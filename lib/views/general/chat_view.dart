import 'dart:io';
import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
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
        ],
      ),
      showNavbar: false,
      body: CustomChat(
        chatId: "1",
        currentUserId: '1',
        onMessageSent: _handleMessageSent,
        initialMessages: _getInitialMessages(),
        onFileUpload: _handleFileUpload,
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
        senderAvatar: "assets/images/app_logo.png",
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        isRead: true,
      ),
      // Voice message example
      ChatMessage(
        id: '4',
        content: 'path/to/voice/file.aac',
        type: MessageType.voice,
        senderId: "1",
        senderName: 'Ben',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        voiceDuration: '0:12',
        isRead: true,
      ),
      // Poll example
      ChatMessage(
        id: '5',
        content: 'Hangi rengi tercih edersiniz?',
        type: MessageType.poll,
        senderId: '2',
        senderName: "İsmail Yılmaz",
        senderAvatar: "assets/images/app_logo.png",
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
        isRead: false,
      ),
    ];
  }

  // Message Sent Handler
  Future<void> _handleMessageSent(ChatMessage message) async {
    try {
      print('Sending message: ${message.content}');

      // Gerçek uygulamada mesajı server'a gönder
      // await ChatService.sendMessage(widget.chatId, message);

      // Real-time güncelleme için WebSocket kullan
      // _socketService.sendMessage(message);

      // Local database'e kaydet
      // await LocalDatabase.saveMessage(message);

      // Push notification gönder (backend'de)
    } catch (e) {
      print('Message send error: $e');

      // Hata durumunda kullanıcıya bildir
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mesaj gönderilemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // File Upload Handler
  Future<void> _handleFileUpload(File file, MessageType type) async {
    try {
      print('Uploading file: ${file.path}, type: $type');

      // Dosyayı server'a yükle
      // final uploadedUrl = await FileUploadService.uploadFile(file, widget.chatId);

      // Gerçek uygulamada upload progress göster
      // _showUploadProgress();

      // Upload başarılı olunca mesajın content'ini güncelle
      // message.content = uploadedUrl;
    } catch (e) {
      print('File upload error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dosya yüklenemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
