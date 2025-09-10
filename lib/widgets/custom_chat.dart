import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/widgets/custom_poll.dart';
import 'package:social/widgets/custom_video_player.dart';
import 'package:social/widgets/custom_voice_recorder_player.dart';

class CustomChat extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final Function(ChatMessage)? onMessageSent;
  final List<ChatMessage>? initialMessages;
  final Function(File file, MessageType type)? onFileUpload;
  final Function()? onPlayStart;
  final Function()? onPlayPause;
  final Function()? onPlayComplete;

  const CustomChat({
    super.key,
    required this.chatId,
    required this.currentUserId,
    this.onMessageSent,
    this.initialMessages,
    this.onFileUpload,
    this.onPlayStart,
    this.onPlayPause,
    this.onPlayComplete,
  });

  @override
  State<CustomChat> createState() => _CustomChatState();
}

class _CustomChatState extends State<CustomChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<ChatMessage> _messages = [];
  ChatMessage? _replyingTo;

  // Ses kayıt için state değişkenleri
  bool _isRecording = false;
  bool _isRecordingCompleted = false;
  String? _recordedFilePath;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  bool _shouldStopRecording = false; // Yeni state

  // Media handling
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessages != null) {
      _messages = List.from(widget.initialMessages!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.themeValue(
        light: AppColors.lightBackground,
        dark: AppColors.darkBackground,
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(_messages[index]);
              },
            ),
          ),
          if (_replyingTo != null) _buildReplyPreview(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isMe = message.senderId == widget.currentUserId;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.75;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _buildAvatar(message.senderAvatar),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth, minWidth: 60),
              child: GestureDetector(
                onLongPress: () => _showMessageOptions(message),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isMe
                            ? AppColors.primary.withOpacity(0.1)
                            : context.themeValue(
                              light: AppColors.lightSurface,
                              dark: AppColors.darkSurface,
                            ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    border: Border.all(
                      color: context.themeValue(
                        light: AppColors.lightBorder,
                        dark: AppColors.darkBorder,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.replyTo != null)
                        _buildReplyBubble(message.replyTo!),
                      _buildMessageContent(message),
                      if (message.reactions.isNotEmpty)
                        _buildReactions(message),
                      _buildMessageInfo(message, isMe),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: context.themeValue(
              light: AppColors.lightText,
              dark: AppColors.darkText,
            ),
          ),
        );

      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImageWidget(message.content),
        );

      case MessageType.video:
        return Container(
          constraints: const BoxConstraints(maxWidth: 250, maxHeight: 200),
          child: FutureBuilder<bool>(
            future: _checkVideoExists(message.content),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingContainer();
              }

              if (snapshot.data != true) {
                return _buildErrorContainer('Video bulunamadı');
              }

              return CustomVideoPlayer(
                url: message.content,
                sourceType:
                    message.content.startsWith('http')
                        ? VideoSourceType.network
                        : VideoSourceType.asset,
                mode: VideoPlayerMode.feed,
                autoPlay: false,
                width: 250,
                height: 200,
                borderRadius: BorderRadius.circular(8),
              );
            },
          ),
        );

      case MessageType.poll:
        return SizedBox(
          width: 280,
          height: 300,
          child: CustomPoll(
            pollData: message.pollData!,
            onVote: (optionIndex) => _handlePollVote(message, optionIndex),
            canVote: true,
            showResults: true,
          ),
        );

      case MessageType.voice:
        return _buildVoiceMessage(message);

      case MessageType.gif:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message.content,
            fit: BoxFit.cover,
            width: 200,
            height: 150,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 200,
                height: 150,
                color: context.themeValue(
                  light: AppColors.lightDivider,
                  dark: AppColors.darkDivider,
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        );
    }
  }

  Future<bool> _checkVideoExists(String videoPath) async {
    if (videoPath.startsWith('http')) {
      return true;
    } else {
      final file = File(videoPath);
      return await file.exists();
    }
  }

  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _buildErrorContainer('Geçersiz resim');
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: context.themeValue(
              light: AppColors.lightDivider,
              dark: AppColors.darkDivider,
            ),
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
          return _buildErrorContainer('Resim yüklenemedi');
        },
      );
    } else {
      final file = File(imageUrl);
      return FutureBuilder<bool>(
        future: file.exists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingContainer();
          }

          if (snapshot.data != true) {
            return _buildErrorContainer('Dosya bulunamadı');
          }

          return Image.file(
            file,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorContainer('Resim açılamadı');
            },
          );
        },
      );
    }
  }

  Widget _buildErrorContainer(String message) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.themeValue(
          light: AppColors.lightDivider,
          dark: AppColors.darkDivider,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 48,
            color: context.themeValue(
              light: AppColors.lightSecondaryText,
              dark: AppColors.darkSecondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: context.themeValue(
                light: AppColors.lightSecondaryText,
                dark: AppColors.darkSecondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.themeValue(
          light: AppColors.lightDivider,
          dark: AppColors.darkDivider,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildVoiceMessage(ChatMessage message) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CustomVoiceRecorderPlayer(
        mode: VoiceWidgetMode.player,
        audioPath: message.content,
        height: 50,
        waveColor: AppColors.primary,
        backgroundColor: context.themeValue(
          light: AppColors.lightSurface,
          dark: AppColors.darkSurface,
        ),
        onPlayStart: widget.onPlayStart,
        onPlayPause: widget.onPlayPause,
        onPlayComplete: widget.onPlayComplete,
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: context.themeValue(
        light: AppColors.lightDivider,
        dark: AppColors.darkDivider,
      ),
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child:
          avatarUrl == null
              ? Icon(
                Icons.person,
                color: context.themeValue(
                  light: AppColors.lightText,
                  dark: AppColors.darkText,
                ),
              )
              : null,
    );
  }

  Widget _buildReactions(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children:
            message.reactions.entries.map((entry) {
              final isMyReaction = entry.value.contains(widget.currentUserId);
              return GestureDetector(
                onTap: () => _toggleReaction(message, entry.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isMyReaction
                            ? AppColors.primary.withOpacity(0.2)
                            : context.themeValue(
                              light: AppColors.lightDivider,
                              dark: AppColors.darkDivider,
                            ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isMyReaction ? AppColors.primary : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${entry.key} ${entry.value.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isMyReaction
                              ? AppColors.primary
                              : context.themeValue(
                                light: AppColors.lightText,
                                dark: AppColors.darkText,
                              ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildReplyBubble(ChatMessage replyMessage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.themeValue(
          light: AppColors.lightDivider,
          dark: AppColors.darkDivider,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyMessage.senderName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getReplyPreviewText(replyMessage),
            style: TextStyle(
              fontSize: 12,
              color: context.themeValue(
                light: AppColors.lightSecondaryText,
                dark: AppColors.darkSecondaryText,
              ),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      color: context.themeValue(
        light: AppColors.lightDivider,
        dark: AppColors.darkDivider,
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yanıtlanıyor: ${_replyingTo!.senderName}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _getReplyPreviewText(_replyingTo!),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.themeValue(
                      light: AppColors.lightSecondaryText,
                      dark: AppColors.darkSecondaryText,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        left: 10,
        right: 10,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: context.themeValue(
          light: AppColors.lightBackground,
          dark: AppColors.darkBackground,
        ),
        border: Border(
          top: BorderSide(
            color: context.themeValue(
              light: AppColors.lightBorder,
              dark: AppColors.darkBorder,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child:
            _isRecording || _isRecordingCompleted
                ? _buildVoiceRecordingUI()
                : _buildNormalMessageUI(),
      ),
    );
  }

  Widget _buildVoiceRecordingUI() {
    return Row(
      children: [
        // İptal butonu
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.1),
          ),
          child: IconButton(
            onPressed: _cancelRecording,
            icon: const Icon(Icons.close),
            color: Colors.red,
            iconSize: 24,
          ),
        ),

        const SizedBox(width: 8),

        // Ses dalga formu veya player
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.themeValue(
                light: AppColors.lightSurface,
                dark: AppColors.darkSurface,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: _isRecording
                ? Row(
                    children: [
                      Icon(Icons.mic, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 20,
                          child: CustomVoiceRecorderPlayer(
                            mode: VoiceWidgetMode.recorder,
                            height: 20,
                            waveColor: Colors.red,
                            backgroundColor: Colors.transparent,
                            shouldStopRecording: _shouldStopRecording,
                            onRecordingComplete: (audioPath) {
                              debugPrint('Ses kaydı tamamlandı: $audioPath');
                              setState(() {
                                _recordedFilePath = audioPath;
                                _isRecordingCompleted = true;
                                _isRecording = false;
                                _shouldStopRecording = false;
                              });
                              _recordingTimer?.cancel();
                            },
                            onRecordingStopped: () {
                              setState(() {
                                _shouldStopRecording = false;
                              });
                            },
                            autoSend: false,
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(_recordingDuration),
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : _isRecordingCompleted && _recordedFilePath != null
                    ? // Ses dosyası tamamlandıktan sonra player göster
                    CustomVoiceRecorderPlayer(
                        mode: VoiceWidgetMode.player,
                        audioPath: _recordedFilePath!,
                        height: 42,
                        waveColor: AppColors.primary,
                        backgroundColor: Colors.transparent,
                        onPlayStart: () {
                          debugPrint('Kayıt oynatılmaya başlandı');
                        },
                        onPlayPause: () {
                          debugPrint('Kayıt duraklatıldı');
                        },
                        onPlayComplete: () {
                          debugPrint('Kayıt oynatması tamamlandı');
                        },
                      )
                    : Center(
                        child: Text(
                          'Ses kaydı hazırlanıyor...',
                          style: TextStyle(
                            color: context.themeValue(
                              light: AppColors.lightSecondaryText,
                              dark: AppColors.darkSecondaryText,
                            ),
                          ),
                        ),
                      ),
          ),
        ),

        const SizedBox(width: 8),

        // Gönder butonu (sadece kayıt tamamlandığında)
        if (_isRecordingCompleted && _recordedFilePath != null)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: IconButton(
              onPressed: _sendVoiceRecording,
              icon: const Icon(Icons.send),
              color: Colors.white,
              iconSize: 24,
            ),
          )
        else if (_isRecording)
          // Durdur butonu
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            child: IconButton(
              onPressed: _stopRecording,
              icon: const Icon(Icons.stop),
              color: Colors.white,
              iconSize: 24,
            ),
          ),
      ],
    );
  }

  Widget _buildNormalMessageUI() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Attachment button
        IconButton(
          icon: Icon(
            Icons.attach_file,
            color: context.themeValue(
              light: AppColors.lightText,
              dark: AppColors.darkText,
            ),
          ),
          onPressed: _showAttachmentOptions,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),

        // Text input field
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 100),
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: _replyingTo != null ? 'Yanıt yaz...' : 'Mesaj yaz...',
                hintStyle: TextStyle(
                  color: context.themeValue(
                    light: AppColors.lightSecondaryText,
                    dark: AppColors.darkSecondaryText,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: context.themeValue(
                  light: AppColors.lightSurface,
                  dark: AppColors.darkSurface,
                ),
              ),
              style: TextStyle(
                color: context.themeValue(
                  light: AppColors.lightText,
                  dark: AppColors.darkText,
                ),
              ),
              onSubmitted: (_) => _sendTextMessage(),
              textInputAction: TextInputAction.send,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Voice/Send button
        if (_messageController.text.trim().isEmpty) ...[
          GestureDetector(
            onTap: _startVoiceRecording,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 24),
            ),
          ),
        ] else ...[
          GestureDetector(
            onTap: _sendTextMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 24),
            ),
          ),
        ],
      ],
    );
  }

  // Ses kayıt metodları - Düzeltilmiş versiyon
  void _startVoiceRecording() async {
    try {
      // Keyboard'u kapat
      FocusScope.of(context).unfocus();

      setState(() {
        _isRecording = true;
        _isRecordingCompleted = false;
        _recordedFilePath = null;
        _recordingDuration = Duration.zero;
        _shouldStopRecording = false;
      });

      // Timer başlat
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration = Duration(seconds: timer.tick);
          });
        }
      });

      debugPrint('Ses kaydı başlatıldı');
    } catch (e) {
      debugPrint('Ses kaydı başlatma hatası: $e');
      _showErrorSnackBar('Ses kaydı başlatılamadı: $e');
      _resetRecordingState();
    }
  }

  void _stopRecording() async {
    try {
      _recordingTimer?.cancel();

      // Widget'a durma komutu gönder
      setState(() {
        _shouldStopRecording = true;
      });

      debugPrint('Ses kaydı durdurma komutu gönderildi');
    } catch (e) {
      debugPrint('Ses kaydı durdurma hatası: $e');
      _showErrorSnackBar('Ses kaydı durdurulamadı: $e');
      _resetRecordingState();
    }
  }

  void _cancelRecording() async {
    try {
      _recordingTimer?.cancel();

      // Dosya varsa sil
      if (_recordedFilePath != null) {
        final file = File(_recordedFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _resetRecordingState();
      debugPrint('Ses kaydı iptal edildi');
    } catch (e) {
      debugPrint('Ses kaydı iptal etme hatası: $e');
      _resetRecordingState();
    }
  }

  void _sendVoiceRecording() async {
    try {
      debugPrint('Gönderilecek ses dosyası: $_recordedFilePath');

      if (_recordedFilePath == null || _recordedFilePath!.isEmpty) {
        _showErrorSnackBar('Ses dosyası bulunamadı');
        debugPrint('Hata: _recordedFilePath null veya boş');
        return;
      }

      final file = File(_recordedFilePath!);
      if (!await file.exists()) {
        _showErrorSnackBar('Ses dosyası mevcut değil: $_recordedFilePath');
        debugPrint('Hata: Dosya mevcut değil - ${_recordedFilePath}');
        return;
      }

      // Dosya boyutunu kontrol et
      final fileSize = await file.length();
      debugPrint('Ses dosyası boyutu: $fileSize bytes');

      if (fileSize == 0) {
        _showErrorSnackBar('Ses dosyası boş');
        debugPrint('Hata: Dosya boyutu 0');
        return;
      }

      // Mesaj oluştur
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _recordedFilePath!,
        type: MessageType.voice,
        senderId: widget.currentUserId,
        senderName: 'Ben',
        timestamp: DateTime.now(),
        replyTo: _replyingTo,
        voiceDuration: _formatDuration(_recordingDuration),
      );

      setState(() {
        _messages.add(message);
        _replyingTo = null;
      });

      // Callbacks çağır
      widget.onMessageSent?.call(message);
      widget.onFileUpload?.call(file, MessageType.voice);

      _scrollToBottom();
      _resetRecordingState();

      _showSuccessSnackBar('Ses mesajı gönderildi');
      debugPrint('Ses mesajı başarıyla gönderildi: $_recordedFilePath');
    } catch (e) {
      debugPrint('Ses mesajı gönderme hatası: $e');
      _showErrorSnackBar('Ses mesajı gönderilirken hata oluştu: $e');
      _resetRecordingState();
    }
  }

  void _resetRecordingState() {
    setState(() {
      _isRecording = false;
      _isRecordingCompleted = false;
      _recordedFilePath = null;
      _recordingDuration = Duration.zero;
      _shouldStopRecording = false;
    });
    _recordingTimer?.cancel();
  }

  Widget _buildMessageInfo(ChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(message.timestamp),
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
    });

    widget.onMessageSent?.call(message);
    _scrollToBottom();
  }

  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: context.themeValue(
                light: AppColors.lightBackground,
                dark: AppColors.darkBackground,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: context.themeValue(
                        light: AppColors.lightDivider,
                        dark: AppColors.darkDivider,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.reply, color: AppColors.primary),
                    title: Text(
                      'Yanıtla',
                      style: TextStyle(
                        color: context.themeValue(
                          light: AppColors.lightText,
                          dark: AppColors.darkText,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _replyingTo = message);
                      _focusNode.requestFocus();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.emoji_emotions,
                      color: AppColors.accent,
                    ),
                    title: Text(
                      'Tepki Ver',
                      style: TextStyle(
                        color: context.themeValue(
                          light: AppColors.lightText,
                          dark: AppColors.darkText,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showReactionPicker(message);
                    },
                  ),
                  if (message.type == MessageType.text)
                    ListTile(
                      leading: Icon(Icons.copy, color: AppColors.secondary),
                      title: Text(
                        'Kopyala',
                        style: TextStyle(
                          color: context.themeValue(
                            light: AppColors.lightText,
                            dark: AppColors.darkText,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _copyMessage(message);
                      },
                    ),
                  if (message.senderId == widget.currentUserId) ...[
                    if (message.type == MessageType.text)
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.orange),
                        title: Text(
                          'Düzenle',
                          style: TextStyle(
                            color: context.themeValue(
                              light: AppColors.lightText,
                              dark: AppColors.darkText,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _editMessage(message);
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text(
                        'Sil',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _deleteMessage(message);
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
    );
  }

  void _copyMessage(ChatMessage message) {
    Clipboard.setData(ClipboardData(text: message.content));
    _showSuccessSnackBar('Mesaj kopyalandı');
  }

  void _editMessage(ChatMessage message) {
    if (message.type == MessageType.text) {
      _messageController.text = message.content;
      _focusNode.requestFocus();
    }
  }

  void _deleteMessage(ChatMessage message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: context.themeValue(
              light: AppColors.lightBackground,
              dark: AppColors.darkBackground,
            ),
            title: Text(
              'Mesajı Sil',
              style: TextStyle(
                color: context.themeValue(
                  light: AppColors.lightText,
                  dark: AppColors.darkText,
                ),
              ),
            ),
            content: Text(
              'Bu mesajı silmek istediğinizden emin misiniz?',
              style: TextStyle(
                color: context.themeValue(
                  light: AppColors.lightText,
                  dark: AppColors.darkText,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'İptal',
                  style: TextStyle(
                    color: context.themeValue(
                      light: AppColors.lightSecondaryText,
                      dark: AppColors.darkSecondaryText,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _messages.remove(message);
                  });
                  _showSuccessSnackBar('Mesaj silindi');
                },
                child: const Text('Sil', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: context.themeValue(
                light: AppColors.lightBackground,
                dark: AppColors.darkBackground,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: context.themeValue(
                        light: AppColors.lightDivider,
                        dark: AppColors.darkDivider,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildAttachmentOption(
                          icon: Icons.photo_camera,
                          label: 'Kamera',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                        _buildAttachmentOption(
                          icon: Icons.photo_library,
                          label: 'Galeri',
                          color: Colors.green,
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                        _buildAttachmentOption(
                          icon: Icons.videocam,
                          label: 'Video',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.pop(context);
                            _pickVideo();
                          },
                        ),
                        _buildAttachmentOption(
                          icon: Icons.poll,
                          label: 'Anket',
                          color: AppColors.accent,
                          onTap: () {
                            Navigator.pop(context);
                            _createPoll();
                          },
                        ),
                        _buildAttachmentOption(
                          icon: Icons.gif,
                          label: 'GIF',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.pop(context);
                            _pickGif();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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

  void _showReactionPicker(ChatMessage message) {
    final reactions = [
      '👍',
      '❤️',
      '😂',
      '😮',
      '😢',
      '😡',
      '🔥',
      '💯',
      '👏',
      '🎉',
      '🙏',
      '😎',
      '🤔',
      '😴',
      '🤩',
      '💔',
      '😇',
      '🤗',
      '🙌',
      '💪',
      '👀',
      '💤',
      '😤',
      '😱',
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: context.themeValue(
              light: AppColors.lightBackground,
              dark: AppColors.darkBackground,
            ),
            title: Text(
              'Tepki Seç',
              style: TextStyle(
                color: context.themeValue(
                  light: AppColors.lightText,
                  dark: AppColors.darkText,
                ),
              ),
            ),
            content: Wrap(
              children:
                  reactions.map((reaction) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _toggleReaction(message, reaction);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: context.themeValue(
                            light: AppColors.lightSurface,
                            dark: AppColors.darkSurface,
                          ),
                        ),
                        child: Text(
                          reaction,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _toggleReaction(ChatMessage message, String reaction) {
    setState(() {
      if (message.reactions[reaction] == null) {
        message.reactions[reaction] = [];
      }

      if (message.reactions[reaction]!.contains(widget.currentUserId)) {
        message.reactions[reaction]!.remove(widget.currentUserId);
        if (message.reactions[reaction]!.isEmpty) {
          message.reactions.remove(reaction);
        }
      } else {
        message.reactions[reaction]!.add(widget.currentUserId);
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      _showLoadingDialog('Fotoğraf seçiliyor...');

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      Navigator.of(context).pop();

      if (image != null) {
        final file = File(image.path);

        if (!await file.exists()) {
          _showErrorSnackBar('Seçilen dosya bulunamadı');
          return;
        }

        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          _showErrorSnackBar('Dosya boyutu çok büyük (max 10MB)');
          return;
        }

        _showImagePreview(file);
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print('Image pick error: $e');
      _showErrorSnackBar('Fotoğraf seçilirken hata oluştu: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      _showLoadingDialog('Video seçiliyor...');

      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      Navigator.of(context).pop();

      if (video != null) {
        final file = File(video.path);

        if (!await file.exists()) {
          _showErrorSnackBar('Seçilen video bulunamadı');
          return;
        }

        final fileSize = await file.length();
        if (fileSize > 50 * 1024 * 1024) {
          _showErrorSnackBar('Video boyutu çok büyük (max 50MB)');
          return;
        }

        _showVideoPreview(file);
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print('Video pick error: $e');
      _showErrorSnackBar('Video seçilirken hata oluştu: $e');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: context.themeValue(
              light: AppColors.lightBackground,
              dark: AppColors.darkBackground,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  message,
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
    );
  }

  Future<void> _pickGif() async {
    try {
      final gif = await GiphyGet.getGif(
        context: context,
        apiKey: 'A3GLzkuYUMXePccALGyKe4eMra2i6NNL',
        lang: GiphyLanguage.turkish,
      );

      if (gif != null) {
        _sendMediaMessage(gif.images?.original?.url ?? '', MessageType.gif);
      }
    } catch (e) {
      _showErrorSnackBar('GIF seçilirken hata oluştu: $e');
    }
  }

  void _createPoll() {
    _showPollCreationDialog();
  }

  void _showImagePreview(File imageFile) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder:
            (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  color: context.themeValue(
                    light: AppColors.lightBackground,
                    dark: AppColors.darkBackground,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.file(
                          imageFile,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.error, size: 48),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'İptal',
                              style: TextStyle(
                                color: context.themeValue(
                                  light: AppColors.lightSecondaryText,
                                  dark: AppColors.darkSecondaryText,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _sendFileMessage(imageFile, MessageType.image);
                            },
                            child: const Text('Gönder'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
    } catch (e) {
      print('Image preview error: $e');
      _showErrorSnackBar('Fotoğraf önizlemesi gösterilirken hata oluştu');
    }
  }

  void _showVideoPreview(File videoFile) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder:
            (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  color: context.themeValue(
                    light: AppColors.lightBackground,
                    dark: AppColors.darkBackground,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 300,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CustomVideoPlayer(
                          url: videoFile.path,
                          sourceType: VideoSourceType.asset,
                          mode: VideoPlayerMode.standard,
                          autoPlay: false,
                          showControls: true,
                          allowFullscreen: false,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'İptal',
                              style: TextStyle(
                                color: context.themeValue(
                                  light: AppColors.lightSecondaryText,
                                  dark: AppColors.darkSecondaryText,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _sendFileMessage(videoFile, MessageType.video);
                            },
                            child: const Text('Gönder'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
    } catch (e) {
      print('Video preview error: $e');
      _showErrorSnackBar('Video önizlemesi gösterilirken hata oluştu');
    }
  }

  void _showPollCreationDialog() {
    final questionController = TextEditingController();
    final List<TextEditingController> optionControllers = [
      TextEditingController(),
      TextEditingController(),
    ];

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  backgroundColor: context.themeValue(
                    light: AppColors.lightBackground,
                    dark: AppColors.darkBackground,
                  ),
                  title: Text(
                    'Anket Oluştur',
                    style: TextStyle(
                      color: context.themeValue(
                        light: AppColors.lightText,
                        dark: AppColors.darkText,
                      ),
                    ),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: questionController,
                          decoration: InputDecoration(
                            labelText: 'Anket Sorusu',
                            labelStyle: TextStyle(
                              color: context.themeValue(
                                light: AppColors.lightSecondaryText,
                                dark: AppColors.darkSecondaryText,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: context.themeValue(
                                  light: AppColors.lightBorder,
                                  dark: AppColors.darkBorder,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: context.themeValue(
                                  light: AppColors.lightBorder,
                                  dark: AppColors.darkBorder,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                          style: TextStyle(
                            color: context.themeValue(
                              light: AppColors.lightText,
                              dark: AppColors.darkText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...optionControllers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final controller = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                      labelText: 'Seçenek ${index + 1}',
                                      labelStyle: TextStyle(
                                        color: context.themeValue(
                                          light: AppColors.lightSecondaryText,
                                          dark: AppColors.darkSecondaryText,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: context.themeValue(
                                            light: AppColors.lightBorder,
                                            dark: AppColors.darkBorder,
                                          ),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: context.themeValue(
                                            light: AppColors.lightBorder,
                                            dark: AppColors.darkBorder,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: context.themeValue(
                                        light: AppColors.lightText,
                                        dark: AppColors.darkText,
                                      ),
                                    ),
                                  ),
                                ),
                                if (optionControllers.length > 2)
                                  IconButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        optionControllers.removeAt(index);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                        if (optionControllers.length < 5)
                          TextButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                optionControllers.add(TextEditingController());
                              });
                            },
                            icon: Icon(Icons.add, color: AppColors.primary),
                            label: Text(
                              'Seçenek Ekle',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'İptal',
                        style: TextStyle(
                          color: context.themeValue(
                            light: AppColors.lightSecondaryText,
                            dark: AppColors.darkSecondaryText,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (questionController.text.trim().isNotEmpty &&
                            optionControllers.every(
                              (c) => c.text.trim().isNotEmpty,
                            )) {
                          Navigator.pop(context);
                          _sendPollMessage(
                            questionController.text.trim(),
                            optionControllers
                                .map((c) => c.text.trim())
                                .toList(),
                          );
                        } else {
                          _showErrorSnackBar('Lütfen tüm alanları doldurun');
                        }
                      },
                      child: const Text('Oluştur'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _sendPollMessage(String question, List<String> options) {
    final pollData = {
      'question': question,
      'options': options,
      'votes': List.filled(options.length, 0),
    };

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: question,
      type: MessageType.poll,
      senderId: widget.currentUserId,
      senderName: 'You',
      timestamp: DateTime.now(),
      replyTo: _replyingTo,
      pollData: pollData,
    );

    setState(() {
      _messages.add(message);
      _replyingTo = null;
    });

    widget.onMessageSent?.call(message);
    _scrollToBottom();
  }

  void _sendFileMessage(File file, MessageType type) async {
    try {
      if (widget.onFileUpload != null) {
        await widget.onFileUpload!(file, type);
      }

      String duration = '';
      if (type == MessageType.voice) {
        duration = _formatDuration(_recordingDuration);
      }

      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: file.path,
        type: type,
        senderId: widget.currentUserId,
        senderName: 'Ben',
        timestamp: DateTime.now(),
        replyTo: _replyingTo,
        voiceDuration: type == MessageType.voice ? duration : null,
      );

      setState(() {
        _messages.add(message);
        _replyingTo = null;
      });

      widget.onMessageSent?.call(message);
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackBar('Dosya gönderilirken hata oluştu: $e');
    }
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
      _replyingTo = null;
    });

    widget.onMessageSent?.call(message);
    _scrollToBottom();
  }

  void _handlePollVote(ChatMessage message, int optionIndex) {
    if (message.pollData != null) {
      final pollData = Map<String, dynamic>.from(message.pollData!);
      final votes = List<int>.from(pollData['votes']);

      setState(() {
        votes[optionIndex]++;
        pollData['votes'] = votes;
        message.pollData = pollData;
      });

      _showSuccessSnackBar('Oyunuz kaydedildi');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

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
