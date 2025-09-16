import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/widgets/custom_poll.dart';
import 'package:social/widgets/custom_video_player.dart';
import 'package:social/widgets/custom_voice_recorder_player.dart';

enum MessageType { text, image, video, voice, poll, gif, document }

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
  final FocusNode _focusNode = FocusNode();

  final ImagePicker _imagePicker = ImagePicker();
  List<ChatMessage> _messages = [];
  ChatMessage? _replyingTo;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessages != null) {
      _messages = List.from(widget.initialMessages!);
      _scrollToBottom();
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
        if (_replyingTo != null) _buildReplyPreview(),
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
      child:
          _isRecording
              ? Expanded(
                child: CustomVoiceRecorderPlayer(
                  mode: VoiceWidgetMode.recorder,
                  onSendRecording: (file) {
                    _sendMediaMessage(file.path, MessageType.voice);
                    setState(() {
                      _isRecording = false;
                    });
                  },
                  onRecordingDeleted: () {
                    setState(() {
                      _isRecording = false;
                    });
                  },
                ),
              )
              : Row(
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
                      focusNode: _focusNode,
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
                      onChanged: (value) => setState(() {}),
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
                      onPressed: () {
                        setState(() {
                          _isRecording = true;
                        });
                      },
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
                      onPressed: () => _sendTextMessage(),
                    ),
                ],
              ),
    );
  }

  Widget _buildReplyPreview() {
    if (_replyingTo == null) return SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.themeValue(
          light: AppColors.lightDisabled.withValues(alpha: 0.3),
          dark: AppColors.darkDisabled.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _replyingTo!.senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.themeValue(
                      light: AppColors.lightText,
                      dark: AppColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getReplyPreviewText(_replyingTo!),
                  style: TextStyle(
                    color: context.themeValue(
                      light: AppColors.lightText,
                      dark: AppColors.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                _replyingTo = null;
              });
            },
          ),
        ],
      ),
    );
  }

  void _sendTextMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _messageController.text.trim(),
      type: MessageType.text,
      senderId: widget.currentUserId,
      senderName: 'Ben',
      timestamp: DateTime.now(),
      replyTo: _replyingTo,
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
      _replyingTo = null;
      _scrollToBottom();
    });
  }

  void _sendMediaMessage(String url, MessageType type) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: url,
      type: type,
      senderId: widget.currentUserId,
      senderName: 'Ben',
      timestamp: DateTime.now(),
      replyTo: _replyingTo,
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
      _replyingTo = null;
      _scrollToBottom();
    });
  }

  void _sendPollMessage(Map<String, dynamic> pollData) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: pollData['question'],
      type: MessageType.poll,
      senderId: widget.currentUserId,
      senderName: 'Ben',
      timestamp: DateTime.now(),
      replyTo: _replyingTo,
      pollData: pollData,
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
      _replyingTo = null;
      _scrollToBottom();
    });
  }

  void _createPoll() {
    final TextEditingController questionController = TextEditingController();
    final List<TextEditingController> optionControllers = [
      TextEditingController(),
      TextEditingController(),
    ];

    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text("Anket Oluştur"),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: questionController,
                          decoration: InputDecoration(
                            labelText: 'Anket Sorusu',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("Seçenekler"),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: optionControllers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: TextField(
                                  controller: optionControllers[index],
                                  decoration: InputDecoration(
                                    labelText: 'Seçenek ${index + 1}',
                                    suffixIcon:
                                        index >= 2
                                            ? IconButton(
                                              icon: Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                setDialogState(() {
                                                  optionControllers.removeAt(
                                                    index,
                                                  );
                                                });
                                              },
                                            )
                                            : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (optionControllers.length < 5)
                          TextButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('Seçenek Ekle'),
                            onPressed: () {
                              setDialogState(() {
                                optionControllers.add(TextEditingController());
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Kapat"),
                    ),
                    TextButton(
                      onPressed: () {
                        if (questionController.text.trim().isEmpty ||
                            optionControllers.any(
                              (controller) => controller.text.trim().isEmpty,
                            ) ||
                            optionControllers.length < 2) {
                          return;
                        }
                        Navigator.pop(context);
                        _sendPollMessage({
                          'question': questionController.text.trim(),
                          'options':
                              optionControllers
                                  .map((controller) => controller.text.trim())
                                  .toList(),
                          'votes': List.filled(optionControllers.length, 0),
                        });
                      },
                      child: Text("Oluştur"),
                    ),
                  ],
                ),
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
                _pickImage(ImageSource.camera);
              }),
              _buildAttachmentOption(Icons.photo, 'Galeri', () {
                _pickImage(ImageSource.gallery);
              }),
              _buildAttachmentOption(Icons.video_camera_back, 'Video', () {
                _pickVideo(ImageSource.gallery);
              }),
              _buildAttachmentOption(Icons.poll, 'Anket', () {
                _createPoll();
              }),
              _buildAttachmentOption(Icons.gif, 'Çıkartmalar', () {
                _pickGif();
              }),
              _buildAttachmentOption(Icons.insert_drive_file, 'Belge', () {
                _pickDocument();
              }),
            ],
          ),
        );
      },
    );
  }

  void _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'],
    );

    if (result != null && result.files.isNotEmpty) {
      Navigator.pop(context);

      final file = result.files.first;
      _sendMediaMessage(file.path!, MessageType.document);
    }
  }

  void _pickGif() async {
    final gif = await GiphyGet.getGif(
      context: context,
      apiKey: 'A3GLzkuYUMXePccALGyKe4eMra2i6NNL',
      lang: GiphyLanguage.turkish,
    );

    if (gif != null) {
      Navigator.pop(context);

      _sendMediaMessage(gif.images?.original?.url ?? '', MessageType.gif);
    }
  }

  void _pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (image != null) {
      final file = File(image.path);
      if (!await file.exists()) {
        return;
      }

      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        return;
      }

      Navigator.pop(context);

      _sendMediaMessage(file.path, MessageType.image);
    }
  }

  void _pickVideo(ImageSource source) async {
    final XFile? video = await _imagePicker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 5),
    );

    if (video != null) {
      final file = File(video.path);
      if (!await file.exists()) {
        return;
      }

      final fileSize = await file.length();
      if (fileSize > 50 * 1024 * 1024) {
        return;
      }

      Navigator.pop(context);

      _sendMediaMessage(file.path, MessageType.video);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 300,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
            onDoubleTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (message.reactions.containsKey('❤️')) {
                  if (message.reactions['❤️']!.contains(widget.currentUserId)) {
                    message.reactions['❤️']!.remove(widget.currentUserId);
                    if (message.reactions['❤️']!.isEmpty) {
                      message.reactions.remove('❤️');
                    }
                  } else {
                    message.reactions.putIfAbsent('❤️', () => []);
                    message.reactions['❤️']!.add(widget.currentUserId);
                  }
                } else {
                  message.reactions['❤️'] = [widget.currentUserId];
                }
              });
            },
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
                  if (message.replyTo != null)
                    _buildMessageReplyContent(message.replyTo),
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

  Widget _buildMessageReplyContent(ChatMessage? replyTo) {
    if (replyTo == null) return SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.themeValue(
          light: AppColors.lightDisabled.withValues(alpha: 0.1),
          dark: AppColors.darkDisabled.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyTo.senderName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getReplyPreviewText(replyTo),
            style: TextStyle(
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getReplyPreviewText(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return message.content;
      case MessageType.image:
        return '📷 Fotoğraf';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.voice:
        return '🎤 Ses mesajı';
      case MessageType.poll:
        return '📊 ${message.pollData?['question'] ?? 'Anket'}';
      case MessageType.gif:
        return '🎞️ GIF';
      case MessageType.document:
        return '📄 ${message.content.split('/').last}';
    }
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
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (message.reactions.containsKey(reaction)) {
                if (message.reactions[reaction]!.contains(
                  widget.currentUserId,
                )) {
                  message.reactions[reaction]!.remove(widget.currentUserId);
                  if (message.reactions[reaction]!.isEmpty) {
                    message.reactions.remove(reaction);
                  }
                } else {
                  message.reactions.putIfAbsent(reaction, () => []);
                  message.reactions[reaction]!.add(widget.currentUserId);
                }
              } else {
                message.reactions[reaction] = [widget.currentUserId];
              }
            });
          },
          child: Container(
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
      items: [
        PopupMenuItem(
          value: 'react',
          child: Row(
            children: [
              Icon(Icons.emoji_emotions, size: 20),
              SizedBox(width: 12),
              Text('Tepki Ver'),
            ],
          ),
        ),
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
        if (message.type == MessageType.text)
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
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'react':
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Tepki Seç'),
                  content: Wrap(
                    spacing: 10,
                    children:
                        ['❤️', '😂', '😮', '😢', '👍', '👎'].map((emoji) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              HapticFeedback.selectionClick();
                              setState(() {
                                if (message.reactions.containsKey(emoji)) {
                                  if (message.reactions[emoji]!.contains(
                                    widget.currentUserId,
                                  )) {
                                    message.reactions[emoji]!.remove(
                                      widget.currentUserId,
                                    );
                                    if (message.reactions[emoji]!.isEmpty) {
                                      message.reactions.remove(emoji);
                                    }
                                  } else {
                                    message.reactions.putIfAbsent(
                                      emoji,
                                      () => [],
                                    );
                                    message.reactions[emoji]!.add(
                                      widget.currentUserId,
                                    );
                                  }
                                } else {
                                  message.reactions[emoji] = [
                                    widget.currentUserId,
                                  ];
                                }
                              });
                            },
                            child: Text(emoji, style: TextStyle(fontSize: 30)),
                          );
                        }).toList(),
                  ),
                );
              },
            );
            break;
          case 'copy':
            Clipboard.setData(ClipboardData(text: message.content));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Mesaj kopyalandı')));
            break;
          case 'reply':
            setState(() {
              _replyingTo = message;
              _focusNode.requestFocus();
            });
            break;
          case 'forward':
            break;
          case 'delete':
            setState(() {
              _messages.removeWhere((m) => m.id == message.id);
            });
            break;
        }
      }
    });
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
      case MessageType.document:
        return _buildMessageDocumentContent(message);
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
      child: SizedBox(
        width: 300,
        child:
            message.content.contains("http")
                ? Image.network(
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey,
                      height: 200,
                      width: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey,
                      height: 200,
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Resim yüklenemedi',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                  message.content,
                )
                : Image.file(File(message.content)),
      ),
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
          sourceType:
              message.content.contains("http")
                  ? VideoSourceType.network
                  : VideoSourceType.asset,
        ),
      ),
    );
  }

  Widget _buildMessageGifContent(ChatMessage message) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.all(Radius.circular(8)),
      child: SizedBox(width: 300, child: Image.network(message.content)),
    );
  }

  Widget _buildMessageDocumentContent(ChatMessage message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.insert_drive_file, size: 40, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message.content.split('/').last,
            style: TextStyle(
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
              decoration: TextDecoration.underline,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 5,
          ),
        ),
      ],
    );
  }
}
