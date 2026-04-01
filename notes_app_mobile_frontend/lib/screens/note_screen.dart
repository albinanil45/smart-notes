import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../models/collection_model.dart';
import '../providers/note_provider.dart';
import '../providers/collection_provider.dart';

// ─── Color palette for notes ────────────────────────────────────────────────
const List<Map<String, dynamic>> kNoteColors = [
  {'label': 'Default', 'value': ''},
  {'label': 'Rose', 'value': '#FFE4E6'},
  {'label': 'Amber', 'value': '#FEF3C7'},
  {'label': 'Lime', 'value': '#ECFCCB'},
  {'label': 'Sky', 'value': '#E0F2FE'},
  {'label': 'Violet', 'value': '#EDE9FE'},
  {'label': 'Peach', 'value': '#FFEDD5'},
  {'label': 'Mint', 'value': '#D1FAE5'},
  {'label': 'Blush', 'value': '#FCE7F3'},
];

Color _hexToColor(String hex, BuildContext context) {
  if (hex.isEmpty) return Theme.of(context).colorScheme.surface;
  final buffer = StringBuffer();
  if (hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

// ─── NoteScreen ─────────────────────────────────────────────────────────────
class NoteScreen extends StatefulWidget {
  final NoteModel? note;
  final String? collectionId; // if passed, lock the collection

  const NoteScreen({super.key, this.note, this.collectionId});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> with TickerProviderStateMixin {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late FocusNode _titleFocus;
  late FocusNode _contentFocus;

  String _selectedColor = '';
  String? _selectedCollectionId;
  bool _isLocked = false; // collection locked from constructor

  NoteModel? _currentNote; // null = not yet created
  bool _isSaving = false;
  Timer? _debounce;

  // animation
  late AnimationController _fabAnim;
  late AnimationController _toolbarAnim;

  @override
  void initState() {
    super.initState();

    _currentNote = widget.note;
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _selectedColor = widget.note?.color ?? '';

    // collection logic
    if (widget.collectionId != null) {
      _selectedCollectionId = widget.collectionId;
      _isLocked = true;
    } else {
      _selectedCollectionId = widget.note?.collectionId;
    }

    _titleFocus = FocusNode();
    _contentFocus = FocusNode();

    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _toolbarAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _titleCtrl.addListener(_onChanged);
    _contentCtrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    _fabAnim.dispose();
    _toolbarAnim.dispose();
    super.dispose();
  }

  // ── Auto-save with debounce ──────────────────────────────────────────────
  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _save);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty && content.isEmpty) return;

    setState(() => _isSaving = true);

    final provider = context.read<NoteProvider>();

    try {
      if (_currentNote == null) {
        // Create new note
        await provider.createNote(
          title: title,
          content: content,
          collectionId: _selectedCollectionId,
          color: _selectedColor,
        );
        // grab the newly created note from provider
        _currentNote = provider.notes.isNotEmpty ? provider.notes.first : null;
      } else {
        // Update existing
        await provider.updateNote(_currentNote!.id, {
          'title': title,
          'content': content,
          'collectionId': _selectedCollectionId,
          'color': _selectedColor,
        });
        _currentNote = _currentNote!.copyWith(
          title: title,
          content: content,
          collectionId: _selectedCollectionId,
          color: _selectedColor,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    if (mounted) setState(() => _isSaving = false);
  }

  // ── Immediate save (for color/collection change) ─────────────────────────
  void _saveImmediate() {
    _debounce?.cancel();
    _save();
  }

  // ── Color picker bottom sheet ────────────────────────────────────────────
  void _showColorPicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ColorPickerSheet(
        selectedColor: _selectedColor,
        onSelected: (color) {
          setState(() => _selectedColor = color);
          _saveImmediate();
          Navigator.pop(context);
        },
      ),
    );
  }

  // ── Archive ──────────────────────────────────────────────────────────────
  Future<void> _toggleArchive() async {
    if (_currentNote == null) return;
    HapticFeedback.mediumImpact();
    try {
      await context.read<NoteProvider>().toggleArchive(_currentNote!.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Pin ──────────────────────────────────────────────────────────────────
  Future<void> _togglePin() async {
    if (_currentNote == null) return;
    HapticFeedback.lightImpact();
    try {
      await context.read<NoteProvider>().toggleGlobalPin(_currentNote!.id);
      setState(() {
        _currentNote = _currentNote!.copyWith(
          isPinnedGlobal: !_currentNote!.isPinnedGlobal,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────
  Future<void> _deleteNote() async {
    if (_currentNote == null) {
      Navigator.pop(context);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Move to Trash?'),
        content: const Text(
          'This note will be moved to trash and deleted after 30 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await context.read<NoteProvider>().deleteNotes([_currentNote!.id]);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bgColor = _hexToColor(_selectedColor, context);
    final isDark =
        ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark;
    final onBg = isDark ? Colors.white : cs.onSurface;

    return Scaffold(
      //backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────────────────────
            _TopBar(
              isSaving: _isSaving,
              isPinned: _currentNote?.isPinnedGlobal ?? false,
              isLocked: _isLocked,
              noteExists: _currentNote != null,
              onBack: () {
                _debounce?.cancel();
                _save().then((_) {
                  if (mounted) Navigator.pop(context);
                });
              },
              onPin: _togglePin,
              onArchive: _toggleArchive,
              onDelete: _deleteNote,
              onColorPick: _showColorPicker,
              selectedColor: _selectedColor,
              foregroundColor: onBg,
              colorScheme: cs,
            ),

            // ── Collection picker ─────────────────────────────────────────
            Consumer<CollectionProvider>(
              builder: (_, cp, __) {
                if (cp.collections.isEmpty) return const SizedBox.shrink();
                return _CollectionPicker(
                  collections: cp.collections,
                  selectedId: _selectedCollectionId,
                  isLocked: _isLocked,
                  foregroundColor: onBg,
                  colorScheme: cs,
                  onChanged: (id) {
                    setState(() => _selectedCollectionId = id);
                    _saveImmediate();
                  },
                );
              },
            ),

            // ── Title + Content ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    TextField(
                      controller: _titleCtrl,
                      focusNode: _titleFocus,
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: onBg,
                        height: 1.3,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: tt.headlineSmall?.copyWith(
                          color: onBg.withOpacity(0.35),
                          fontWeight: FontWeight.w700,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _contentFocus.requestFocus(),
                    ),

                    // Thin divider
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        color: onBg.withOpacity(0.12),
                        thickness: 1,
                        height: 1,
                      ),
                    ),

                    // Metadata row
                    _MetaRow(note: _currentNote, foregroundColor: onBg),

                    const SizedBox(height: 16),

                    // Content field
                    TextField(
                      controller: _contentCtrl,
                      focusNode: _contentFocus,
                      style: tt.bodyLarge?.copyWith(
                        color: onBg,
                        height: 1.7,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Start writing…',
                        hintStyle: tt.bodyLarge?.copyWith(
                          color: onBg.withOpacity(0.35),
                          height: 1.7,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isSaving;
  final bool isPinned;
  final bool isLocked;
  final bool noteExists;
  final VoidCallback onBack;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onColorPick;
  final String selectedColor;
  final Color foregroundColor;
  final ColorScheme colorScheme;

  const _TopBar({
    required this.isSaving,
    required this.isPinned,
    required this.isLocked,
    required this.noteExists,
    required this.onBack,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
    required this.onColorPick,
    required this.selectedColor,
    required this.foregroundColor,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Back
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: foregroundColor,
            ),
            onPressed: onBack,
            tooltip: 'Back',
          ),

          const Spacer(),

          // Saving indicator
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isSaving
                ? Padding(
                    key: const ValueKey('saving'),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: foregroundColor.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Saving',
                          style: TextStyle(
                            fontSize: 12,
                            color: foregroundColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('idle')),
          ),

          // Color picker button
          _ColorDot(
            color: selectedColor,
            foregroundColor: foregroundColor,
            onTap: onColorPick,
          ),

          // Pin
          if (noteExists)
            IconButton(
              icon: Icon(
                isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                size: 20,
                color: isPinned ? colorScheme.primary : foregroundColor,
              ),
              onPressed: onPin,
              tooltip: isPinned ? 'Unpin' : 'Pin',
            ),

          // More options
          if (noteExists)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: foregroundColor,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (val) {
                if (val == 'archive') onArchive();
                if (val == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: const [
                      Icon(Icons.archive_outlined, size: 18),
                      SizedBox(width: 12),
                      Text('Archive'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Delete',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Color Dot (top bar) ──────────────────────────────────────────────────────
class _ColorDot extends StatelessWidget {
  final String color;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.isEmpty
              ? cs.surfaceContainerHighest
              : _hexToColor(color, context),
          border: Border.all(
            color: foregroundColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: color.isEmpty
            ? Icon(
                Icons.palette_outlined,
                size: 14,
                color: foregroundColor.withOpacity(0.6),
              )
            : null,
      ),
    );
  }
}

// ─── Collection Picker ────────────────────────────────────────────────────────
class _CollectionPicker extends StatelessWidget {
  final List<CollectionModel> collections;
  final String? selectedId;
  final bool isLocked;
  final Color foregroundColor;
  final ColorScheme colorScheme;
  final ValueChanged<String?> onChanged;

  const _CollectionPicker({
    required this.collections,
    required this.selectedId,
    required this.isLocked,
    required this.foregroundColor,
    required this.colorScheme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedId != null
        ? collections.firstWhere(
            (c) => c.id == selectedId,
            orElse: () => collections.first,
          )
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Icon(
            isLocked ? Icons.folder_rounded : Icons.folder_outlined,
            size: 16,
            color: foregroundColor.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          if (isLocked)
            // Locked — just show the name
            Text(
              selected?.name ?? 'Collection',
              style: TextStyle(
                fontSize: 13,
                color: foregroundColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            )
          else
            // Dropdown
            DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedId,
                isDense: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: foregroundColor.withOpacity(0.5),
                ),
                style: TextStyle(
                  fontSize: 13,
                  color: foregroundColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                hint: Text(
                  'No collection',
                  style: TextStyle(
                    fontSize: 13,
                    color: foregroundColor.withOpacity(0.4),
                  ),
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'No collection',
                      style: TextStyle(color: foregroundColor.withOpacity(0.5)),
                    ),
                  ),
                  ...collections.map(
                    (c) => DropdownMenuItem<String?>(
                      value: c.id,
                      child: Row(
                        children: [
                          if (c.color.isNotEmpty) ...[
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _hexToColor(c.color, context),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(c.name),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: onChanged,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Meta Row (timestamps) ────────────────────────────────────────────────────
class _MetaRow extends StatelessWidget {
  final NoteModel? note;
  final Color foregroundColor;

  const _MetaRow({required this.note, required this.foregroundColor});

  String _fmt(DateTime? dt) {
    if (dt == null) return 'Now';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.schedule_rounded,
          size: 13,
          color: foregroundColor.withOpacity(0.4),
        ),
        const SizedBox(width: 4),
        Text(
          note == null ? 'New note' : 'Edited ${_fmt(note!.updatedAt)}',
          style: TextStyle(
            fontSize: 12,
            color: foregroundColor.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}

// ─── Color Picker Bottom Sheet ────────────────────────────────────────────────
class _ColorPickerSheet extends StatelessWidget {
  final String selectedColor;
  final ValueChanged<String> onSelected;

  const _ColorPickerSheet({
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Note Color',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          // Color grid — each item is circle + label stacked together
          Wrap(
            spacing: 12,
            runSpacing: 16,
            children: kNoteColors.map((c) {
              final value = c['value'] as String;
              final isSelected = value == selectedColor;
              final bgColor = value.isEmpty
                  ? cs.surfaceContainerHighest
                  : _hexToColor(value, context);

              return GestureDetector(
                onTap: () => onSelected(value),
                child: SizedBox(
                  width: 52,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: bgColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? cs.primary
                                : cs.outline.withOpacity(0.3),
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: cs.primary.withOpacity(0.25),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                size: 22,
                                color: cs.primary,
                              )
                            : (value.isEmpty
                                  ? Icon(
                                      Icons.block_rounded,
                                      size: 16,
                                      color: cs.onSurfaceVariant.withOpacity(
                                        0.4,
                                      ),
                                    )
                                  : null),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        c['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: cs.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
