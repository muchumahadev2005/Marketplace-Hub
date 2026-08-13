// ─────────────────────────────────────────────
//  CHAT MODELS
//  Represent chat rooms and messages from the backend.
// ─────────────────────────────────────────────

class ChatRoom {
  final String id;
  final String adId;
  final String adTitle;
  final String adImageUrl;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.adId,
    required this.adTitle,
    required this.adImageUrl,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json, String currentUserId) {
    final ad = json['ad'] as Map<String, dynamic>? ?? {};
    final buyer = json['buyer'] as Map<String, dynamic>? ?? {};
    final seller = json['seller'] as Map<String, dynamic>? ?? {};

    final buyerId = buyer['id']?.toString() ?? '';

    // "Other" user is whoever is NOT the current user
    final Map<String, dynamic> otherUser =
        buyerId == currentUserId ? seller : buyer;

    return ChatRoom(
      id: json['id']?.toString() ?? '',
      adId: ad['id']?.toString() ?? '',
      adTitle: ad['title'] ?? 'Unknown Ad',
      adImageUrl: ad['imageUrl'] ??
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=200&q=80',
      otherUserId: otherUser['id']?.toString() ?? '',
      otherUserName: otherUser['name'] ?? 'Unknown User',
      otherUserAvatar: otherUser['profileImage'] ??
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&q=80',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'].toString())
          : null,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>? ?? {};
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      roomId: json['roomId']?.toString() ?? '',
      senderId: sender['id']?.toString() ?? '',
      senderName: sender['name'] ?? '',
      content: json['content'] ?? '',
      isRead: json['read'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
