# SUD💜KU

FOSS Sudoku! What else needs be said?


<a href="https://liberapay.com/TheSunCat/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg"> <img src="https://img.shields.io/liberapay/receives/TheSunCat.svg"></a>


<p float="left">
<img src="https://github.com/TheSunCat/Sudoku/raw/main/metadata/en-US/images/phoneScreenshots/01_home.png" width=30%>
<img src="https://github.com/TheSunCat/Sudoku/raw/main/metadata/en-US/images/phoneScreenshots/02_ingame.png" width=30%>
<img src="https://github.com/TheSunCat/Sudoku/raw/main/metadata/en-US/images/phoneScreenshots/03_ingame.png" width=30%>
</p>

## Features
- Play Sudoku!
- Markup where numbers could go.
- Highlight numbers to better examine the board.
- Validate the current board to find mistakes.
- Smooth and sleek animations.
- Full theming support.
- Local leaderboard to track your best times per difficulty.
- Auto-save the game so you can pick back up where you left off.
- Fully Free and Open Source Software!

## How to run

### Android
Download and install the APK. It should run with no problems.

### Linux
Run the `sudoku` binary. You may need to mark it as executable first.

### Web
Serve the folder as an HTTP server. I used `simple-http-server` from the AUR, though any should work.

---

**NOTE**: This app was designed for the mobile form factor. Make sure the window is sufficiently tall and thin to accomodate the game, or it won't look right!

## Building
Clone the repository, run `flutter pub get`, and run one of the following:

- Android: `flutter build apk`
- Linux: `flutter build linux --release`
- Web: `flutter build web`
- iOS and macOS (untested): it's possible, but more complicated. See the Flutter wiki for details.
- Microsoft Windows (untested, unsupported): `flutter build windows`

You will find the build output inside your platform's folder within `./build/`. All contributions are welcome!

<br><br>
---
<sub><sup>Dedicated to you (you know who you are!). </sup></sub>
