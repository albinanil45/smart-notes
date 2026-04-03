import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_app_mobile_frontend/screens/note_screen.dart';
import 'package:notes_app_mobile_frontend/widgets/notes_list_widget.dart';
import 'package:notes_app_mobile_frontend/widgets/note_tile_widget.dart';
import 'package:notes_app_mobile_frontend/widgets/smart_notes_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../providers/collection_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> _selectedIds = {};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;
  bool _searchFocused = false;

  late AnimationController _searchAnimCtrl;
  late Animation<double> _searchExpandAnim;

  @override
  void initState() {
    super.initState();

    _searchAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _searchExpandAnim = CurvedAnimation(
      parent: _searchAnimCtrl,
      curve: Curves.easeOutCubic,
    );

    _searchFocus.addListener(() {
      setState(() => _searchFocused = _searchFocus.hasFocus);
      if (_searchFocus.hasFocus) {
        _searchAnimCtrl.forward();
      } else if (!_isSearching) {
        _searchAnimCtrl.reverse();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _searchAnimCtrl.dispose();
    super.dispose();
  }

  void _onNoteSelected(String id) {
    HapticFeedback.selectionClick();
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

  void _onSearchChanged(String value) {
    context.read<NoteProvider>().searchNotes(value);
    setState(() => _isSearching = value.trim().isNotEmpty);
    if (value.trim().isNotEmpty) {
      _searchAnimCtrl.forward();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    context.read<NoteProvider>().clearSearch();
    setState(() => _isSearching = false);
    _searchAnimCtrl.reverse();
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
    await context.read<NoteProvider>().toggleArchive(_selectedIds.first);
    _clearSelection();
  }

  Future<void> _handleTogglePin(BuildContext context) async {
    await context.read<NoteProvider>().toggleGlobalPin(_selectedIds.first);
    _clearSelection();
  }

  bool _isPinned(BuildContext context) {
    if (_selectedIds.length != 1) return false;
    final notes = context.read<NoteProvider>().notes;
    try {
      return notes.firstWhere((n) => n.id == _selectedIds.first).isPinnedGlobal;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelecting = _selectedIds.isNotEmpty;
    final isSingle = _selectedIds.length == 1;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      drawer: const SmartNotesDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Bar ──────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
                      ),
                    ),
                    const Spacer(),
                    if (isSingle)
                      IconButton(
                        tooltip: _isPinned(context) ? 'Unpin' : 'Pin',
                        icon: Icon(
                          _isPinned(context)
                              ? Icons.push_pin_rounded
                              : Icons.push_pin_outlined,
                        ),
                        onPressed: () => _handleTogglePin(context),
                      ),
                    if (isSingle)
                      IconButton(
                        tooltip: 'Archive',
                        icon: const Icon(Icons.archive_outlined),
                        onPressed: () => _handleArchive(context),
                      ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error,
                      ),
                      onPressed: () => _handleDelete(context),
                    ),
                  ] else ...[
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu_rounded),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
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
                      icon: const Icon(Icons.more_vert_rounded),
                      onPressed: () {},
                    ),
                  ],
                ],
              ),
            ),

            // ── Search Bar ───────────────────────────────────────
            if (!isSelecting)
              _SearchBar(
                controller: _searchController,
                focusNode: _searchFocus,
                isSearching: _isSearching,
                isFocused: _searchFocused,
                expandAnim: _searchExpandAnim,
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
              ),

            // ── Notes / Search Results ───────────────────────────
            Expanded(
              child: _isSearching
                  ? _SearchResultsView(onNoteSelected: _onNoteSelected)
                  : NotesListWidget(
                      selectedIds: _selectedIds,
                      onNoteSelected: _onNoteSelected,
                    ),
            ),
          ],
        ),
      ),

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

// ── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final bool isFocused;
  final Animation<double> expandAnim;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.isFocused,
    required this.expandAnim,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: AnimatedBuilder(
        animation: expandAnim,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(
                16 - (expandAnim.value * 4), // 16 → 12 when focused
              ),
              border: Border.all(
                color: isFocused || isSearching
                    ? cs.primary.withOpacity(0.6)
                    : cs.outlineVariant.withOpacity(0.5),
                width: isFocused || isSearching ? 1.5 : 1.0,
              ),
              boxShadow: isFocused || isSearching
                  ? [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // ── Search icon / animated indicator ──────────
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isSearching
                        ? Icon(
                            Icons.manage_search_rounded,
                            key: const ValueKey('active'),
                            size: 22,
                            color: cs.primary,
                          )
                        : Icon(
                            Icons.search_rounded,
                            key: const ValueKey('idle'),
                            size: 22,
                            color: isFocused
                                ? cs.primary.withOpacity(0.8)
                                : cs.onSurfaceVariant.withOpacity(0.5),
                          ),
                  ),
                ),

                const SizedBox(width: 10),

                // ── Input ──────────────────────────────────────
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: isFocused ? 'Type to search…' : 'Search notes…',
                      hintStyle: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant.withOpacity(
                          isFocused ? 0.4 : 0.5,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      isDense: true,
                    ),
                  ),
                ),

                // ── Right side: count badge or clear ──────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSearching
                      ? _SearchSuffix(
                          key: const ValueKey('suffix'),
                          controller: controller,
                          onClear: onClear,
                          cs: cs,
                          tt: tt,
                        )
                      : const SizedBox(key: ValueKey('empty'), width: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SearchSuffix extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final ColorScheme cs;
  final TextTheme tt;

  const _SearchSuffix({
    super.key,
    required this.controller,
    required this.onClear,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    final count = context.watch<NoteProvider>().searchResults.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Result count pill
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: tt.labelSmall?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        // Clear button
        IconButton(
          icon: Icon(Icons.close_rounded, size: 18, color: cs.onSurfaceVariant),
          onPressed: onClear,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }
}

// ── Search Results ───────────────────────────────────────────────────────────
class _SearchResultsView extends StatelessWidget {
  final void Function(String id) onNoteSelected;

  const _SearchResultsView({required this.onNoteSelected});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final results = provider.searchResults;
    final keyword = provider.searchKeyword;
    final cs = Theme.of(context).colorScheme;
    final collections = context.watch<CollectionProvider>().collections;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 36,
                color: cs.onSurfaceVariant.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "$keyword"',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try different keywords',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Result header ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 2),
          child: Row(
            children: [
              Text(
                '${results.length} result${results.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Divider(
                  color: cs.outlineVariant.withOpacity(0.4),
                  thickness: 1,
                ),
              ),
            ],
          ),
        ),

        // ── Tiles ──────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final note = results[index];
              final collectionName = note.collectionId != null
                  ? collections
                        .where((c) => c.id == note.collectionId)
                        .map((c) => c.name)
                        .firstOrNull
                  : null;

              return NoteTileWidget(
                note: note,
                collectionName: collectionName,
                isSelected: false,
                isSelecting: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NoteScreen(note: note)),
                  );
                },
                onLongPress: () => onNoteSelected(note.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
