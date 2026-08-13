import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import 'api_client.dart';
import 'auth_service.dart';

// ─────────────────────────────────────────────
//  CHAT SERVICE
//  Manages chat rooms and messages.
//  • getChatRooms() → GET /api/chats/rooms
//  • getOrCreateRoom(adId) → POST /api/chats/room?adId=
//  • getMessages(roomId) → GET /api/chats/rooms/{id}/messages
//  • sendMessage(roomId, content) → POST /api/chats/rooms/{id}/messages
// ─────────────────────────────────────────────

class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  static ChatService get instance => _instance;
  ChatService._internal();

  List<ChatRoom> _rooms = [];
  bool _isLoadingRooms = false;

  List<ChatRoom> get rooms => List.unmodifiable(_rooms);
  bool get isLoadingRooms => _isLoadingRooms;

  /// Fetch all chat rooms for the current user
  Future<void> loadChatRooms() async {
    if (!ApiClient.instance.hasToken) return;
    _isLoadingRooms = true;
    notifyListeners();

    try {
      final currentUserId = AuthService.instance.currentUser?.id ?? '';
      final data = await ApiClient.instance.get('/chats/rooms', auth: true);
      if (data is List) {
        _rooms = data
            .map((json) => ChatRoom.fromJson(json as Map<String, dynamic>, currentUserId))
            .toList();
      }
    } catch (e) {
      debugPrint('ChatService.loadChatRooms error: $e');
    }

    _isLoadingRooms = false;
    notifyListeners();
  }

  /// Get or create a chat room for a given ad.
  /// Returns the [ChatRoom] or null on failure.
  Future<ChatRoom?> getOrCreateRoom(String adId) async {
    if (!ApiClient.instance.hasToken) return null;
    try {
      final currentUserId = AuthService.instance.currentUser?.id ?? '';
      final data = await ApiClient.instance.post(
        '/chats/room',
        auth: true,
        queryParams: {'adId': adId},
      );
      if (data is Map<String, dynamic>) {
        return ChatRoom.fromJson(data, currentUserId);
      }
    } catch (e) {
      debugPrint('ChatService.getOrCreateRoom error: $e');
    }
    return null;
  }

  /// Fetch all messages in a room
  Future<List<ChatMessage>> getMessages(String roomId) async {
    if (!ApiClient.instance.hasToken) return [];
    try {
      final data = await ApiClient.instance.get(
        '/chats/rooms/$roomId/messages',
        auth: true,
      );
      if (data is List) {
        return data
            .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('ChatService.getMessages error: $e');
    }
    return [];
  }

  /// Send a message in a room. Returns the sent [ChatMessage] or null.
  Future<ChatMessage?> sendMessage(String roomId, String content) async {
    if (!ApiClient.instance.hasToken) return null;
    try {
      final data = await ApiClient.instance.post(
        '/chats/rooms/$roomId/messages',
        auth: true,
        body: {'content': content},
      );
      if (data is Map<String, dynamic>) {
        return ChatMessage.fromJson(data);
      }
    } catch (e) {
      debugPrint('ChatService.sendMessage error: $e');
    }
    return null;
  }

  /// Clear on logout
  void clear() {
    _rooms = [];
    notifyListeners();
  }
}
