import 'package:flutter/material.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_appbar.dart';
import 'package:social/widgets/custom_chat.dart';
import 'package:social/widgets/custom_profile.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      appBar: CustomAppbar(
        title: CustomProfile(
          displayName: "İsmail Yılmaz",
          username: "ismail_yilmaz",
          profilePicture: "assets/images/app_logo.png",
          isVerified: true,
        ),
        actions: [
          /*
          IconButton(
            icon: Icon(
              Icons.video_call,
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
            ),
            onPressed: () {
              // Video call action
            },
          ),
          IconButton(
            icon: Icon(
              Icons.call,
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
            ),
            onPressed: () {
              // Voice call action
            },
          ),
          */
        ],
      ),
      showNavbar: false,
      body: CustomChat(
        currentUserId: '1',
        initialMessages: _getInitialMessages(),
      ),
    );
  }

  // Chat Data Loading
  void _loadChatData() async {
    // Gerçek uygulamada bu veriler API'den gelecek
    // Chat bilgilerini yükle
    // Online status'u kontrol et
    // Son görülme zamanını al
  }

  // Initial Messages - Gerçek uygulamada API'den gelecek
  List<ChatMessage> _getInitialMessages() {
    return [
      ChatMessage(
        id: '1',
        content: 'Merhaba! Nasılsın? Bu bir test mesajı.',
        type: MessageType.text,
        senderId: '2',
        senderName: "İsmail Yılmaz",
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: true,
      ),
      ChatMessage(
        id: '2',
        content: 'İyiyim teşekkürler! Sen nasılsın?',
        type: MessageType.text,
        senderId: "1",
        senderName: 'Ben',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        isRead: true,
      ),
      ChatMessage(
        id: '3',
        content: 'https://avatars.githubusercontent.com/u/73759254?v=4',
        type: MessageType.image,
        senderId: '2',
        senderName: "İsmail Yılmaz",
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        reactions: {
          '👍': ['user1', 'user2'],
          '❤️': ['user3'],
        },
        isRead: true,
      ),
      ChatMessage(
        id: '4',
        content: 'path/to/voice/file.aac',
        type: MessageType.voice,
        senderId: "1",
        senderName: 'Ben',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        voiceDuration: '0:12',
        reactions: {
          '👍': ['user1', 'user2'],
          '❤️': ['user3'],
        },
        isRead: true,
      ),
      ChatMessage(
        id: '5',
        content: 'Hangi rengi tercih edersiniz?',
        type: MessageType.poll,
        senderId: '2',
        senderName: "İsmail Yılmaz",
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        pollData: {
          'question': 'Hangi rengi tercih edersiniz?',
          'options': ['Kırmızı', 'Mavi', 'Yeşil', 'Sarı'],
          'votes': [5, 8, 3, 2],
        },
        reactions: {
          '👍': ['user1', 'user2'],
          '❤️': ['user3'],
        },
        isRead: true,
      ),
      ChatMessage(
        id: '6',
        content: 'Son mesaj bu',
        type: MessageType.text,
        senderId: "1",
        senderName: 'Ben',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        reactions: {
          '👍': ['user1', 'user2'],
          '❤️': ['user3'],
        },
        isRead: true,
      ),
      ChatMessage(
        id: '7',
        content: 'assets/videos/video2.mp4',
        type: MessageType.video,
        senderId: '2',
        senderName: "İsmail Yılmaz",
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        reactions: {
          '👍': ['user1', 'user2'],
          '❤️': ['user3'],
          '😂': ['user4', 'user5', 'user6'],
          '😢': ['user7'],
          '😡': ['user1'],
          '🎉': ['user8', 'user9'],
          '😮': ['user10'],
          '🙏': ['user11'],
          '🔥': ['user12', 'user13'],
          '🚀': ['user14'],
          '💡': ['user15', 'user16'],
          '🌟': ['user17'],
          '🍀': ['user18', 'user19'],
          '🎵': ['user20'],
          '📚': ['user21', 'user22'],
        },
        isRead: true,
      ),
      ChatMessage(
        id: '8',
        content: 'Mustafa Kemal Atatürk mükemmel liderdi.',
        type: MessageType.text,
        senderId: "1",
        senderName: 'Ben',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        reactions: {
          '❤️': [
            'user1',
            'user2',
            'user3',
            'user4',
            'user5',
            'user6',
            'user7',
            'user8',
            'user9',
            'user10',
          ],
        },
        isRead: false,
      ),
    ];
  }
}
