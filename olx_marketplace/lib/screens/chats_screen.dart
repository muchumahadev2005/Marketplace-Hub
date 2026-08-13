import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import 'chat_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of mock chat threads
    final List<Map<String, dynamic>> chats = [
      {
        'id': 'chat1',
        'name': 'Ahmad Raza',
        'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&q=80',
        'productTitle': 'iPhone 14 Pro Max',
        'productImage': 'https://images.unsplash.com/photo-1574755393849-623942496936?w=100&q=80',
        'lastMessage': 'Is the price final? Can we deal at Rs 580,000?',
        'time': '10:45 AM',
        'unreadCount': 2,
      },
      {
        'id': 'chat2',
        'name': 'Sara Khan',
        'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80',
        'productTitle': 'Macbook 14',
        'productImage': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=100&q=80',
        'lastMessage': 'Yes, I can share more images of the battery health.',
        'time': 'Yesterday',
        'unreadCount': 0,
      },
      {
        'id': 'chat3',
        'name': 'Zain Malik',
        'avatar': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=100&q=80',
        'productTitle': 'Suzuki Red Dragon',
        'productImage': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=100&q=80',
        'lastMessage': 'I will come to check it tomorrow evening.',
        'time': '3 days ago',
        'unreadCount': 0,
      },
    ];

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
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.divider,
        ),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: chat['id'],
                    userName: chat['name'],
                    productName: chat['productTitle'],
                  ),
                ),
              );
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.searchBarBg,
              backgroundImage: CachedNetworkImageProvider(chat['avatar']),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    chat['name'],
                    style: AppTextStyles.productTitle.copyWith(
                      fontWeight: chat['unreadCount'] > 0 ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  chat['time'],
                  style: AppTextStyles.productMeta.copyWith(
                    fontSize: 11,
                    color: chat['unreadCount'] > 0 ? AppColors.primary : AppColors.textMuted,
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
                          chat['productTitle'],
                          style: AppTextStyles.productMeta.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          chat['lastMessage'],
                          style: AppTextStyles.productMeta.copyWith(
                            color: chat['unreadCount'] > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: chat['unreadCount'] > 0 ? FontWeight.w500 : FontWeight.normal,
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
                      imageUrl: chat['productImage'],
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (chat['unreadCount'] > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${chat['unreadCount']}',
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
      ),
    );
  }
}
