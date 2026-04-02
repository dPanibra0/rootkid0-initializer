# Generador Product 2 Lightweight en Google Drive

Este comando crea carpetas por fase y sube 4 templates cliente-facing como Google Docs.

## Templates incluidos

- `02-proposal` -> Propuesta de Solucion (v1)
- `04-management` -> Roadmap Ejecutivo
- `06-deployment` -> Plan de Release y Comunicacion
- `07-production` -> Reporte Operativo Mensual

Fuente en repo:

- `99-common/templates/product2-lightweight/`

## Export Product 4 (documento cliente-facing desde docs reales)

Este flujo exporta **una fase por ejecucion** y construye el contenido desde documentos reales del repo (no templates estaticos).

Comandos:

```bash
npx rootkid0-initializer export-client 04-management --dry-run --date 2026-04-01 --version v1.0
```

Alias:

```bash
npx rootkid0-initializer publish 04-management --dry-run --date 2026-04-01 --version v1.0
```

Ejecucion real:

```bash
npx rootkid0-initializer export-client 04-management --parent-folder-id <DRIVE_FOLDER_ID> --date 2026-04-01 --version v1.0
```

Detalles:

- Fases soportadas: `01-business` a `07-production` (tambien `01..07` y alias simples).
- Fuente de contenido: archivos `NN-*.md` dentro de la fase elegida.
- Salida: 1 Google Doc cliente-facing en la carpeta de fase de Drive.
- No modifica el comportamiento de `drive-templates`.

## Requisitos

1. Node.js 18+
2. Service account de Google Cloud con Google Drive API habilitada
3. Carpeta padre en Drive compartida con el email del service account (Editor)

## Variables de entorno

Politica estricta (obligatoria):

- Nunca almacenar credenciales en este repositorio.
- Si `GOOGLE_APPLICATION_CREDENTIALS` apunta dentro del repo, `drive-templates` y `export-client` fallan de forma intencional con error explicito.
- Esta restriccion no aplica cuando usas solo `GDRIVE_SERVICE_ACCOUNT_EMAIL` + `GDRIVE_SERVICE_ACCOUNT_PRIVATE_KEY` (sin archivo JSON).

Opcion A (recomendada en CI):

- `GDRIVE_SERVICE_ACCOUNT_EMAIL`
- `GDRIVE_SERVICE_ACCOUNT_PRIVATE_KEY` (usar `\\n` para saltos de linea)
- `GDRIVE_PARENT_FOLDER_ID`

Opcion B (local):

- `GOOGLE_APPLICATION_CREDENTIALS` apuntando a un JSON de service account fuera del repo
- `GDRIVE_PARENT_FOLDER_ID`

Opcion C (local con OAuth client web/desktop):

- `GOOGLE_APPLICATION_CREDENTIALS` apuntando a `client_secret_*.json` (formato `web` o `installed`) fuera del repo
- `GDRIVE_OAUTH_REFRESH_TOKEN`
- `GDRIVE_PARENT_FOLDER_ID`

Ejemplos de rutas seguras (placeholders):

- `C:\\secure\\gdrive\\service-account.json`
- `/etc/secrets/gdrive/service-account.json`

Opcional en OAuth (si no viene desde JSON):

- `GDRIVE_OAUTH_CLIENT_ID`
- `GDRIVE_OAUTH_CLIENT_SECRET`

## Scope minimo

- `https://www.googleapis.com/auth/drive.file`

Este scope permite crear y gestionar archivos creados por el propio servicio, minimizando permisos.

## Comandos

Dry run (sin llamadas a Google):

```bash
npx rootkid0-initializer drive-templates --dry-run --date 2026-04-01 --version v1.0
```

Generar y subir los 4 templates:

```bash
npx rootkid0-initializer drive-templates --parent-folder-id <DRIVE_FOLDER_ID> --date 2026-04-01 --version v1.0
```

Tambien puedes usar la variable `GDRIVE_PARENT_FOLDER_ID` y omitir `--parent-folder-id`.

Para subir directo al root de My Drive, usa `--parent-folder-id root` (o `GDRIVE_PARENT_FOLDER_ID=root`).

## Convencion de nombres

Cada documento se crea con:

- `YYYY-MM-DD_<fase>_<nombre>_vX.Y`

Ejemplo:

- `2026-04-01_04-management_roadmap-ejecutivo_v1.0`

## Carpetas que crea el comando

Debajo del parent folder configurado:

- `02-Proposal`
- `04-Management`
- `06-Deployment`
- `07-Production`

## Errores comunes

- `403` o `404` al crear carpetas: la carpeta padre no esta compartida con el service account o el ID es incorrecto.
- `invalid_grant`: clave privada invalida o reloj local desfasado.
- `No se encontraron credenciales`: faltan env vars o `GOOGLE_APPLICATION_CREDENTIALS`.
- `invalid_grant` con OAuth refresh token: refresh token expirado/revocado o client_id/client_secret no coincide.

## Seguridad

- Nunca commitear JSON de credenciales ni variables `.env`.
- Nunca dejar credenciales dentro del arbol de este repo.
- Guardar secretos en el vault/secret manager del entorno.
- Rotar claves del service account segun politica interna.

Guard rails recomendados (checklist manual en raiz del repo, no runtime scan):

- Verificar que no existan archivos sensibles con nombres `client_secret*.json` o `credentials*.json` antes de commit.
