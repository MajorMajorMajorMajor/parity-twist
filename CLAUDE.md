# Claude Code Instructions

## Git

- Always ask for user confirmation before pushing to a remote (git push, gh pr create, etc.)

## Branches

- `main` deploys to `parity-twist.vercel.app` (production)
- `dev` deploys to `parity-twist-dev.vercel.app` (dev Vercel project)
- Never deploy the `dev` branch to the production Vercel project
- Dev web deploys require env vars: `VERCEL_ORG_ID=team_EmWFQ8bH8Vr73Ied2rfX5cHh VERCEL_PROJECT_ID=prj_qRCCwl8MuFf2vjXIKAhIbZMbFwx5`

## APK Build

- `build.sh` auto-downloads `android.jar` and copies `r8.jar` on first run — no manual setup needed
- Required Termux packages: `aapt2 d8 openjdk-17 android-tools` (install with `pkg install`)
- If `libs/` is missing, just run `bash build.sh` — it will set itself up
- The `libs/` directory is gitignored (downloaded/copied jars, ~26MB)
