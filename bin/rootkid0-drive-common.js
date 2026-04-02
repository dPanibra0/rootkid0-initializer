const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");

const REPO_ROOT = path.resolve(__dirname, "..");

function normalizeAbsolutePath(absolutePath) {
  const normalized = path.normalize(absolutePath).replace(/[\\/]+$/, "");
  return process.platform === "win32" ? normalized.toLowerCase() : normalized;
}

function isPathInsideDirectory(candidatePath, directoryPath) {
  const normalizedCandidate = normalizeAbsolutePath(candidatePath);
  const normalizedDirectory = normalizeAbsolutePath(directoryPath);
  if (normalizedCandidate === normalizedDirectory) {
    return true;
  }

  return normalizedCandidate.startsWith(`${normalizedDirectory}${path.sep}`);
}

function assertCredentialsOutsideRepo(credentialsPath) {
  if (!credentialsPath) {
    return;
  }

  const resolvedPath = path.resolve(process.cwd(), credentialsPath);
  if (isPathInsideDirectory(resolvedPath, REPO_ROOT)) {
    throw new Error(
      [
        "Politica estricta: GOOGLE_APPLICATION_CREDENTIALS no puede apuntar dentro del repositorio.",
        `Ruta detectada: ${resolvedPath}`,
        `Repo root: ${REPO_ROOT}`,
        "Mueve el JSON fuera del proyecto y actualiza la variable.",
        "Ejemplos seguros: C:\\secure\\gdrive\\service-account.json o /etc/secrets/gdrive/service-account.json",
        "Alternativa sin archivo: usar GDRIVE_SERVICE_ACCOUNT_EMAIL + GDRIVE_SERVICE_ACCOUNT_PRIVATE_KEY"
      ].join(" ")
    );
  }
}

function base64Url(input) {
  return Buffer.from(input)
    .toString("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

function signJwt(email, privateKey, scope) {
  const now = Math.floor(Date.now() / 1000);
  const header = base64Url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const payload = base64Url(
    JSON.stringify({
      iss: email,
      scope,
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600
    })
  );

  const unsigned = `${header}.${payload}`;
  const signer = crypto.createSign("RSA-SHA256");
  signer.update(unsigned);
  signer.end();
  const signature = signer
    .sign(privateKey, "base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  return `${unsigned}.${signature}`;
}

async function requestJson(url, requestOptions, context) {
  const response = await fetch(url, requestOptions);
  const raw = await response.text();
  let parsed;

  try {
    parsed = raw ? JSON.parse(raw) : {};
  } catch (error) {
    parsed = { raw };
  }

  if (!response.ok) {
    const details = parsed.error?.message || parsed.raw || `HTTP ${response.status}`;
    throw new Error(`${context} fallo (${response.status}): ${details}`);
  }

  return parsed;
}

function loadCredentialsFromPath(credentialsPath) {
  if (!credentialsPath) {
    return null;
  }

  const resolvedPath = path.resolve(process.cwd(), credentialsPath);
  assertCredentialsOutsideRepo(resolvedPath);

  if (!fs.existsSync(resolvedPath)) {
    throw new Error(`No existe GOOGLE_APPLICATION_CREDENTIALS en: ${resolvedPath}`);
  }

  return JSON.parse(fs.readFileSync(resolvedPath, "utf8"));
}

function readOauthClientFromJson(json) {
  if (!json || typeof json !== "object") {
    return null;
  }

  if (json.client_id && json.client_secret) {
    return {
      clientId: json.client_id,
      clientSecret: json.client_secret,
      refreshToken: json.refresh_token || ""
    };
  }

  const oauthClient = json.installed || json.web;
  if (!oauthClient) {
    return null;
  }

  return {
    clientId: oauthClient.client_id,
    clientSecret: oauthClient.client_secret,
    refreshToken: oauthClient.refresh_token || ""
  };
}

function loadCredentials() {
  const fromEnvEmail = process.env.GDRIVE_SERVICE_ACCOUNT_EMAIL;
  const fromEnvKey = process.env.GDRIVE_SERVICE_ACCOUNT_PRIVATE_KEY;

  if (fromEnvEmail && fromEnvKey) {
    return {
      mode: "service_account",
      clientEmail: fromEnvEmail,
      privateKey: fromEnvKey.replace(/\\n/g, "\n")
    };
  }

  const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  const json = loadCredentialsFromPath(credentialsPath);
  if (json && json.client_email && json.private_key) {
    return {
      mode: "service_account",
      clientEmail: json.client_email,
      privateKey: json.private_key
    };
  }

  const oauthRefreshToken = process.env.GDRIVE_OAUTH_REFRESH_TOKEN;
  const oauthClientIdFromEnv = process.env.GDRIVE_OAUTH_CLIENT_ID;
  const oauthClientSecretFromEnv = process.env.GDRIVE_OAUTH_CLIENT_SECRET;

  if (oauthRefreshToken && oauthClientIdFromEnv && oauthClientSecretFromEnv) {
    return {
      mode: "oauth_refresh",
      clientId: oauthClientIdFromEnv,
      clientSecret: oauthClientSecretFromEnv,
      refreshToken: oauthRefreshToken
    };
  }

  const oauthFromJson = readOauthClientFromJson(json);
  if (oauthFromJson?.clientId && oauthFromJson?.clientSecret && (oauthRefreshToken || oauthFromJson.refreshToken)) {
    return {
      mode: "oauth_refresh",
      clientId: oauthFromJson.clientId,
      clientSecret: oauthFromJson.clientSecret,
      refreshToken: oauthRefreshToken || oauthFromJson.refreshToken
    };
  }

  throw new Error(
    "No se encontraron credenciales validas. Usa service account (GDRIVE_SERVICE_ACCOUNT_EMAIL + GDRIVE_SERVICE_ACCOUNT_PRIVATE_KEY), o OAuth refresh token (GDRIVE_OAUTH_REFRESH_TOKEN + client_id/client_secret via env o GOOGLE_APPLICATION_CREDENTIALS)."
  );
}

async function getAccessToken(credentials) {
  if (credentials.mode === "oauth_refresh") {
    const body = new URLSearchParams({
      grant_type: "refresh_token",
      client_id: credentials.clientId,
      client_secret: credentials.clientSecret,
      refresh_token: credentials.refreshToken
    });

    const tokenResponse = await requestJson(
      "https://oauth2.googleapis.com/token",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: body.toString()
      },
      "Solicitud de access token"
    );

    if (!tokenResponse.access_token) {
      throw new Error("No se recibio access_token desde Google OAuth.");
    }

    return tokenResponse.access_token;
  }

  const scope = "https://www.googleapis.com/auth/drive.file";
  const assertion = signJwt(credentials.clientEmail, credentials.privateKey, scope);
  const body = new URLSearchParams({
    grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
    assertion
  });

  const tokenResponse = await requestJson(
    "https://oauth2.googleapis.com/token",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: body.toString()
    },
    "Solicitud de access token"
  );

  if (!tokenResponse.access_token) {
    throw new Error("No se recibio access_token desde Google OAuth.");
  }

  return tokenResponse.access_token;
}

async function createDriveFolder(accessToken, folderName, parentId) {
  return requestJson(
    "https://www.googleapis.com/drive/v3/files?fields=id,name,webViewLink",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        name: folderName,
        mimeType: "application/vnd.google-apps.folder",
        parents: [parentId]
      })
    },
    `Creacion de carpeta ${folderName}`
  );
}

