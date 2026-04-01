import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      // Navigate to your home screen
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (_) => const HomeScreen()),
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // ── Logo + Icon Block ──────────────────────────────────────
              _LogoBlock(colorScheme: colorScheme),

              const SizedBox(height: 32),

              // ── App Name ──────────────────────────────────────────────
              Text(
                'Smart Notes',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2,
                ),
              ),

              const SizedBox(height: 10),

              // ── Tagline ───────────────────────────────────────────────
              Text(
                'Think clearly. Note everything.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
              ),

              const Spacer(flex: 3),

              // ── Feature Pills ─────────────────────────────────────────
              _FeaturePills(colorScheme: colorScheme),

              const Spacer(flex: 1),

              // ── Loading Dots ──────────────────────────────────────────
              _LoadingDots(colorScheme: colorScheme),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logo Block ────────────────────────────────────────────────────────────────

class _LogoBlock extends StatelessWidget {
  final ColorScheme colorScheme;

  const _LogoBlock({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primaryContainer.withOpacity(0.25),
          ),
        ),

        // Middle ring
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primaryContainer.withOpacity(0.45),
          ),
        ),

        // Inner icon container
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.edit_note_rounded,
            color: colorScheme.onPrimary,
            size: 36,
          ),
        ),
      ],
    );
  }
}

// ── Feature Pills ─────────────────────────────────────────────────────────────

class _FeaturePills extends StatelessWidget {
  final ColorScheme colorScheme;

  const _FeaturePills({required this.colorScheme});

  static const _features = [
    (Icons.bolt_rounded, 'Fast'),
    (Icons.push_pin_rounded, 'Pinnable'),
    (Icons.archive_rounded, 'Archivable'),
    (Icons.sync_rounded, 'Synced'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: _features.map((f) {
        return _Pill(icon: f.$1, label: f.$2, colorScheme: colorScheme);
      }).toList(),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _Pill({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading Dots ──────────────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  final ColorScheme colorScheme;

  const _LoadingDots({required this.colorScheme});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> {
  int _activeDot = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (mounted) {
        setState(() => _activeDot = (_activeDot + 1) % 3);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isActive = i == _activeDot;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? widget.colorScheme.primary
                : widget.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
