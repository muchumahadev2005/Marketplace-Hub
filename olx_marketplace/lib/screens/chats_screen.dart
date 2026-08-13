import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    ChatService.instance.loadChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Chats',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: ChatService.instance,
        builder: (context, _) {
          final rooms = ChatService.instance.rooms;

          if (ChatService.instance.isLoadingRooms && rooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No chats yet',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start a conversation from an ad listing details!',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.divider,
            ),
            itemBuilder: (context, index) {
              final room = rooms[index];
              final formattedTime = room.lastMessageTime != null
                  ? '${room.lastMessageTime!.hour}:${room.lastMessageTime!.minute.toString().padLeft(2, '0')}'
                  : '';

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: room.id,
                        userName: room.otherUserName,
                        productName: room.adTitle,
                      ),
                    ),
                  ).then((_) => ChatService.instance.loadChatRooms());
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.searchBarBg,
                  backgroundImage: CachedNetworkImageProvider(room.otherUserAvatar),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.otherUserName,
                        style: AppTextStyles.productTitle.copyWith(
                          fontWeight: room.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: AppTextStyles.productMeta.copyWith(
                        fontSize: 11,
                        color: room.unreadCount > 0 ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.adTitle,
                              style: AppTextStyles.productMeta.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              room.lastMessage.isNotEmpty ? room.lastMessage : 'No messages yet',
                              style: AppTextStyles.productMeta.copyWith(
                                color: room.unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                                fontWeight: room.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Product Thumbnail on right
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: room.adImageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            width: 40,
                            height: 40,
                            color: AppColors.searchBarBg,
                            child: const Icon(Icons.image, size: 18, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      if (room.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${room.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
