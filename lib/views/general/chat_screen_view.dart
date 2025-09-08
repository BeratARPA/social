import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_appbar.dart';
import 'package:social/widgets/custom_profile.dart';

class ChatScreenView extends StatefulWidget {
  const ChatScreenView({super.key});

  @override
  State<ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  late final ChatController _chatController;

  @override
  void initState() {
    super.initState();
    _chatController = ChatController(
      initialMessageList: [
        Message(
          id: '1',
          message: "Selam 👋",
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          sentBy: "1",
          status: MessageStatus.read,
        ),
        Message(
          id: '1',
          message: "Merhaba! Nasılsın?",
          createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
          sentBy: "2",
          status: MessageStatus.read,
        ),
        Message(
          id: '2',
          message: "Teşekkürler iyi, sen nasılsın?",
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          sentBy: "1",
          status: MessageStatus.read,
        ),
        Message(
          id: '3',
          message: "Ben de iyiyim, teşekkürler! Bugün neler yapıyorsun?",
          createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          sentBy: "2",
          status: MessageStatus.read,
        ),
        Message(
          id: '4',
          message: "Bugün işten sonra buluşalım mı?",
          createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          sentBy: "1",
          status: MessageStatus.read,
        ),
        Message(
          id: '5',
          message: "Tamam, saat 5'te görüşürüz.",
          createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          sentBy: "2",
          status: MessageStatus.read,
        ),
        Message(
          id: '6',
          message: "https://beratarpa.com/",
          createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          sentBy: "1",
          status: MessageStatus.read,
        ),
      ],
      scrollController: ScrollController(),
      currentUser: ChatUser(
        id: '1',
        name: 'Flutter User',
        profilePhoto: "assets/images/app_logo.png",
        imageType: ImageType.asset,
      ),
      otherUsers: [
        ChatUser(
          id: '2',
          name: 'İsmail Yılmaz',
          profilePhoto: "assets/images/app_logo.png",
          imageType: ImageType.asset,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) {
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      createdAt: DateTime.now(),
      sentBy: _chatController.currentUser.id,
      replyMessage: replyMessage,
      messageType: messageType,
      status: MessageStatus.read,
    );

    _chatController.addMessage(newMessage);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      showAppBar: false,
      showNavbar: false,
      body: ChatView(
        appBar: CustomAppbar(
          title: CustomProfile(
            padding: EdgeInsets.all(0),
            isVerified: true,
            displayName: "İsmail Yılmaz",
            username: "ismail.yilmaz",
            profilePicture: "assets/images/app_logo.png",
          ),
          actions: [
            /*    IconButton(
              icon: const Icon(Icons.video_camera_front_outlined),
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.call_outlined),
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
              onPressed: () {},
            ),
            */
          ],
        ),
        chatController: _chatController,
        chatViewState: ChatViewState.hasMessages,
        onSendTap: onSendTap,
        featureActiveConfig: const FeatureActiveConfig(
          enableOtherUserName: false,
          enableScrollToBottomButton: true,
        ),
        chatBackgroundConfig: ChatBackgroundConfiguration(
          backgroundColor: context.themeValue(
            light: AppColors.lightBackground,
            dark: AppColors.darkBackground,
          ),
        ),
        sendMessageConfig: SendMessageConfiguration(
          shouldSendImageWithText: true,
          voiceRecordingConfiguration: VoiceRecordingConfiguration(
            iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
            androidOutputFormat: AndroidOutputFormat.mpeg4,
            androidEncoder: AndroidEncoder.aac,
            bitRate: 128000,
            sampleRate: 44100,
            stopIcon: Icon(Icons.stop, color: Colors.red.shade400),
            waveStyle: WaveStyle(
              showMiddleLine: false,
              waveColor: Colors.white,
              extendWaveform: true,
            ),
          ),
          textFieldBackgroundColor: context.themeValue(
            light: AppColors.lightSurface,
            dark: AppColors.darkSurface,
          ),
          textFieldConfig: TextFieldConfiguration(
            hintText: "Mesaj...",
            maxLines: 5,
            textStyle: TextStyle(
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
            ),
          ),
          sendButtonIcon: const Icon(
            Icons.send_rounded,
            color: AppColors.primary,
          ),
          replyMessageColor: AppColors.lightText,
        ),
        chatBubbleConfig: ChatBubbleConfiguration(
          inComingChatBubbleConfig: ChatBubble(
            color: Colors.grey.shade300,
            textStyle: const TextStyle(color: AppColors.lightText),
          ),
          outgoingChatBubbleConfig: ChatBubble(
            color: AppColors.primary,
            textStyle: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
