#!/usr/bin/env node

const { spawnSync } = require("node:child_process");
const path = require("node:path");

const argv = process.argv.slice(2);
let projectName = "";

function printHelp() {
  console.log("Uso: rootkid0-initializer <project-name>");
  console.log("");
  console.log("Ejemplos:");
  console.log("  npx rootkid0-initializer my-project");
}

for (const arg of argv) {
  if (arg === "-h" || arg === "--help") {
    printHelp();
    process.exit(0);
  }

  if (arg.startsWith("-")) {
    console.error(`Error: opcion no reconocida '${arg}'`);
    printHelp();
    process.exit(1);
  }

  if (!projectName) {
    projectName = arg;
    continue;
  }

  console.error(`Error: argumento no reconocido '${arg}'`);
  printHelp();
  process.exit(1);
}

const packageRoot = path.resolve(__dirname, "..");
let command = "";
let commandArgs = [];

if (process.platform === "win32") {
  const psScript = path.join(packageRoot, "rootkid0-bootstrap", "init-project.ps1");
  command = "powershell";
  commandArgs = ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", psScript];

  if (projectName) {
    commandArgs.push(projectName);
  }
} else {
  const shScript = path.join(packageRoot, "rootkid0-bootstrap", "init-project.sh");
  command = "bash";
  commandArgs = [shScript];

  if (projectName) {
    commandArgs.push(projectName);
  }
}

const result = spawnSync(command, commandArgs, {
  stdio: "inherit",
  cwd: process.cwd()
});

if (result.error) {
  console.error(`Error ejecutando bootstrap: ${result.error.message}`);
  process.exit(1);
}

if (typeof result.status === "number") {
  process.exit(result.status);
}

process.exit(1);
