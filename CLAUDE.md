# Claude Code Instructions

## Git

- Never push to a remote unless the user explicitly asks (git push, gh pr create, etc.).

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

## Default After-Change Workflow

On each code/content change (unless the user asks to skip):

1. Commit changes locally (clear message; use `Pi <pi@localhost>` unless user says otherwise).
2. Build APK: `bash build.sh`
3. Copy newest APK to Android Downloads:
   - `LATEST_APK=$(ls -t build/*.apk | head -n 1); cp "$LATEST_APK" /storage/emulated/0/Download/`
4. Publish web to Vercel for the current branch:
   - On `dev`: use `VERCEL_ORG_ID=team_EmWFQ8bH8Vr73Ied2rfX5cHh VERCEL_PROJECT_ID=prj_qRCCwl8MuFf2vjXIKAhIbZMbFwx5 vercel --yes --prod` from `web/`
   - On `main`: deploy to production project (`parity-twist`) from `web/`

Do not push commits to GitHub unless the user explicitly requests it.
