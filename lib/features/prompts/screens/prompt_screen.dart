import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../mascot/providers/mascot_provider.dart';
import '../../mascot/widgets/art_cat_mascot.dart';
import '../providers/prompt_provider.dart';

/// Screen for generating and managing art prompts
class PromptScreen extends StatelessWidget {
  const PromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Art Prompts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => _showFavourites(context),
            tooltip: 'Favourites',
          ),
        ],
      ),
      body: Consumer<PromptProvider>(
        builder: (context, promptProvider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Prompt card
                    _PromptCard(prompt: promptProvider.currentPrompt),
                    const SizedBox(height: 24),
                    // Word slots
                    _WordSlot(
                      label: 'Adjective',
                      word: promptProvider.currentPrompt.adjective,
                      isLocked: promptProvider.currentPrompt.adjectiveLocked,
                      onLockToggle: promptProvider.toggleAdjectiveLock,
                      onShuffle: promptProvider.shuffleAdjective,
                      onEdit: () => _editWord(
                        context,
                        'Adjective',
                        promptProvider.currentPrompt.adjective,
                        promptProvider.setAdjective,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _WordSlot(
                      label: 'Noun',
                      word: promptProvider.currentPrompt.noun,
                      isLocked: promptProvider.currentPrompt.nounLocked,
                      onLockToggle: promptProvider.toggleNounLock,
                      onShuffle: promptProvider.shuffleNoun,
                      onEdit: () => _editWord(
                        context,
                        'Noun',
                        promptProvider.currentPrompt.noun,
                        promptProvider.setNoun,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _WordSlot(
                      label: 'Verb',
                      word: promptProvider.currentPrompt.verb,
                      isLocked: promptProvider.currentPrompt.verbLocked,
                      onLockToggle: promptProvider.toggleVerbLock,
                      onShuffle: promptProvider.shuffleVerb,
                      onEdit: () => _editWord(
                        context,
                        'Verb',
                        promptProvider.currentPrompt.verb,
                        promptProvider.setVerb,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Favourite button
                        OutlinedButton.icon(
                          onPressed: promptProvider.toggleFavourite,
                          icon: Icon(
                            promptProvider.currentPrompt.isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: ArtCatColors.error,
                          ),
                          label: Text(
                            promptProvider.currentPrompt.isFavourite
                                ? 'Saved'
                                : 'Save',
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Shuffle button
                        ElevatedButton.icon(
                          onPressed: () {
                            promptProvider.shufflePrompt();
                            context
                                .read<MascotProvider>()
                                .setReaction(MascotReaction.excited);
                          },
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Shuffle All'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Start drawing button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/canvas',
                            arguments: promptProvider.currentPrompt.fullText,
                          );
                        },
                        icon: const Icon(Icons.brush),
                        label: const Text('Start Drawing'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ArtCatColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              // Art Cat mascot
              Positioned(
                right: 16,
                bottom: 16,
                child: Consumer<MascotProvider>(
                  builder: (context, mascotProvider, _) => ArtCatMascot(
                    onTap: () {
                      mascotProvider.showContextualTooltip('prompts');
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editWord(
    BuildContext context,
    String label,
    String currentValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter a $label',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFavourites(BuildContext context) {
    final promptProvider = context.read<PromptProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: ArtCatColors.error),
                    const SizedBox(width: 8),
                    const Text(
                      'Favourite Prompts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: promptProvider.favourites.isEmpty
                      ? const Center(
                          child: Text(
                            'No favourites yet!\nTap the heart to save prompts.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: ArtCatColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: promptProvider.favourites.length,
                          itemBuilder: (context, index) {
                            final prompt = promptProvider.favourites[index];
                            return ListTile(
                              title: Text(prompt.fullText),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward),
                                    onPressed: () {
                                      promptProvider.loadPrompt(prompt);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: ArtCatColors.error,
                                    ),
                                    onPressed: () {
                                      promptProvider.removeFavourite(prompt.id);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final dynamic prompt;

  const _PromptCard({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ArtCatColors.primary, ArtCatColors.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ArtCatColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '✨ Your Prompt ✨',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            prompt.fullText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WordSlot extends StatelessWidget {
  final String label;
  final String word;
  final bool isLocked;
  final VoidCallback onLockToggle;
  final VoidCallback onShuffle;
  final VoidCallback onEdit;

  const _WordSlot({
    required this.label,
    required this.word,
    required this.isLocked,
    required this.onLockToggle,
    required this.onShuffle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLocked ? ArtCatColors.surfaceVariant : ArtCatColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked ? ArtCatColors.primary : Colors.grey.shade300,
          width: isLocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Lock button
          IconButton(
            icon: Icon(
              isLocked ? Icons.lock : Icons.lock_open,
              color: isLocked ? ArtCatColors.primary : ArtCatColors.textLight,
            ),
            onPressed: onLockToggle,
            tooltip: isLocked ? 'Unlock' : 'Lock',
          ),
          // Label and word
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ArtCatColors.textLight,
                  ),
                ),
                GestureDetector(
                  onTap: onEdit,
                  child: Text(
                    word,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ArtCatColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Shuffle button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLocked ? null : onShuffle,
            tooltip: 'Shuffle',
          ),
        ],
      ),
    );
  }
}
