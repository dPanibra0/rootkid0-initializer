#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");
const {
  loadCredentials,
  getAccessToken,
  findDriveFolder,
  createDriveFolder,
  createGoogleDoc
} = require("./rootkid0-drive-common");

const TEMPLATE_DEFINITIONS = [
  {
    phaseKey: "02-proposal",
    phaseFolder: "02-Proposal",
    nameSlug: "propuesta-de-solucion",
    templatePath: "99-common/templates/product2-lightweight/02-propuesta-solucion-v1.md"
  },
  {
    phaseKey: "04-management",
    phaseFolder: "04-Management",
    nameSlug: "roadmap-ejecutivo",
    templatePath: "99-common/templates/product2-lightweight/04-roadmap-ejecutivo.md"
  },
  {
    phaseKey: "06-deployment",
    phaseFolder: "06-Deployment",
    nameSlug: "plan-release-comunicacion",
    templatePath: "99-common/templates/product2-lightweight/06-plan-release-comunicacion.md"
  },
  {
    phaseKey: "07-production",
    phaseFolder: "07-Production",
    nameSlug: "reporte-operativo-mensual",
    templatePath: "99-common/templates/product2-lightweight/07-reporte-operativo-mensual.md"
  }
];

function printHelp() {
  console.log("Uso: rootkid0-initializer drive-templates [opciones]");
  console.log("");
  console.log("Opciones:");
  console.log("  --parent-folder-id <id>   ID de carpeta padre en Google Drive.");
  console.log("  --date <YYYY-MM-DD>       Fecha para el naming (default: hoy).");
  console.log("  --version <vX.Y>          Version para el naming (default: v1.0).");
  console.log("  --dry-run                 Muestra el plan sin llamar APIs.");
  console.log("  -h, --help                Muestra esta ayuda.");
  console.log("");
  console.log("Env vars soportadas:");
  console.log("  GDRIVE_PARENT_FOLDER_ID");
  console.log("  GDRIVE_SERVICE_ACCOUNT_EMAIL");
  console.log("  GDRIVE_SERVICE_ACCOUNT_PRIVATE_KEY");
  console.log("  GDRIVE_OAUTH_REFRESH_TOKEN");
  console.log("  GDRIVE_OAUTH_CLIENT_ID");
  console.log("  GDRIVE_OAUTH_CLIENT_SECRET");
  console.log("  GOOGLE_APPLICATION_CREDENTIALS");
}

function parseArgs(argv) {
  const options = {
    parentFolderId: process.env.GDRIVE_PARENT_FOLDER_ID || "",
    date: new Date().toISOString().slice(0, 10),
    version: "v1.0",
    dryRun: false
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "-h" || arg === "--help") {
      options.help = true;
      continue;
    }

    if (arg === "--dry-run") {
      options.dryRun = true;
      continue;
    }

    if (arg === "--parent-folder-id") {
      options.parentFolderId = argv[i + 1] || "";
      i += 1;
      continue;
    }

    if (arg === "--date") {
      options.date = argv[i + 1] || "";
      i += 1;
      continue;
    }

    if (arg === "--version") {
      options.version = argv[i + 1] || "";
      i += 1;
      continue;
    }

    throw new Error(`Opcion no reconocida: ${arg}`);
  }

  return options;
}

function validateOptions(options) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(options.date)) {
    throw new Error("--date debe usar formato YYYY-MM-DD.");
  }

  if (!/^v\d+\.\d+$/.test(options.version)) {
    throw new Error("--version debe usar formato vX.Y (ej: v1.0).");
  }

  if (!options.parentFolderId && !options.dryRun) {
    throw new Error("Falta parent folder ID. Usa --parent-folder-id o GDRIVE_PARENT_FOLDER_ID.");
  }
}

function readTemplateContent(templatePath) {
  const packageRoot = path.resolve(__dirname, "..");
  const absolutePath = path.join(packageRoot, templatePath);
  if (!fs.existsSync(absolutePath)) {
    throw new Error(`No existe template: ${absolutePath}`);
  }

  return fs.readFileSync(absolutePath, "utf8");
}

async function run() {
  const options = parseArgs(process.argv.slice(2));
  if (options.help) {
    printHelp();
    return;
  }

  validateOptions(options);

  const plannedFiles = TEMPLATE_DEFINITIONS.map((template) => ({
    ...template,
    fileName: `${options.date}_${template.phaseKey}_${template.nameSlug}_${options.version}`
  }));

  if (options.dryRun) {
    console.log("[dry-run] Se crearian estas carpetas y documentos:");
    for (const template of plannedFiles) {
      console.log(`- ${template.phaseFolder}/${template.fileName}`);
    }
    return;
  }

  const credentials = loadCredentials();
  const accessToken = await getAccessToken(credentials);

  const folderIdsByPhase = {};
  for (const template of plannedFiles) {
    if (!folderIdsByPhase[template.phaseKey]) {
      const existingFolder = await findDriveFolder(accessToken, template.phaseFolder, options.parentFolderId);
      const folder = existingFolder
        ? existingFolder
        : await createDriveFolder(accessToken, template.phaseFolder, options.parentFolderId);

      folderIdsByPhase[template.phaseKey] = folder.id;
      console.log(
        existingFolder
          ? `Carpeta existente: ${template.phaseFolder} (${folder.id})`
          : `Carpeta creada: ${template.phaseFolder} (${folder.id})`
      );
    }

    const content = readTemplateContent(template.templatePath);
    const file = await createGoogleDoc(
      accessToken,
      folderIdsByPhase[template.phaseKey],
      template.fileName,
      content
    );

    console.log(`Documento creado: ${file.name} (${file.webViewLink || file.id})`);
  }
}

run().catch((error) => {
  console.error(`Error: ${error.message}`);
  console.error("Tip: valida credenciales OAuth/Service Account y permisos sobre la carpeta destino.");
  process.exit(1);
});
