import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/prompt.dart';

/// Manages prompt generation and favourites
class PromptProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  final _random = Random();

  Prompt _currentPrompt;
  Prompt get currentPrompt => _currentPrompt;

  final List<Prompt> _favourites = [];
  List<Prompt> get favourites => List.unmodifiable(_favourites);

  final List<Prompt> _history = [];
  List<Prompt> get history => List.unmodifiable(_history);

  PromptProvider() : _currentPrompt = _generateInitialPrompt();

  static Prompt _generateInitialPrompt() {
    final random = Random();
    return Prompt(
      id: const Uuid().v4(),
      adjective: PromptWords.adjectives[random.nextInt(PromptWords.adjectives.length)],
      noun: PromptWords.nouns[random.nextInt(PromptWords.nouns.length)],
      verb: PromptWords.verbs[random.nextInt(PromptWords.verbs.length)],
    );
  }

  /// Generate a new random prompt, respecting locked fields
  void shufflePrompt() {
    _history.add(_currentPrompt);
    if (_history.length > 20) {
      _history.removeAt(0);
    }

    _currentPrompt = Prompt(
      id: _uuid.v4(),
      adjective: _currentPrompt.adjectiveLocked
          ? _currentPrompt.adjective
          : _getRandomAdjective(),
      noun: _currentPrompt.nounLocked
          ? _currentPrompt.noun
          : _getRandomNoun(),
      verb: _currentPrompt.verbLocked
          ? _currentPrompt.verb
          : _getRandomVerb(),
      adjectiveLocked: _currentPrompt.adjectiveLocked,
      nounLocked: _currentPrompt.nounLocked,
      verbLocked: _currentPrompt.verbLocked,
    );
    notifyListeners();
  }

  /// Shuffle only the adjective
  void shuffleAdjective() {
    if (_currentPrompt.adjectiveLocked) return;
    _currentPrompt = _currentPrompt.copyWith(
      adjective: _getRandomAdjective(),
    );
    notifyListeners();
  }

  /// Shuffle only the noun
  void shuffleNoun() {
    if (_currentPrompt.nounLocked) return;
    _currentPrompt = _currentPrompt.copyWith(
      noun: _getRandomNoun(),
    );
    notifyListeners();
  }

  /// Shuffle only the verb
  void shuffleVerb() {
    if (_currentPrompt.verbLocked) return;
    _currentPrompt = _currentPrompt.copyWith(
      verb: _getRandomVerb(),
    );
    notifyListeners();
  }

  /// Toggle lock on adjective
  void toggleAdjectiveLock() {
    _currentPrompt = _currentPrompt.copyWith(
      adjectiveLocked: !_currentPrompt.adjectiveLocked,
    );
    notifyListeners();
  }

  /// Toggle lock on noun
  void toggleNounLock() {
    _currentPrompt = _currentPrompt.copyWith(
      nounLocked: !_currentPrompt.nounLocked,
    );
    notifyListeners();
  }

  /// Toggle lock on verb
  void toggleVerbLock() {
    _currentPrompt = _currentPrompt.copyWith(
      verbLocked: !_currentPrompt.verbLocked,
    );
    notifyListeners();
  }

  /// Add current prompt to favourites
  void toggleFavourite() {
    final isFav = _favourites.any((p) => p.id == _currentPrompt.id);
    if (isFav) {
      _favourites.removeWhere((p) => p.id == _currentPrompt.id);
      _currentPrompt = _currentPrompt.copyWith(isFavourite: false);
    } else {
      _currentPrompt = _currentPrompt.copyWith(isFavourite: true);
      _favourites.add(_currentPrompt);
    }
    notifyListeners();
  }

  /// Remove a prompt from favourites
  void removeFavourite(String id) {
    _favourites.removeWhere((p) => p.id == id);
    if (_currentPrompt.id == id) {
      _currentPrompt = _currentPrompt.copyWith(isFavourite: false);
    }
    notifyListeners();
  }

  /// Load a prompt from history or favourites
  void loadPrompt(Prompt prompt) {
    _currentPrompt = prompt.copyWith(
      adjectiveLocked: false,
      nounLocked: false,
      verbLocked: false,
    );
    notifyListeners();
  }

  /// Set a custom word for a field
  void setAdjective(String adjective) {
    _currentPrompt = _currentPrompt.copyWith(adjective: adjective);
    notifyListeners();
  }

  void setNoun(String noun) {
    _currentPrompt = _currentPrompt.copyWith(noun: noun);
    notifyListeners();
  }

  void setVerb(String verb) {
    _currentPrompt = _currentPrompt.copyWith(verb: verb);
    notifyListeners();
  }

  String _getRandomAdjective() {
    return PromptWords.adjectives[_random.nextInt(PromptWords.adjectives.length)];
  }

  String _getRandomNoun() {
    return PromptWords.nouns[_random.nextInt(PromptWords.nouns.length)];
  }

  String _getRandomVerb() {
    return PromptWords.verbs[_random.nextInt(PromptWords.verbs.length)];
  }
}
