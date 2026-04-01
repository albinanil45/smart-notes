// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:notes_app_mobile_frontend/providers/auth_provider.dart';
import 'package:notes_app_mobile_frontend/providers/socket_provider.dart';
import 'package:notes_app_mobile_frontend/providers/note_provider.dart';
import 'package:notes_app_mobile_frontend/providers/collection_provider.dart';
import 'package:notes_app_mobile_frontend/screens/blocked_screen.dart';
import 'package:notes_app_mobile_frontend/screens/home_screen.dart';
import 'package:notes_app_mobile_frontend/screens/splash_screen.dart';
import 'package:notes_app_mobile_frontend/widgets/app_snackbar.dart';
import 'package:provider/provider.dart';

// Screens
import '../screens/auth/auth_screen.dart';
import '../screens/not_verified_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _initialized = false;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();

    // Run after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryInit();
    });
  }

  void _tryInit() {
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id;

    if (auth.status == AuthStatus.authenticated && userId != null) {
      // Prevent re-initializing for same user
      if (_initialized && _lastUserId == userId) return;

      _initApp(userId);
    }
  }

  Future<void> _initApp(String userId) async {
    final socketProvider = context.read<SocketProvider>();
    final noteProvider = context.read<NoteProvider>();
    final collectionProvider = context.read<CollectionProvider>();

    final startTime = DateTime.now(); // ⏱️ track start

    try {
      print("🚀 Initializing app for user: $userId");

      // 1. Connect socket
      await socketProvider.init(userId);

      // 2. Attach listeners
      noteProvider.attachSocket(socketProvider);
      collectionProvider.attachSocket(socketProvider);

      // 3. Fetch initial data
      await Future.wait([
        noteProvider.fetchNotes(),
        collectionProvider.fetchCollections(),
      ]);

      // ⏳ Ensure minimum 2 seconds splash
      final elapsed = DateTime.now().difference(startTime);
      const minDuration = Duration(seconds: 2);

      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }

      if (!mounted) return;

      setState(() {
        _initialized = true;
        _lastUserId = userId;
      });

      print("✅ App initialized successfully");
    } catch (e) {
      print("❌ Init error: $e");

      if (!mounted) return;

      AppSnackBar.show(context, message: "Initialization Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // 🔄 Try init again if auth changes (important!)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryInit();
    });

    // 🔹 Loading state
    if (auth.status == AuthStatus.initial ||
        auth.status == AuthStatus.loading) {
      return const SplashScreen();
    }

    // 🔹 Not logged in
    if (auth.status == AuthStatus.unauthenticated) {
      _initialized = false; // reset
      return const AuthScreen();
    }

    // 🔹 Email not verified
    if (auth.status == AuthStatus.unverified) {
      return NotVerifiedScreen(email: auth.user?.email ?? '');
    }

    // 🔹 Blocked user
    if (auth.status == AuthStatus.blocked) {
      return BlockedScreen();
    }

    // 🔹 Authenticated
    if (auth.status == AuthStatus.authenticated) {
      if (!_initialized) {
        return const SplashScreen();
      }

      // ✅ HOME SCREEN
      return HomeScreen();
    }

    // Fallback (should never reach)
    return const SizedBox();
  }
}
