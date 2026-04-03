import 'package:flutter/material.dart';
import 'package:notes_app_mobile_frontend/providers/auth_provider.dart';
import 'package:notes_app_mobile_frontend/providers/collection_provider.dart';
import 'package:notes_app_mobile_frontend/providers/note_provider.dart';
import 'package:notes_app_mobile_frontend/screens/collections_screen.dart';
import 'package:provider/provider.dart';

class SmartNotesDrawer extends StatelessWidget {
  const SmartNotesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final noteProvider = context.watch<NoteProvider>();
    final collectionProvider = context.watch<CollectionProvider>();

    return Drawer(
      width: 300,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _DrawerHeader(
            scheme: scheme,
            authProvider: authProvider,
            noteProvider: noteProvider,
            collectionProvider: collectionProvider,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 0),
              children: [
                _SectionLabel('Library'),
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Collections',
                  description: 'Browse all folders',
                  iconBg: scheme.primaryContainer,
                  iconColor: scheme.onPrimary,
                  badge: collectionProvider.collections.length.toString(),
                  badgeColor: scheme.primary,
                  badgeFg: scheme.onPrimary,
                  //isActive: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CollectionsScreen(),
                      ),
                    );
                  },
                ),
                const _Divider(),
                _NavItem(
                  icon: Icons.archive_outlined,
                  label: 'Archived',
                  description: 'Hidden from home',
                  iconBg: const Color(0xFFFAEEDA),
                  iconColor: const Color(0xFF854F0B),
                  badge: noteProvider.archivedNotes.length.toString(),
                  badgeColor: const Color(0xFF854F0B),
                  badgeFg: Colors.white,
                  onTap: () => Navigator.pop(context),
                ),
                _NavItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Trash',
                  description: 'Auto-deletes in 30d',
                  iconBg: const Color(0xFFFCEBEB),
                  iconColor: const Color(0xFFA32D2D),
                  badge: noteProvider.deletedNotes.length.toString(),
                  badgeColor: const Color(0xFFA32D2D),
                  badgeFg: Colors.white,
                  onTap: () => Navigator.pop(context),
                ),
                const _Divider(),
                _SectionLabel('Preferences'),
                _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  description: 'Theme, sync & more',
                  iconBg: scheme.surfaceContainerHighest,
                  iconColor: scheme.onSurfaceVariant,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          _DrawerFooter(scheme: scheme),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.scheme,
    required this.authProvider,
    required this.noteProvider,
    required this.collectionProvider,
  });
  final ColorScheme scheme;
  final AuthProvider authProvider;
  final NoteProvider noteProvider;
  final CollectionProvider collectionProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withOpacity(0.4),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Container(
                //   width: 6,
                //   height: 6,
                //   decoration: BoxDecoration(
                //     color: scheme.onPrimary,
                //     shape: BoxShape.circle,
                //   ),
                // ),
                // const SizedBox(width: 6),
                Text(
                  'SMART NOTES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Avatar row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.primary.withOpacity(0.8), scheme.primary],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  authProvider.user?.name.substring(0, 1).toUpperCase() ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.user?.name ?? 'User Name',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      authProvider.user?.email ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          //const SizedBox(height: 14),
          // Stats row
          // Row(
          //   children: [
          //     _StatChip(
          //       value: noteProvider.notes.length.toString(),
          //       label: 'Notes',
          //       scheme: scheme,
          //     ),
          //     const SizedBox(width: 8),
          //     _StatChip(
          //       value: collectionProvider.collections.length.toString(),
          //       label: 'Collections',
          //       scheme: scheme,
          //     ),
          //     const SizedBox(width: 8),
          //     _StatChip(value: '6', label: 'Pinned', scheme: scheme),
          //   ],
          // ),
        ],
      ),
    );
  }
}

// class _StatChip extends StatelessWidget {
//   const _StatChip({
//     required this.value,
//     required this.label,
//     required this.scheme,
//   });

//   final String value;
//   final String label;
//   final ColorScheme scheme;

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         decoration: BoxDecoration(
//           color: scheme.surface,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: scheme.outlineVariant.withOpacity(0.4),
//             width: 0.5,
//           ),
//         ),
//         child: Column(
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.w600,
//                 color: scheme.onSurface,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               label.toUpperCase(),
//               style: TextStyle(
//                 fontSize: 9,
//                 fontWeight: FontWeight.w500,
//                 color: scheme.onSurfaceVariant,
//                 letterSpacing: 0.4,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ─── Nav Item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.iconBg,
    required this.iconColor,
    this.badge,
    this.badgeColor,
    this.badgeFg,
    // ignore: unused_element_parameter
    this.isActive = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color iconBg;
  final Color iconColor;
  final String? badge;
  final Color? badgeColor;
  final Color? badgeFg;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: isActive
            ? scheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                // Active indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 3,
                  height: isActive ? 22 : 0,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(width: 12),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isActive ? scheme.primary : scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor!.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: badgeColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Divider(
        height: 0.5,
        thickness: 0.5,
        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
      ),
    );
  }
}

// ─── Footer ──────────────────────────────────────────────────────────────────

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withOpacity(0.4),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Storage',
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
              Text(
                '62% · 124 MB',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: 0.62,
              minHeight: 4,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
