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
# For web
flutter run -d chrome

# For desktop (Linux)
flutter run -d linux

# For Android (if device connected)
flutter run -d android

# For iOS (on macOS)
flutter run -d ios
```

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
