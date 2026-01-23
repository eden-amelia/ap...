import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/canvas/models/artwork.dart';
import '../../features/prompts/models/prompt.dart';

/// Local storage service using Hive
class LocalStorage {
  static const String _artworksBoxName = 'artworks';
  static const String _promptsBoxName = 'prompts';
  static const String _settingsBoxName = 'settings';

  static late Box<String> _artworksBox;
  static late Box<String> _promptsBox;
  static late Box<dynamic> _settingsBox;

  /// Initialise Hive storage
  static Future<void> init() async {
    await Hive.initFlutter();
    _artworksBox = await Hive.openBox<String>(_artworksBoxName);
    _promptsBox = await Hive.openBox<String>(_promptsBoxName);
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
  }

  // ===== ARTWORKS =====

  /// Save an artwork
  static Future<void> saveArtwork(Artwork artwork) async {
    final json = jsonEncode(artwork.toJson());
    await _artworksBox.put(artwork.id, json);
  }

  /// Get an artwork by ID
  static Artwork? getArtwork(String id) {
    final json = _artworksBox.get(id);
    if (json == null) return null;
    return Artwork.fromJson(jsonDecode(json));
  }

  /// Get all saved artworks
  static List<Artwork> getAllArtworks() {
    final artworks = <Artwork>[];
    for (final json in _artworksBox.values) {
      try {
        artworks.add(Artwork.fromJson(jsonDecode(json)));
      } catch (e) {
        // Skip malformed entries
      }
    }
    // Sort by updated date, newest first
    artworks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return artworks;
  }

  /// Delete an artwork
  static Future<void> deleteArtwork(String id) async {
    await _artworksBox.delete(id);
  }

  /// Clear all artworks
  static Future<void> clearAllArtworks() async {
    await _artworksBox.clear();
  }

  // ===== PROMPTS =====

  /// Save favourite prompts
  static Future<void> saveFavouritePrompts(List<Prompt> prompts) async {
    final jsonList = prompts.map((p) => jsonEncode(p.toJson())).toList();
    await _promptsBox.put('favourites', jsonEncode(jsonList));
  }

  /// Get favourite prompts
  static List<Prompt> getFavouritePrompts() {
    final json = _promptsBox.get('favourites');
    if (json == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(json);
      return jsonList
          .map((j) => Prompt.fromJson(jsonDecode(j as String)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ===== SETTINGS =====

  /// Get a setting value
  static T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  /// Set a setting value
  static Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  /// Check if tooltips are enabled
  static bool get tooltipsEnabled {
    return getSetting<bool>('tooltipsEnabled', defaultValue: true) ?? true;
  }

  /// Set tooltips enabled
  static Future<void> setTooltipsEnabled(bool enabled) async {
    await setSetting('tooltipsEnabled', enabled);
  }

  /// Get the last used brush size
  static double get lastBrushSize {
    return getSetting<double>('lastBrushSize', defaultValue: 4.0) ?? 4.0;
  }

  /// Set the last used brush size
  static Future<void> setLastBrushSize(double size) async {
    await setSetting('lastBrushSize', size);
  }

  /// Get the last used colour (as int value)
  static int? get lastColorValue {
    return getSetting<int>('lastColorValue');
  }

  /// Set the last used colour
  static Future<void> setLastColorValue(int value) async {
    await setSetting('lastColorValue', value);
  }

  /// Check if first launch
  static bool get isFirstLaunch {
    return getSetting<bool>('hasLaunched', defaultValue: false) != true;
  }

  /// Mark as launched
  static Future<void> markLaunched() async {
    await setSetting('hasLaunched', true);
  }
}
