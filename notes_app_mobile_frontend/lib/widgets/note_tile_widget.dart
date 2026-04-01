import 'package:flutter/material.dart';
import '../../models/note_model.dart';

class NoteTileWidget extends StatelessWidget {
  final NoteModel note;
  final String? collectionName;
  final bool isSelected;
  final bool isSelecting;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteTileWidget({
    super.key,
    required this.note,
    this.collectionName,
    required this.isSelected,
    required this.isSelecting,
    required this.onTap,
    required this.onLongPress,
  });

  Color? _noteColor(BuildContext context) {
    if (note.color.isEmpty) return null;
    try {
      final hex = note.color.replaceAll('#', '');
      final value = int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
      return Color(value);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final noteColor = _noteColor(context);

    // Tile background: note color → surfaceContainerHighest → surfaceContainer
    final tileBg =
        noteColor ??
        (isSelected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest);

    // Compute a readable foreground for tinted tiles
    final fgColor = noteColor != null
        ? ThemeData.estimateBrightnessForColor(noteColor) == Brightness.dark
              ? Colors.white
              : Colors.black87
        : colorScheme.onSurface;

    final subtextColor = noteColor != null
        ? fgColor.withOpacity(0.65)
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : noteColor != null
              ? null
              : Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.4),
                  width: 1,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Checkbox (selection mode) ───────────────
                  if (isSelecting) ...[
                    AnimatedScale(
                      scale: isSelecting ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, top: 2),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 20,
                          color: isSelected
                              ? colorScheme.surface
                              : subtextColor,
                        ),
                      ),
                    ),
                  ],

                  // ── Content ─────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            if (note.isPinnedGlobal)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.push_pin_rounded,
                                  size: 14,
                                  color: noteColor != null
                                      ? fgColor.withOpacity(0.7)
                                      : colorScheme.primary,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                note.title.isEmpty ? 'Untitled' : note.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? colorScheme.surface
                                          : fgColor,
                                    ),
                              ),
                            ),
                          ],
                        ),

                        // Content preview
                        if (note.content.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            note.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isSelected
                                      ? colorScheme.surface
                                      : subtextColor,
                                  height: 1.4,
                                ),
                          ),
                        ],

                        // Footer: collection chip + date
                        if (collectionName != null ||
                            note.collectionId != null) ...[
                          const SizedBox(height: 8),
                          _CollectionChip(
                            name: collectionName ?? 'Unknown',
                            fgColor: fgColor,
                            noteColor: noteColor,
                            colorScheme: colorScheme,
                          ),
                        ],

                        const SizedBox(height: 6),
                        Text(
                          _formatDate(note.updatedAt),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: isSelected
                                    ? colorScheme.surface
                                    : subtextColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _CollectionChip extends StatelessWidget {
  final String name;
  final Color fgColor;
  final Color? noteColor;
  final ColorScheme colorScheme;

  const _CollectionChip({
    required this.name,
    required this.fgColor,
    required this.noteColor,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final chipBg = noteColor != null
        ? fgColor.withOpacity(0.12)
        : colorScheme.secondaryContainer.withOpacity(0.7);

    final chipFg = noteColor != null
        ? fgColor.withOpacity(0.85)
        : colorScheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_outlined, size: 11, color: chipFg),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: chipFg,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
