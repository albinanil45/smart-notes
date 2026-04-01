import 'package:flutter/material.dart';
import 'package:notes_app_mobile_frontend/screens/note_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/collection_provider.dart';
import '../../models/note_model.dart';
import 'note_tile_widget.dart';

class NotesListWidget extends StatelessWidget {
  final Set<String> selectedIds;
  final ValueChanged<String> onNoteSelected;

  const NotesListWidget({
    super.key,
    required this.selectedIds,
    required this.onNoteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final collectionProvider = context.watch<CollectionProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    if (noteProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    final notes = noteProvider.notes;

    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_outlined,
              size: 64,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + to create your first note',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.outlineVariant,
              ),
            ),
          ],
        ),
      );
    }

    // ── Sort: pinned first, then by updatedAt desc ────────────────
    final pinned = notes.where((n) => n.isPinnedGlobal).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final unpinned = notes.where((n) => !n.isPinnedGlobal).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return CustomScrollView(
      slivers: [
        // ── Pinned section ──────────────────────────────────────
        if (pinned.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
              child: Row(
                children: [
                  Icon(
                    Icons.push_pin_rounded,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PINNED',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final note = pinned[index];
              return NoteTileWidget(
                note: note,
                collectionName: _collectionName(note, collectionProvider),
                isSelected: selectedIds.contains(note.id),
                isSelecting: selectedIds.isNotEmpty,
                onTap: () => _handleTap(note, context),
                onLongPress: () => onNoteSelected(note.id),
              );
            }, childCount: pinned.length),
          ),
        ],

        // ── Divider between sections ────────────────────────────
        if (pinned.isNotEmpty && unpinned.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Text(
                    'OTHER NOTES',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Unpinned section ────────────────────────────────────
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final note = unpinned[index];
            return NoteTileWidget(
              note: note,
              collectionName: _collectionName(note, collectionProvider),
              isSelected: selectedIds.contains(note.id),
              isSelecting: selectedIds.isNotEmpty,
              onTap: () => _handleTap(note, context),
              onLongPress: () => onNoteSelected(note.id),
            );
          }, childCount: unpinned.length),
        ),

        // ── Bottom padding for FAB ──────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 88)),
      ],
    );
  }

  String? _collectionName(NoteModel note, CollectionProvider cp) {
    if (note.collectionId == null || note.collectionId!.isEmpty) return null;
    return cp.getById(note.collectionId!)?.name;
  }

  void _handleTap(NoteModel note, BuildContext context) {
    if (selectedIds.isNotEmpty) {
      onNoteSelected(note.id);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NoteScreen(note: note)),
      );
    }
  }
}