function escapeDriveQueryValue(value) {
  return value.replace(/'/g, "\\'");
}

async function findDriveFolder(accessToken, folderName, parentId) {
  const query = [
    `name='${escapeDriveQueryValue(folderName)}'`,
    "mimeType='application/vnd.google-apps.folder'",
    "trashed=false",
    `'${escapeDriveQueryValue(parentId)}' in parents`
  ].join(" and ");

  const url =
    "https://www.googleapis.com/drive/v3/files" +
    `?q=${encodeURIComponent(query)}` +
    "&fields=files(id,name,webViewLink)" +
    "&pageSize=1";

  const response = await requestJson(
    url,
    {
      method: "GET",
      headers: {
        Authorization: `Bearer ${accessToken}`
      }
    },
    `Busqueda de carpeta ${folderName}`
  );

  return response.files && response.files.length > 0 ? response.files[0] : null;
}

async function createGoogleDoc(accessToken, folderId, fileName, content) {
  const boundary = `rootkid0-${crypto.randomUUID()}`;
  const metadata = {
    name: fileName,
    mimeType: "application/vnd.google-apps.document",
    parents: [folderId]
  };

  const multipartBody = [
    `--${boundary}`,
    "Content-Type: application/json; charset=UTF-8",
    "",
    JSON.stringify(metadata),
    `--${boundary}`,
    "Content-Type: text/plain; charset=UTF-8",
    "",
    content,
    `--${boundary}--`
  ].join("\r\n");

  return requestJson(
    "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&fields=id,name,webViewLink",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": `multipart/related; boundary=${boundary}`
      },
      body: multipartBody
    },
    `Creacion de documento ${fileName}`
  );
}

module.exports = {
  loadCredentials,
  getAccessToken,
  findDriveFolder,
  createDriveFolder,
  createGoogleDoc
};
