# Parity Twist

A strategy game where two players (or one player vs AI) take turns placing numbers 1-10 on a board, competing to win 2 out of 3 rows. The twist: whether the higher or lower number wins each row depends on parity rules determined by a shared Master Key.

**Play now:** https://parity-twist.vercel.app

## Rules

The board has 3 rows and 3 columns (**P1**, **P2**, **Key**), plus one **Master Key** cell below — 10 cells total. Players alternate placing the numbers 1 through 10, one per cell, in any empty cell. Each number is used exactly once.

After all 10 cells are filled, each row is scored:

- Compare the **Key** column number's parity (odd/even) with the **Master Key**'s parity
- **Same parity** (both odd or both even) → the **lower** number between P1 and P2 wins the row
- **Different parity** → the **higher** number wins the row
- Win **2 out of 3** rows to win the game

The Master Key affects all three rows at once, making it the most powerful cell on the board.

## Variants

You can choose a ruleset before each game:

- **Classic** — Original 10-cell game (3 rows + 1 Master Key).
- **Delfs** — 9-cell game with no Master Key cell; parity uses the sum of the Key column.
- **Whiteacre** — Normal Master Key scoring with numbers 1-12; fill 10 cells and leave 2 numbers unplayed.
- **Hodgkins** — Normal board rules, but parity row wins are worth 2 points each and each row gives +1 to the number closest to that row's Key.
- **Dual Master Keys** — Uses two master cells: odd-key rows use MASTER ODD, even-key rows use MASTER EVEN.
- **Key Locking** — Filling a Key cell locks that row’s P1/P2 cells for one opponent turn.
- **Draft + Place** — Each turn has two phases: draft from market, then place from your hand.
- **Hidden Master Key** — Master Key value stays hidden until endgame scoring.

## Game Modes

### VS Player
Local pass-and-play for two humans. Players alternate turns starting with P1.

### VS AI
Single-player against an AI opponent. After selecting VS AI you choose:

1. **Difficulty**
   - **Easy** — picks a random legal move
   - **Medium** — minimax search to depth 2 with a heuristic evaluation
   - **Hard** — minimax depth 3 in the early game, solves to completion when 6 or fewer moves remain (perfect endgame play)

2. **Turn order** — You first, AI first, or Random

The AI uses minimax with alpha-beta pruning. The search space is small enough (518K nodes at 6 moves remaining) that Hard mode solves the endgame exactly.

## Project Structure

```
parity-twist/
  assets/game.html       # The entire game (HTML/CSS/JS in one file)
  web/index.html          # Copy of game.html for web deployment
  src/com/paritytwist/
    MainActivity.java     # Android WebView wrapper
  AndroidManifest.xml     # Android app manifest
  res/
    drawable/ic_launcher.png
    values/strings.xml
  build.sh                # Builds the APK from source
  make_icon.py            # Generates the launcher icon (requires Pillow)
  .gitignore
```

The game is a single self-contained HTML file (`assets/game.html`). The Android app is a thin WebView wrapper that loads it. The same file is deployed to the web as `web/index.html`.

## Building

### Prerequisites (Termux)

```bash
pkg install aapt2 d8 openjdk-17 android-tools
```

This provides `aapt2`, `apksigner`, `javac`, and the D8 dex compiler. The build script auto-downloads `android.jar` (API 34, ~26MB) and copies `r8.jar` from the `d8` package on first run — no manual setup needed.

For non-Termux environments, manually place `android.jar` (API 34) and `r8.jar` in `libs/`.

### Build the APK

```bash
bash build.sh
```

This compiles resources, Java source, converts to DEX, packages, and signs with a debug keystore (auto-generated on first build). Output: `build/parity-twist-dev-v0.00-<rev>.apk`.

### Regenerate the icon

```bash
pip install Pillow
python make_icon.py
```

## Deploying to the Web

Deploy web with the helper script:

```bash
bash deploy-web.sh
```

The script auto-copies `assets/game.html` to `web/index.html` and deploys to the correct Vercel project for the current branch (`main` or `dev`).

Or just open `web/index.html` in any browser — no server required.

## Branches

| Branch | Web URL | APK name |
|--------|---------|----------|
| `main` | https://parity-twist.vercel.app | `parity-twist.apk` |
| `dev` | https://parity-twist-dev.vercel.app | `parity-twist-dev-v0.00-<rev>.apk` |

The `dev` branch builds include a watermark (branch and rev ID) in the bottom-right corner of the game.

## Dev Environment

The `dev` branch has its own Vercel project (`parity-twist-dev`) to avoid accidentally deploying dev code to production.

### Building the dev APK

```bash
git checkout dev
bash build.sh
```

Output: `build/parity-twist-dev-v0.00-<rev>.apk`. The rev ID is the short git commit hash at build time.

### Deploying dev to the web

From the `dev` branch, deploy with:

```bash
bash deploy-web.sh
```

This targets `parity-twist-dev.vercel.app` automatically.

### Promoting dev to production

When dev is ready, merge into main and deploy from there:

```bash
git checkout main
git merge dev
bash build.sh
bash deploy-web.sh
```

## Development

All game logic lives in `assets/game.html`. To make changes:

1. Edit `assets/game.html`
2. Test by opening it directly in a browser
3. Rebuild APK with `bash build.sh`
4. Deploy web with `bash deploy-web.sh`

### Architecture Notes

- **Single-file game** — all CSS, HTML, and JS in one file, no dependencies
- **AI engine** — minimax with alpha-beta pruning, runs synchronously in the main thread (fast enough for this game's branching factor)
- **Android wrapper** — `MainActivity.java` is a fullscreen WebView that loads `file:///android_asset/game.html`
- **State management** — plain JS variables (`board`, `usedNumbers`, `currentPlayer`, etc.), no framework
- **Endgame display** — inline (board stays visible at 82% scale with a scoreboard and row-by-row breakdown), no modal overlay
