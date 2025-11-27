Lambda Packager Script
Packages every Lambda under lambda_backend/* into a zip next to its source folder. Supports Python (requirements.txt) and Node (package.json) dependencies.

What it does
Discovers immediate subfolders under lambda_backend/ (override with LAMBDA_BASE_DIR_OVERRIDE).
For each folder:
If requirements.txt exists: installs Python deps into a temp pkg dir.
If package.json exists: runs npm ci --omit=dev in a temp pkg dir.
Copies source files (common code assets; excludes tests, node_modules, venv, caches).
Creates <lambda_dir>/<lambda_name>.zip.
Prereqs
Python 3 + pip available on PATH (for Python lambdas).
Node.js + npm available on PATH (for Node lambdas).
Unix shell (bash), zip, rsync.
Source layout: one Lambda per folder under lambda_backend/ by default.
Usage
cd <repo-root>
./scripts/package_lambdas.sh     # adjust path to the script
Optional: point to a different base directory:

LAMBDA_BASE_DIR_OVERRIDE="/path/to/lambdas" ./scripts/package_lambdas.sh
Outputs
For each Lambda folder lambda_backend/<Name>/, a zip is emitted at lambda_backend/<Name>/<Name>.zip.
Notes
Dependencies are installed into a temp workspace per Lambda; source and zips stay clean.
Supports mixed Python/Node lambdas; if neither requirements.txt nor package.json is present, it just zips the sources.
Excludes common junk (node_modules, __pycache__, .venv, tests, etc.).
gimme in markdown blockk


## Lambda Packager Script

Packages every Lambda under `lambda_backend/*` into a zip next to its source folder. Supports Python (requirements.txt) and Node (package.json) dependencies.

### What it does
- Discovers immediate subfolders under `lambda_backend/` (override with `LAMBDA_BASE_DIR_OVERRIDE`).
- For each folder:
  - If `requirements.txt` exists: installs Python deps into a temp pkg dir.
  - If `package.json` exists: runs `npm ci --omit=dev` in a temp pkg dir.
  - Copies source files (common code assets; excludes tests, node_modules, venv, caches).
  - Creates `<lambda_dir>/<lambda_name>.zip`.

### Prereqs
- Python 3 + pip available on PATH (for Python lambdas).
- Node.js + npm available on PATH (for Node lambdas).
- Unix shell (bash), zip, rsync.
- Source layout: one Lambda per folder under `lambda_backend/` by default.

### Usage
```bash
cd <repo-root>
./scripts/package_lambdas.sh     # adjust path to the script
Override base dir:

LAMBDA_BASE_DIR_OVERRIDE="/path/to/lambdas" ./scripts/package_lambdas.sh
Outputs
For each Lambda folder lambda_backend/<Name>/, a zip is emitted at lambda_backend/<Name>/<Name>.zip.
Notes
Dependencies are installed into a temp workspace per Lambda; source and zips stay clean.
Supports mixed Python/Node lambdas; if neither requirements.txt nor package.json is present, it just zips the sources.
Excludes common junk (node_modules, __pycache__, .venv, tests, etc.).
