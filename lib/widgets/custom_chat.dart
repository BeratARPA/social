import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/widgets/custom_poll.dart';
import 'package:social/widgets/custom_video_player.dart';
import 'package:social/widgets/custom_voice_recorder_player.dart';

enum MessageType { text, image, video, voice, poll, gif }

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final DateTime timestamp;
  final ChatMessage? replyTo;
  final Map<String, List<String>> reactions;
  final bool isRead;
  final String? voiceDuration;
  Map<String, dynamic>? pollData;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.timestamp,
    this.replyTo,
    Map<String, List<String>>? reactions,
    this.isRead = false,
    this.voiceDuration,
    this.pollData,
  }) : reactions = reactions ?? {};
}

class CustomChat extends StatefulWidget {
  final String currentUserId;
  final List<ChatMessage>? initialMessages;

  const CustomChat({
    super.key,
    required this.currentUserId,
    this.initialMessages,
  });

  @override
  State<CustomChat> createState() => _CustomChatState();
}

class _CustomChatState extends State<CustomChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialMessages != null) {
      _messages = List.from(widget.initialMessages!);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return _buildMessageBubble(_messages[index]);
            },
          ),
        ),

        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      decoration: BoxDecoration(
        color: context.themeValue(
          light: AppColors.lightSurface,
          dark: AppColors.darkSurface,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
            ),
            onPressed: () => _showAttachmentOptions(),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Mesaj...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              minLines: 1,
              maxLines: 5,
            ),
          ),
          if (_messageController.text.trim().isEmpty) ...[
            IconButton(
              icon: Icon(
                Icons.mic,
                color: context.themeValue(
                  light: AppColors.lightText,
                  dark: AppColors.darkText,
                ),
              ),
              onPressed: () {},
            ),
          ] else
            IconButton(
              icon: Icon(
                Icons.send,
                color: context.themeValue(
                  light: AppColors.lightText,
                  dark: AppColors.darkText,
                ),
              ),
              onPressed: () {},
            ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 3,
            children: [
              _buildAttachmentOption(Icons.camera_alt, 'Kamera', () {
                Navigator.pop(context);
              }),
              _buildAttachmentOption(Icons.photo, 'Galeri', () {
                Navigator.pop(context);
              }),
              _buildAttachmentOption(Icons.video_camera_back, 'Video', () {
                Navigator.pop(context);
              }),
              _buildAttachmentOption(Icons.poll, 'Anket', () {
                Navigator.pop(context);
              }),
              _buildAttachmentOption(Icons.gif, 'Çıkartmalar', () {
                Navigator.pop(context);
              }),
              _buildAttachmentOption(Icons.location_on, 'Konum', () {
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.themeValue(
            light: AppColors.lightBackground,
            dark: AppColors.darkBackground,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderId == widget.currentUserId;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.75;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 8),
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              backgroundImage:
                  message.senderAvatar != null
                      ? NetworkImage(message.senderAvatar!)
                      : AssetImage("assets/images/app_logo.png"),
            ),
          GestureDetector(
            onLongPressStart:
                (details) =>
                    _showMessageOptions(message, details.globalPosition, isMe),
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth, minWidth: 60),
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: context.themeValue(
                  light: AppColors.lightDisabled.withValues(alpha: 0.6),
                  dark: AppColors.primary.withValues(alpha: 0.2),
                ),
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isMe ? 12 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(message),
                  if (message.reactions.isNotEmpty)
                    _buildReactions(message, maxWidth),
                  _buildMessageInfo(message, isMe),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInfo(ChatMessage message, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
            style: TextStyle(
              fontSize: 10,
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 4),
            Icon(
              message.isRead ? Icons.done_all : Icons.done,
              size: 12,
              color:
                  message.isRead
                      ? AppColors.primary
                      : context.themeValue(
                        light: AppColors.lightText,
                        dark: AppColors.darkText,
                      ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReactions(ChatMessage message, double maxWidth) {
    List<Widget> reactionWidgets = [];

    message.reactions.forEach((reaction, users) {
      reactionWidgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: context.themeValue(
              light: AppColors.lightSurface,
              dark: AppColors.darkSurface,
            ),
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(reaction, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                users.length.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      );
    });

    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ), // Maksimum genişlik sınırı
      child: Wrap(spacing: 4, runSpacing: 4, children: reactionWidgets),
    );
  }

  void _showMessageOptions(ChatMessage message, Offset position, bool isMe) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    HapticFeedback.selectionClick();

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Offset.zero & overlay.size,
      ),
      surfaceTintColor: AppColors.accent,
      shape: ShapeBorder.lerp(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
        1,
      ),
      elevation: 4,
      items: [
        PopupMenuItem(
          value: 'reply',
          child: Row(
            children: [
              Icon(Icons.reply, size: 20),
              SizedBox(width: 12),
              Text('Yanıtla'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'forward',
          child: Row(
            children: [
              Icon(Icons.forward, size: 20),
              SizedBox(width: 12),
              Text('İlet'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy, size: 20),
              SizedBox(width: 12),
              Text('Kopyala'),
            ],
          ),
        ),
        if (isMe) // Sadece kendi mesajlarımızda sil seçeneği
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 12),
                Text('Sil', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMessageContent(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return _buildMessageTextContent(message);
      case MessageType.image:
        return _buildMessageImageContent(message);
      case MessageType.video:
        return _buildMessageVideoContent(message);
      case MessageType.voice:
        return _buildMessageVoiceContent(message);
      case MessageType.poll:
        return _buildMessagePollContent(message);
      case MessageType.gif:
        return _buildMessageGifContent(message);
    }
  }

  Widget _buildMessageTextContent(ChatMessage message) {
    return RichText(
      text: TextSpan(
        text: message.content,
        style: TextStyle(
          color: context.themeValue(
            light: AppColors.lightText,
            dark: AppColors.darkText,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageImageContent(ChatMessage message) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.all(Radius.circular(8)),
      child: SizedBox(width: 300, child: Image.network(message.content)),
    );
  }

  Widget _buildMessageVoiceContent(ChatMessage message) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.all(Radius.circular(8)),
      child: SizedBox(
        width: 300,
        child: CustomVoiceRecorderPlayer(
          mode: VoiceWidgetMode.player,
          audioPath: message.content,
        ),
      ),
    );
  }

  Widget _buildMessagePollContent(ChatMessage message) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.all(Radius.circular(8)),
      child: SizedBox(
        width: 300,
        height: 300,
        child: CustomPoll(
          pollData: message.pollData!,
          canVote: true,
          showResults: true,
        ),
      ),
    );
  }

  Widget _buildMessageVideoContent(ChatMessage message) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.all(Radius.circular(8)),
      child: SizedBox(
        width: 300,
        height: 300,
        child: CustomVideoPlayer(
          url: message.content,
          autoPlay: false,
          sourceType: VideoSourceType.asset,
        ),
      ),
    );
  }

  Widget _buildMessageGifContent(ChatMessage message) {
    return Image.network(message.content);
  }
}
