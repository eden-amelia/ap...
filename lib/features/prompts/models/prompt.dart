/// Represents a creative art prompt
class Prompt {
  final String id;
  final String adjective;
  final String noun;
  final String verb;
  final bool adjectiveLocked;
  final bool nounLocked;
  final bool verbLocked;
  final bool isFavourite;

  const Prompt({
    required this.id,
    required this.adjective,
    required this.noun,
    required this.verb,
    this.adjectiveLocked = false,
    this.nounLocked = false,
    this.verbLocked = false,
    this.isFavourite = false,
  });

  /// Get the full prompt text
  String get fullText => '$adjective $noun $verb';

  /// Create a copy with modifications
  Prompt copyWith({
    String? id,
    String? adjective,
    String? noun,
    String? verb,
    bool? adjectiveLocked,
    bool? nounLocked,
    bool? verbLocked,
    bool? isFavourite,
  }) {
    return Prompt(
      id: id ?? this.id,
      adjective: adjective ?? this.adjective,
      noun: noun ?? this.noun,
      verb: verb ?? this.verb,
      adjectiveLocked: adjectiveLocked ?? this.adjectiveLocked,
      nounLocked: nounLocked ?? this.nounLocked,
      verbLocked: verbLocked ?? this.verbLocked,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adjective': adjective,
      'noun': noun,
      'verb': verb,
      'isFavourite': isFavourite,
    };
  }

  /// Create from JSON
  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['id'] as String,
      adjective: json['adjective'] as String,
      noun: json['noun'] as String,
      verb: json['verb'] as String,
      isFavourite: json['isFavourite'] as bool? ?? false,
    );
  }
}

/// Word lists for prompt generation
class PromptWords {
  PromptWords._();

  static const List<String> adjectives = [
    'Shiny',
    'Mystic',
    'Cozy',
    'Dreamy',
    'Fierce',
    'Gentle',
    'Wild',
    'Cosmic',
    'Playful',
    'Elegant',
    'Whimsical',
    'Bold',
    'Serene',
    'Magical',
    'Ancient',
    'Glowing',
    'Fluffy',
    'Sparkling',
    'Mysterious',
    'Cheerful',
    'Majestic',
    'Tiny',
    'Giant',
    'Floating',
    'Hidden',
  ];

  static const List<String> nouns = [
    'Mountain',
    'Cat',
    'Star',
    'Forest',
    'Ocean',
    'Dragon',
    'Castle',
    'Garden',
    'Robot',
    'Phoenix',
    'Island',
    'City',
    'Cloud',
    'Crystal',
    'Butterfly',
    'Moon',
    'Treehouse',
    'Volcano',
    'Unicorn',
    'Waterfall',
    'Lighthouse',
    'Mushroom',
    'Owl',
    'Rainbow',
    'Spaceship',
  ];

  static const List<String> verbs = [
    'Dancing',
    'Growing',
    'Glowing',
    'Flying',
    'Sleeping',
    'Exploring',
    'Singing',
    'Hiding',
    'Dreaming',
    'Melting',
    'Blooming',
    'Spinning',
    'Jumping',
    'Swimming',
    'Transforming',
    'Watching',
    'Celebrating',
    'Wandering',
    'Resting',
    'Playing',
    'Discovering',
    'Creating',
    'Shining',
    'Floating',
    'Laughing',
  ];
}
