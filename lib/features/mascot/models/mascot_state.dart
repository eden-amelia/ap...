/// Reaction states for the Art Cat mascot
enum MascotReaction {
  idle,
  happy,
  excited,
  thinking,
  celebrating,
  sleeping,
  curious,
}

/// Tooltip content for different contexts
class MascotTooltip {
  final String title;
  final String message;
  final String emoji;

  const MascotTooltip({
    required this.title,
    required this.message,
    required this.emoji,
  });
}

/// Predefined tooltips for different features
class MascotTooltips {
  MascotTooltips._();

  static const Map<String, MascotTooltip> tooltips = {
    'welcome': MascotTooltip(
      title: 'Welcome!',
      message: 'I\'m Art Cat! Tap me anytime for help.',
      emoji: '🐱',
    ),
    'canvas': MascotTooltip(
      title: 'Drawing Canvas',
      message: 'Draw with your finger or mouse! Use the tools below to change pens and colours.',
      emoji: '🎨',
    ),
    'pen': MascotTooltip(
      title: 'Pen Tool',
      message: 'Draw smooth lines! Adjust the size with the slider.',
      emoji: '✏️',
    ),
    'pencil': MascotTooltip(
      title: 'Pencil Tool',
      message: 'Softer, sketchier strokes—great for rough ideas!',
      emoji: '✒️',
    ),
    'eraser': MascotTooltip(
      title: 'Eraser',
      message: 'Oops! Use this to erase mistakes.',
      emoji: '🧹',
    ),
    'shape': MascotTooltip(
      title: 'Shapes',
      message: 'Drag to draw perfect circles, squares, and triangles!',
      emoji: '⬡',
    ),
    'fill': MascotTooltip(
      title: 'Fill Tool',
      message: 'Tap to fill enclosed areas with your selected colour.',
      emoji: '🪣',
    ),
    'undo': MascotTooltip(
      title: 'Undo & Redo',
      message: 'Made a mistake? Use undo. Two-finger tap on the canvas also undoes!',
      emoji: '↩️',
    ),
    'color': MascotTooltip(
      title: 'Colours',
      message: 'Pick your favourite colour from the palette!',
      emoji: '🌈',
    ),
    'prompts': MascotTooltip(
      title: 'Art Prompts',
      message: 'Feeling stuck? Generate random prompts for inspiration!',
      emoji: '💡',
    ),
    'gallery': MascotTooltip(
      title: 'Your Gallery',
      message: 'All your masterpieces are saved here!',
      emoji: '🖼️',
    ),
    'save': MascotTooltip(
      title: 'Saved!',
      message: 'Your artwork has been saved. Purrfect!',
      emoji: '😸',
    ),
  };

  static MascotTooltip getTooltip(String key) {
    return tooltips[key] ??
        const MascotTooltip(
          title: 'Art Cat',
          message: 'Tap a tool to get started!',
          emoji: '🐾',
        );
  }
}
