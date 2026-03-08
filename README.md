# ART CAT - Mobile Art App

A playful, cross-platform art application built with Flutter featuring an adorable cat mascot that guides users through the creative process.

## Features

### Core Features (MVP)
- **Drawing Canvas** - Smooth freehand drawing with customisable brushes
- **Art Cat Mascot** - Interactive cat companion with helpful tooltips
- **Prompt Generator** - Creative prompt system with lock/shuffle functionality
- **Tools Panel** - Pen, pencil, eraser, shapes, and fill tools
- **Colour Palette** - 12 basic colours with easy selection
- **Gallery** - View and manage saved artworks
- **Offline Support** - All data stored locally using Hive

### Drawing Tools
- Pen (smooth lines)
- Pencil (lighter strokes)
- Eraser
- Shape tool (circle, square, triangle)
- Fill tool
- Adjustable brush size (1-50px)
- Undo/Redo support

### Art Cat Mascot
- Tap the cat for contextual help
- Reacts to your actions with different expressions
- Provides tips and guidance throughout the app

### Prompt Generator
- Random adjective + noun + verb combinations
- Lock individual words to keep them while shuffling others
- Save favourite prompts for later
- Custom word entry

## Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher

### Installation

1. Clone the repository or navigate to the project directory:
```bash
cd art_cat
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For web (runs in browser)
flutter run -d chrome

# For web when Chrome isn't available (e.g. WSL2) – opens a URL to use in any browser
flutter run -d web-server

# For desktop (Linux) – app opens in a native window (ignore the printed URL; it's for DevTools)
flutter run -d linux

# For Android (if device connected)
flutter run -d android

# For iOS (on macOS)
flutter run -d ios
```

**Note:** With `flutter run -d linux`, the app runs in a **desktop window**, not in the browser. The URL Flutter prints (e.g. `http://127.0.0.1:port/...`) is the Dart VM Service for debugging and hot reload—opening it in a browser shows a blank page. To use the app in the browser, run `flutter run -d chrome` instead.

**WSL2:** On WSL2 there is usually no Linux display server, so `flutter run -d linux` may start but no window appears. Chrome may not be detected as a device. Use **`flutter run -d web-server`** instead: it starts a local server and prints a URL—open that URL in any browser (e.g. Chrome or Edge on Windows). Alternatively use **`flutter run -d chrome`** if Chrome is installed inside WSL.

**WSL2 segfault (cursor theme):** If the Linux app crashes with "Segmentation fault" and "Unable to load from the cursor theme", GTK is failing to load the cursor theme and the process exits before the window is usable. Workarounds: (1) **Prefer web:** run `flutter run -d chrome`. (2) **Fix cursor theme:** install a full cursor theme (e.g. `sudo apt install adwaita-icon-theme`) and set `export XCURSOR_THEME=Adwaita` before `flutter run -d linux`. (3) **Try without Impeller:** run `flutter run -d linux --no-enable-impeller` in case the crash is in the Impeller renderer.

### Building

```bash
# Build for web
flutter build web

# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app widget with routing
├── core/
│   ├── constants/
│   │   ├── colors.dart       # App colour palette
│   │   └── tools.dart        # Tool definitions
│   └── theme/
│       └── app_theme.dart    # Material theme
├── features/
│   ├── canvas/               # Drawing functionality
│   ├── gallery/              # Saved artworks gallery
│   ├── home/                 # Home screen
│   ├── mascot/               # Art Cat mascot system
│   └── prompts/              # Prompt generator
└── shared/
    ├── storage/              # Local storage (Hive)
    └── widgets/              # Reusable widgets
```

## Architecture

- **State Management**: Provider pattern
- **Local Storage**: Hive (no-SQL, offline-first)
- **Routing**: Named routes with MaterialApp
- **Design Pattern**: Feature-first folder structure

## Colour Palette

The app uses a warm, cat-themed colour palette:
- Primary: Warm Orange (#FF8C42)
- Secondary: Soft Purple (#9B7EDE)
- Background: Cream (#FFF8F0)

## Future Enhancements

Potential features for future versions:
- AI Art Partner with style learning
- AR Collaborative Canvas
- Monetisation Hub (digital prints, workshops)
- Discord integration
- Custom brush imports
- Membership system with premium features
- Daily page limits for non-members
- Contest system with rewards

## Licence

This project is for educational/demonstration purposes.
