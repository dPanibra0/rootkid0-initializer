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

const PHASE_MANIFEST = {
  "01-business": {
    phaseFolder: "01-Business",
    title: "Discovery y Contexto",
    outputSlug: "resumen-cliente"
  },
  "02-proposal": {
    phaseFolder: "02-Proposal",
    title: "Propuesta de Solucion",
    outputSlug: "propuesta-cliente"
  },
  "03-design": {
    phaseFolder: "03-Design",
    title: "Diseno de la Solucion",
    outputSlug: "diseno-cliente"
  },
  "04-management": {
    phaseFolder: "04-Management",
    title: "Plan de Ejecucion",
    outputSlug: "roadmap-cliente"
  },
  "05-development": {
    phaseFolder: "05-Development",
    title: "Estrategia de Desarrollo",
    outputSlug: "desarrollo-cliente"
  },
  "06-deployment": {
    phaseFolder: "06-Deployment",
    title: "Preparacion de Deployment",
    outputSlug: "deployment-cliente"
  },
  "07-production": {
    phaseFolder: "07-Production",
    title: "Operacion en Produccion",
    outputSlug: "operacion-cliente"
  }
};

const PHASE_ALIASES = {
  "01": "01-business",
  business: "01-business",
  discovery: "01-business",
  "01-business": "01-business",
  "02": "02-proposal",
  proposal: "02-proposal",
  "02-proposal": "02-proposal",
  "03": "03-design",
  design: "03-design",
  "03-design": "03-design",
  "04": "04-management",
  management: "04-management",
  "04-management": "04-management",
  "05": "05-development",
  development: "05-development",
  "05-development": "05-development",
  "06": "06-deployment",
  deployment: "06-deployment",
  "06-deployment": "06-deployment",
  "07": "07-production",
  production: "07-production",
  "07-production": "07-production"
};

const NEXT_STEP_BY_PHASE = {
  "01-business": "Validar hallazgos y aprobar la propuesta de solucion (fase 02-proposal).",
  "02-proposal": "Alinear alcance y pasar a diseno tecnico (fase 03-design).",
  "03-design": "Transformar decisiones de diseno en plan ejecutable de management (fase 04-management).",
  "04-management": "Ejecutar plan en desarrollo con estandares y pruebas (fase 05-development).",
  "05-development": "Preparar despliegue y checklist operativo (fase 06-deployment).",
  "06-deployment": "Iniciar operacion controlada y seguimiento post-release (fase 07-production).",
  "07-production": "Mantener ciclo de mejora continua y retroalimentar backlog/prioridades."
};

function printHelp() {
  console.log("Uso: rootkid0-initializer export-client <phase> [opciones]");
  console.log("     rootkid0-initializer publish <phase> [opciones]");
  console.log("");
  console.log("Fases soportadas:");
  console.log("  01-business | 02-proposal | 03-design | 04-management | 05-development | 06-deployment | 07-production");
  console.log("  Tambien: 01..07 y alias business/proposal/design/management/development/deployment/production");
  console.log("");
  console.log("Opciones:");
  console.log("  --parent-folder-id <id>   ID de carpeta padre en Google Drive.");
  console.log("  --date <YYYY-MM-DD>       Fecha para el naming (default: hoy).");
  console.log("  --version <vX.Y>          Version para el naming (default: v1.0).");
  console.log("  --project-name <nombre>   Nombre canonico del proyecto (default: rootkid0-initializer).");
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
    phaseInput: "",
    parentFolderId: process.env.GDRIVE_PARENT_FOLDER_ID || "",
    projectName: "rootkid0-initializer",
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

    if (arg === "--project-name") {
      options.projectName = argv[i + 1] || "";
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

    if (arg.startsWith("-")) {
      throw new Error(`Opcion no reconocida: ${arg}`);
    }

    if (!options.phaseInput) {
      options.phaseInput = arg;
      continue;
    }

    throw new Error(`Argumento no reconocido: ${arg}`);
  }

  return options;
}

function normalizePhase(phaseInput) {
  const normalized = (phaseInput || "").trim().toLowerCase();
  return PHASE_ALIASES[normalized] || "";
}

