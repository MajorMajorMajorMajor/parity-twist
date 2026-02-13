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

### Prerequisites

The build script targets **Termux on Android** but works anywhere with these tools:

- **Java JDK 11+** (for `javac`)
- **Android SDK** — specifically `aapt2` and `apksigner` on your PATH
- **android.jar** (API 34) at `libs/android.jar`
- **r8.jar** (D8 dex compiler) at `libs/r8.jar`

### Build the APK

```bash
bash build.sh
```

This compiles resources, Java source, converts to DEX, packages, and signs with a debug keystore (auto-generated on first build). Output: `build/parity-twist.apk`.

### Regenerate the icon

```bash
pip install Pillow
python make_icon.py
```

## Deploying to the Web

Copy the game to the web directory and deploy:

```bash
cp assets/game.html web/index.html
cd web
vercel --prod
```

Or just open `web/index.html` in any browser — no server required.

## Development

All game logic lives in `assets/game.html`. To make changes:

1. Edit `assets/game.html`
2. Test by opening it directly in a browser
3. Copy to `web/index.html` when ready
4. Rebuild APK with `bash build.sh`
5. Deploy web with `vercel --prod` from `web/`

### Architecture Notes

- **Single-file game** — all CSS, HTML, and JS in one file, no dependencies
- **AI engine** — minimax with alpha-beta pruning, runs synchronously in the main thread (fast enough for this game's branching factor)
- **Android wrapper** — `MainActivity.java` is a fullscreen WebView that loads `file:///android_asset/game.html`
- **State management** — plain JS variables (`board`, `usedNumbers`, `currentPlayer`, etc.), no framework
- **Endgame display** — inline (board stays visible at 82% scale with a scoreboard and row-by-row breakdown), no modal overlay
