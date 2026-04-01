import 'package:flutter/material.dart';
import 'package:notes_app_mobile_frontend/screens/note_screen.dart';
import 'package:notes_app_mobile_frontend/widgets/notes_list_widget.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> _selectedIds = {};

  void _onNoteSelected(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() => _selectedIds.clear());
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notes'),
        content: Text(
          'Move ${_selectedIds.length} note${_selectedIds.length > 1 ? 's' : ''} to trash?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<NoteProvider>().deleteNotes(_selectedIds.toList());
      _clearSelection();
    }
  }

  Future<void> _handleArchive(BuildContext context) async {
    final noteProvider = context.read<NoteProvider>();
    final id = _selectedIds.first;
    await noteProvider.toggleArchive(id);
    _clearSelection();
  }

  Future<void> _handleTogglePin(BuildContext context) async {
    final noteProvider = context.read<NoteProvider>();
    final id = _selectedIds.first;
    await noteProvider.toggleGlobalPin(id);
    _clearSelection();
  }

  bool _isPinned(BuildContext context) {
    if (_selectedIds.length != 1) return false;
    final notes = context.read<NoteProvider>().notes;
    final note = notes.firstWhere(
      (n) => n.id == _selectedIds.first,
      orElse: () => notes.first,
    );
    return note.isPinnedGlobal;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelecting = _selectedIds.isNotEmpty;
    final isSingle = _selectedIds.length == 1;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              // color: isSelecting
              //     ? colorScheme.secondaryContainer
              //     : colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  if (isSelecting) ...[
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _clearSelection,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_selectedIds.length} selected',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        // color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const Spacer(),
                    // Pin / Unpin — single only
                    if (isSingle)
                      IconButton(
                        tooltip: _isPinned(context) ? 'Unpin' : 'Pin',
                        icon: Icon(
                          _isPinned(context)
                              ? Icons.push_pin_rounded
                              : Icons.push_pin_outlined,
                          // color: colorScheme.onSecondaryContainer,
                        ),
                        onPressed: () => _handleTogglePin(context),
                      ),
                    // Archive — single only
                    if (isSingle)
                      IconButton(
                        tooltip: 'Archive',
                        icon: Icon(
                          Icons.archive_outlined,
                          // color: colorScheme.onSecondaryContainer,
                        ),
                        onPressed: () => _handleArchive(context),
                      ),
                    // Delete — always shown
                    IconButton(
                      tooltip: 'Delete',
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error,
                      ),
                      onPressed: () => _handleDelete(context),
                    ),
                  ] else ...[
                    const SizedBox(width: 8),
                    Text(
                      'Smart Notes',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search_rounded),
                      onPressed: () {
                        // TODO: navigate to search
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded),
                      onPressed: () {
                        // TODO: overflow menu
                      },
                    ),
                  ],
                ],
              ),
            ),

            // ── Notes List ───────────────────────────────────────
            Expanded(
              child: NotesListWidget(
                selectedIds: _selectedIds,
                onNoteSelected: _onNoteSelected,
              ),
            ),
          ],
        ),
      ),

      // ── FAB ─────────────────────────────────────────────────────
      floatingActionButton: isSelecting
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NoteScreen()),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Note'),
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
    );
  }
}