function validateOptions(options) {
  if (!options.phaseInput) {
    throw new Error("Debes indicar una fase. Ej: export-client 04-management");
  }

  if (!options.phaseKey) {
    throw new Error(`Fase no reconocida: ${options.phaseInput}`);
  }

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

function listPhaseSourceFiles(phaseKey) {
  const packageRoot = path.resolve(__dirname, "..");
  const phaseDir = path.join(packageRoot, phaseKey);
  if (!fs.existsSync(phaseDir)) {
    throw new Error(`No existe la carpeta de fase: ${phaseDir}`);
  }

  return fs
    .readdirSync(phaseDir, { withFileTypes: true })
    .filter((entry) => entry.isFile())
    .map((entry) => entry.name)
    .filter((name) => /^\d{2}-.*\.md$/i.test(name))
    .sort((a, b) => a.localeCompare(b))
    .map((name) => ({
      absolutePath: path.join(phaseDir, name),
      relativePath: `${phaseKey}/${name}`
    }));
}

function parseDoc(content, fallbackTitle) {
  const lines = content.split(/\r?\n/);
  let title = fallbackTitle;
  let firstParagraph = "";
  const sections = [];
  const bullets = [];

  for (const line of lines) {
    if (!title) {
      const h1 = line.match(/^#\s+(.+)$/);
      if (h1) {
        title = h1[1].trim();
      }
    }

    const h2 = line.match(/^##\s+(.+)$/);
    if (h2) {
      sections.push(h2[1].trim());
    }

    const bullet = line.match(/^[-*]\s+(.+)$/);
    if (bullet) {
      bullets.push(bullet[1].trim());
    }

    if (!firstParagraph) {
      const trimmed = line.trim();
      if (trimmed && !trimmed.startsWith("#") && !trimmed.startsWith("- ") && !trimmed.startsWith("* ")) {
        firstParagraph = trimmed;
      }
    }
  }

  const words = content.trim().split(/\s+/).filter(Boolean).length;
  return {
    title: title || fallbackTitle,
    sections,
    bullets,
    firstParagraph,
    words
  };
}

function uniqueLimited(items, limit) {
  const seen = new Set();
  const result = [];
  for (const item of items) {
    const normalized = item.trim();
    if (!normalized) {
      continue;
    }

    if (seen.has(normalized.toLowerCase())) {
      continue;
    }

    seen.add(normalized.toLowerCase());
    result.push(normalized);
    if (result.length >= limit) {
      break;
    }
  }

  return result;
}

function buildClientFacingMarkdown({ options, phaseInfo, sourceDocs }) {
  const allSections = uniqueLimited(
    sourceDocs.flatMap((doc) => doc.parsed.sections),
    8
  );
  const allBullets = uniqueLimited(
    sourceDocs.flatMap((doc) => doc.parsed.bullets),
    8
  );
  const representativeParagraphs = sourceDocs
    .map((doc) => ({
      title: doc.parsed.title,
      text: doc.parsed.firstParagraph
    }))
    .filter((item) => Boolean(item.text))
    .slice(0, 4);

  const totalWords = sourceDocs.reduce((acc, doc) => acc + doc.parsed.words, 0);
  const lines = [];
  lines.push(`# ${phaseInfo.title} - Documento para Cliente`);
  lines.push("");
  lines.push(`Proyecto: ${options.projectName}`);
  lines.push(`Fase: ${options.phaseKey}`);
  lines.push(`Fecha de exportacion: ${options.date}`);
  lines.push(`Version: ${options.version}`);
  lines.push("");
  lines.push("## Resumen ejecutivo");
  lines.push(
    `Esta entrega resume ${sourceDocs.length} documento(s) reales de la fase ${options.phaseKey}, consolidando decisiones, alcance y estado actual para revision del cliente.`
  );
  lines.push(
    `Cobertura aproximada: ${totalWords} palabras de contenido fuente en ${sourceDocs.length} artefacto(s) de trabajo.`
  );
  lines.push("");
  lines.push("## Documentos fuente utilizados");
  for (const doc of sourceDocs) {
    lines.push(`- ${doc.relativePath}`);
  }
  lines.push("");
  lines.push("## Definiciones y decisiones clave");
  if (allSections.length === 0 && allBullets.length === 0) {
    lines.push("- No se detectaron subtitulos o bullets estructurados en los documentos fuente.");
  } else {
    for (const section of allSections) {
      lines.push(`- ${section}`);
    }
    for (const bullet of allBullets.slice(0, Math.max(0, 8 - allSections.length))) {
      lines.push(`- ${bullet}`);
    }
  }
  lines.push("");
  lines.push("## Alcance y progreso de la fase");
  for (const doc of sourceDocs) {
    lines.push(
      `- ${doc.parsed.title}: ${doc.parsed.sections.length} seccion(es) principales, ${doc.parsed.bullets.length} bullet(s), ${doc.parsed.words} palabras.`
    );
  }
  lines.push("");
  lines.push("## Proximos pasos recomendados");
  lines.push(`- ${NEXT_STEP_BY_PHASE[options.phaseKey]}`);
  lines.push("- Validar este documento con stakeholders y registrar feedback antes de la siguiente fase.");

  if (representativeParagraphs.length > 0) {
    lines.push("");
    lines.push("## Extractos representativos");
    for (const item of representativeParagraphs) {
      lines.push(`### ${item.title}`);
      lines.push(item.text);
      lines.push("");
    }
  }

  return lines.join("\n").trim() + "\n";
}

async function run() {
  const options = parseArgs(process.argv.slice(2));
  if (options.help) {
    printHelp();
    return;
  }

  options.phaseKey = normalizePhase(options.phaseInput);
  validateOptions(options);

  const phaseInfo = PHASE_MANIFEST[options.phaseKey];
  const sourceFiles = listPhaseSourceFiles(options.phaseKey);
  if (sourceFiles.length === 0) {
    throw new Error(`No se encontraron documentos reales en ${options.phaseKey} (esperado: archivos 01-*.md, 02-*.md, etc.)`);
  }

  const sourceDocs = sourceFiles.map((fileInfo) => {
    const raw = fs.readFileSync(fileInfo.absolutePath, "utf8");
    return {
      ...fileInfo,
      parsed: parseDoc(raw, path.basename(fileInfo.relativePath, ".md"))
    };
  });

  const fileName = `${options.date}_${options.phaseKey}_${phaseInfo.outputSlug}_${options.version}`;
  const generatedContent = buildClientFacingMarkdown({ options, phaseInfo, sourceDocs });

  if (options.dryRun) {
    console.log("[dry-run] Se exportaria un documento cliente-facing desde documentos reales:");
    console.log(`- Fase: ${options.phaseKey}`);
    console.log(`- Carpeta destino: ${phaseInfo.phaseFolder}`);
    console.log(`- Documento: ${fileName}`);
    console.log("- Fuentes:");
    for (const doc of sourceDocs) {
      console.log(`  - ${doc.relativePath}`);
    }
    console.log(`- Preview bytes: ${Buffer.byteLength(generatedContent, "utf8")}`);
    return;
  }

  const credentials = loadCredentials();
  const accessToken = await getAccessToken(credentials);
  const existingFolder = await findDriveFolder(accessToken, phaseInfo.phaseFolder, options.parentFolderId);
  const folder = existingFolder
    ? existingFolder
    : await createDriveFolder(accessToken, phaseInfo.phaseFolder, options.parentFolderId);

  console.log(
    existingFolder
      ? `Carpeta existente: ${phaseInfo.phaseFolder} (${folder.id})`
      : `Carpeta creada: ${phaseInfo.phaseFolder} (${folder.id})`
  );

  const file = await createGoogleDoc(accessToken, folder.id, fileName, generatedContent);
  console.log(`Documento creado: ${file.name} (${file.webViewLink || file.id})`);
}

run().catch((error) => {
  console.error(`Error: ${error.message}`);
  console.error("Tip: valida fase, documentos fuente reales y credenciales OAuth/Service Account.");
  process.exit(1);
});
