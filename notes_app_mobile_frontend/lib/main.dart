import 'package:flutter/material.dart';
import 'package:notes_app_mobile_frontend/providers/auth_provider.dart';
import 'package:notes_app_mobile_frontend/providers/collection_provider.dart';
import 'package:notes_app_mobile_frontend/providers/note_provider.dart';
//import 'package:notes_app_mobile_frontend/providers/socket_provider.dart';
import 'package:notes_app_mobile_frontend/themes/themes.dart';
import 'package:notes_app_mobile_frontend/widgets/auth_gate.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        //ChangeNotifierProvider(create: (_) => SocketProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => CollectionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Notes',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: AuthGate(),
    );
  }
}
