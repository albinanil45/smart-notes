// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool get isConnected => _socket?.connected ?? false;

  // ✅ Connect
  Future<void> connect() async {
    if (isConnected) return;

    final token = await _storage.read(key: 'token');

    _socket = IO.io(
      'http://192.168.31.247:5000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Socket connected: ${_socket!.id}');
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
    });

    _socket!.onConnectError((err) {
      print('⚠️ Socket connection error: $err');
    });
  }

  // ✅ Disconnect
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  // ✅ Join note room
  void joinNotes(String userId) {
    _socket?.emit('joinNotes', userId);
  }

  // ✅ Join collection room
  void joinCollections(String userId) {
    _socket?.emit('joinCollections', userId);
  }

  // ✅ Listen to note changes
  void onNoteChanged(void Function(Map<String, dynamic> data) callback) {
    _socket?.on('noteChanged', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  // ✅ Listen to collection changes
  void onCollectionChanged(void Function(Map<String, dynamic> data) callback) {
    _socket?.on('collectionChanged', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  // ✅ Remove note listener
  void offNoteChanged() {
    _socket?.off('noteChanged');
  }

  // ✅ Remove collection listener
  void offCollectionChanged() {
    _socket?.off('collectionChanged');
  }
}
