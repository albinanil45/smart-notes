import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/collection_model.dart';
import '../providers/collection_provider.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerController.forward();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<CollectionProvider>().fetchCollections();
    // });
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  // ── Palette ─────────────────────────────────────────────
  static const List<_ColorOption> _palette = [
    _ColorOption('Crimson', '#E53935'),
    _ColorOption('Coral', '#FF7043'),
    _ColorOption('Amber', '#FFB300'),
    _ColorOption('Lime', '#7CB342'),
    _ColorOption('Teal', '#00897B'),
    _ColorOption('Sky', '#039BE5'),
    _ColorOption('Indigo', '#3949AB'),
    _ColorOption('Violet', '#8E24AA'),
    _ColorOption('Rose', '#D81B60'),
    _ColorOption('Slate', '#546E7A'),
  ];

  Color? _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final s = hex.replaceAll('#', '');
      if (s.length == 6) return Color(int.parse('FF$s', radix: 16));
      if (s.length == 8) return Color(int.parse(s, radix: 16));
    } catch (_) {}
    return null;
  }

  String _formatDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  // ── Create Sheet ─────────────────────────────────────────
  void _showCreateSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateCollectionSheet(
        palette: _palette,
        parseHex: _parseHex,
        onSubmit: (name, color) async {
          await context.read<CollectionProvider>().createCollection(
            name: name,
            color: color,
          );
        },
      ),
    );
  }

  // ── Delete Sheet ─────────────────────────────────────────
  void _showDeleteSheet(CollectionModel col) {
    HapticFeedback.mediumImpact();
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              _DragHandle(),
              const SizedBox(height: 24),
              // Icon + text header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        LucideIcons.trash2,
                        color: scheme.onErrorContainer,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Collection',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '"${col.name}" will be permanently removed.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: scheme.outlineVariant),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            await context
                                .read<CollectionProvider>()
                                .deleteCollection(col.id!);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed: $e'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.error,
                          foregroundColor: scheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(LucideIcons.trash2, size: 16),
                        label: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card ─────────────────────────────────────────────────
  Widget _buildCard(CollectionModel col, int index) {
    final scheme = Theme.of(context).colorScheme;
    final accent = _parseHex(col.color);
    final hasColor = accent != null;

    final bg = hasColor
        ? accent.withOpacity(0.12)
        : scheme.surfaceContainerHigh;
    final iconBg = hasColor
        ? accent.withOpacity(0.20)
        : scheme.primaryContainer.withOpacity(0.5);
    final iconColor = hasColor ? accent : scheme.primary;
    final borderColor = hasColor
        ? accent.withOpacity(0.30)
        : scheme.outlineVariant.withOpacity(0.6);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 55),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - v)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onLongPress: () => _showDeleteSheet(col),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {},
              onLongPress: () => _showDeleteSheet(col),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            LucideIcons.folder,
                            color: iconColor,
                            size: 22,
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest.withOpacity(
                              0.6,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.chevronRight,
                            color: scheme.onSurfaceVariant,
                            size: 15,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // ── Color dot row ──
                    if (hasColor)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '#${col.color.replaceAll('#', '').toUpperCase()}',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: accent.withOpacity(0.75),
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),

                    // ── Name ──
                    Text(
                      col.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // ── Date + notes count row ──
                    Row(
                      children: [
                        Icon(
                          LucideIcons.clock3,
                          size: 11,
                          color: scheme.onSurfaceVariant.withOpacity(0.55),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            col.createdAt != null
                                ? _formatDate(col.createdAt!)
                                : '—',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant.withOpacity(
                                    0.55,
                                  ),
                                  fontSize: 10,
                                ),
                          ),
                        ),
                      ],
                    ),

                    // ── Accent bar ──
                    if (hasColor) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 1,
                          minHeight: 3,
                          backgroundColor: accent.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation(
                            accent.withOpacity(0.55),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────
  Widget _buildEmpty() {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: FadeTransition(
        opacity: _headerFade,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.folderOpen,
                size: 42,
                color: scheme.primary.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'No collections yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to create one.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Consumer<CollectionProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              // ── App bar ──
              SliverAppBar.large(
                backgroundColor: scheme.surface,
                surfaceTintColor: Colors.transparent,
                title: FadeTransition(
                  opacity: _headerFade,
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.layoutGrid,
                        size: 22,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Collections',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  if (!provider.isLoading && provider.collections.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CountBadge(
                        count: provider.collections.length,
                        scheme: scheme,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      onPressed: () =>
                          context.read<CollectionProvider>().fetchCollections(),
                      icon: Icon(
                        LucideIcons.refreshCw,
                        color: scheme.onSurfaceVariant,
                        size: 20,
                      ),
                      tooltip: 'Refresh',
                    ),
                  ),
                ],
              ),

              // ── Content ──
              if (provider.isLoading)
                SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: scheme.primary),
                  ),
                )
              else if (provider.collections.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: _buildEmpty())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildCard(provider.collections[i], i),
                      childCount: provider.collections.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.88,
                        ),
                  ),
                ),
            ],
          );
        },
      ),

      // ── FAB ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 3,
        icon: const Icon(LucideIcons.folderPlus, size: 20),
        label: const Text(
          'New Collection',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Create Collection Bottom Sheet
// ─────────────────────────────────────────────────────────────
class _CreateCollectionSheet extends StatefulWidget {
  final List<_ColorOption> palette;
  final Color? Function(String?) parseHex;
  final Future<void> Function(String name, String color) onSubmit;

  const _CreateCollectionSheet({
    required this.palette,
    required this.parseHex,
    required this.onSubmit,
  });

  @override
  State<_CreateCollectionSheet> createState() => _CreateCollectionSheetState();
}

class _CreateCollectionSheetState extends State<_CreateCollectionSheet> {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  String? _selectedColor;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a collection name.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onSubmit(name, _selectedColor ?? '');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final selectedParsed = widget.parseHex(_selectedColor);

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottom + 12),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ──
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _DragHandle(),
              ),
            ),
            const SizedBox(height: 20),

            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color:
                          selectedParsed?.withOpacity(0.18) ??
                          scheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      LucideIcons.folderPlus,
                      color: selectedParsed ?? scheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Collection',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                      ),
                      Text(
                        'Organise your notes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Name field ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _nameController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Collection name',
                  hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                  prefixIcon: Icon(
                    LucideIcons.pencil,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest,
                  errorText: _error,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: selectedParsed ?? scheme.primary,
                      width: 1.8,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 22),

            // ── Color label ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.palette,
                    size: 15,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Pick a colour  •  optional',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (_selectedColor != null) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _selectedColor = null),
                      child: Text(
                        'Clear',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: scheme.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Color swatches ──
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: widget.palette.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final opt = widget.palette[i];
                  final color = widget.parseHex(opt.hex)!;
                  final selected = _selectedColor == opt.hex;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(
                        () => _selectedColor = selected ? null : opt.hex,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: selected ? 84 : 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(14),
                        border: selected
                            ? Border.all(
                                color: scheme.onSurface.withOpacity(0.35),
                                width: 2.5,
                              )
                            : null,
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.45),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: selected
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  LucideIcons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    opt.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.white30,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: selectedParsed ?? scheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(LucideIcons.folderPlus, size: 18),
                  label: Text(
                    _loading ? 'Creating…' : 'Create Collection',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────
class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: scheme.onSurfaceVariant.withOpacity(0.28),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final ColorScheme scheme;
  const _CountBadge({required this.count, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.layers,
            size: 12,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              color: scheme.onSecondaryContainer,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorOption {
  final String name;
  final String hex;
  const _ColorOption(this.name, this.hex);
}
