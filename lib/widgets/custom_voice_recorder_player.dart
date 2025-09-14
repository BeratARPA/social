import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';

enum VoiceWidgetMode { recorder, player }

class CustomVoiceRecorderPlayer extends StatefulWidget {
  final VoiceWidgetMode mode;
  final String? audioPath;
  final Function(String audioPath)? onRecordingComplete;
  final Function()? onRecordingDeleted;
  final Function()? onPlayStart;
  final Function()? onPlayPause;
  final Function()? onPlayComplete;
  final Color? waveColor;
  final Color? backgroundColor;
  final double? height;
  final String? placeholder;
  final bool autoSend;
  final Function(File file)? onSendRecording;
  final bool shouldStopRecording;
  final VoidCallback? onRecordingStopped;

  const CustomVoiceRecorderPlayer({
    super.key,
    required this.mode,
    this.audioPath,
    this.onRecordingComplete,
    this.onRecordingDeleted,
    this.onPlayStart,
    this.onPlayPause,
    this.onPlayComplete,
    this.waveColor,
    this.backgroundColor,
    this.height = 50,
    this.placeholder,
    this.autoSend = false,
    this.onSendRecording,
    this.shouldStopRecording = false,
    this.onRecordingStopped,
  });

  @override
  State<CustomVoiceRecorderPlayer> createState() =>
      _CustomVoiceRecorderPlayerState();
}

class _CustomVoiceRecorderPlayerState extends State<CustomVoiceRecorderPlayer> {
  late RecorderController recorderController;
  late PlayerController playerController;

  String? recordedFilePath;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isPlaying = false;
  bool isPaused = false;
  late Directory appDirectory;
  bool _previousShouldStop = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(CustomVoiceRecorderPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // shouldStopRecording parametresi değiştiğinde kayıt durdur
    if (widget.shouldStopRecording && !_previousShouldStop && isRecording) {
      _stopRecording();
    }
    _previousShouldStop = widget.shouldStopRecording;
  }

  Future<void> _initializeControllers() async {
    try {
      recorderController = RecorderController();
      playerController = PlayerController();

      if (widget.mode == VoiceWidgetMode.recorder) {
        final hasPermission = await recorderController.checkPermission();
        if (!hasPermission) {
          debugPrint('Mikrofon izni yok');
          return;
        }
        appDirectory = await getApplicationDocumentsDirectory();

        // Otomatik kayıt başlat
        await _startRecording();
      } else if (widget.mode == VoiceWidgetMode.player &&
          widget.audioPath != null) {
        await _initializePlayer();
      }

      _setupPlayerListeners();
    } catch (e) {
      debugPrint('Controller başlatma hatası: $e');
    }
  }

  Future<void> _initializePlayer() async {
    try {
      final file = File(widget.audioPath!);
      if (!await file.exists()) {
        debugPrint('Ses dosyası bulunamadı: ${widget.audioPath}');
        return;
      }
      await playerController.preparePlayer(path: widget.audioPath!);
    } catch (e) {
      debugPrint('Player başlatma hatası: $e');
    }
  }

  void _setupPlayerListeners() {
    playerController.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.isPlaying;
          isPaused = state.isPaused;
        });

        if (state.isPlaying && !isPaused) {
          widget.onPlayStart?.call();
        } else if (isPaused) {
          widget.onPlayPause?.call();
        }
      }
    });

    playerController.onCompletion.listen((duration) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          isPaused = false;
        });
        widget.onPlayComplete?.call();
      }
    });
  }

  Future<void> _startRecording() async {
    try {
      final String fileName =
          'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final String filePath = '${appDirectory.path}/$fileName';

      await recorderController.record(path: filePath);

      if (mounted) {
        setState(() {
          isRecording = true;
          recordedFilePath = filePath;
        });
      }

      debugPrint('Kayıt başlatıldı: $filePath');
    } catch (e) {
      debugPrint('Kayıt başlatma hatası: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (!isRecording) {
        debugPrint('Kayıt zaten durmuş durumda');
        return;
      }

      final path = await recorderController.stop(false);

      if (mounted) {
        setState(() {
          isRecording = false;
          isRecordingCompleted = true;
          recordedFilePath = path;
        });

        if (path != null && path.isNotEmpty) {
          final file = File(path);
          if (await file.exists()) {
            final fileSize = await file.length();
            debugPrint('Kayıt tamamlandı: $path (Boyut: $fileSize bytes)');

            // Player'ı hazırla
            await playerController.preparePlayer(path: path);

            // Callback çağır
            widget.onRecordingComplete?.call(path);
            widget.onRecordingStopped?.call();
          } else {
            debugPrint('Hata: Kayıt dosyası oluşturulamadı');
          }
        } else {
          debugPrint('Hata: Kayıt path null veya boş');
        }
      }
    } catch (e) {
      debugPrint('Kayıt durdurma hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == VoiceWidgetMode.recorder) {
      return _buildRecorderWidget();
    } else {
      return _buildPlayerWidget();
    }
  }

  Widget _buildRecorderWidget() {
    if (isRecording) {
      return AudioWaveforms(
        enableGesture: false,
        size: Size(
          MediaQuery.of(context).size.width - 100,
          widget.height ?? 20,
        ),
        recorderController: recorderController,
        waveStyle: WaveStyle(
          waveColor: widget.waveColor ?? Colors.red,
          extendWaveform: true,
          showMiddleLine: false,
          spacing: 6.0,
          backgroundColor: widget.backgroundColor ?? Colors.transparent,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
      );
    } else {
      return SizedBox(
        height: widget.height ?? 20,
        child: Center(
          child: Text(
            widget.placeholder ?? 'Kayıt hazırlanıyor...',
            style: TextStyle(
              color: context.themeValue(
                light: AppColors.lightSecondaryText,
                dark: AppColors.darkSecondaryText,
              ),
              fontSize: 12,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildPlayerWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:
            widget.backgroundColor ??
            context.themeValue(
              light: AppColors.lightSurface,
              dark: AppColors.darkSurface,
            ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _playOrPauseAudio,
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            iconSize: 20,
            color: widget.waveColor ?? AppColors.primary,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Expanded(
            child:
                widget.audioPath != null
                    ? AudioFileWaveforms(
                      playerController: playerController,
                      size: Size(200, 32),
                      enableSeekGesture: true,
                      waveformType: WaveformType.long,
                      playerWaveStyle: PlayerWaveStyle(
                        fixedWaveColor: context.themeValue(
                          light: AppColors.lightSecondaryText.withOpacity(0.3),
                          dark: AppColors.darkSecondaryText.withOpacity(0.3),
                        ),
                        liveWaveColor: widget.waveColor ?? AppColors.primary,
                      ),
                    )
                    : Center(
                      child: Text(
                        'Ses dosyası bulunamadı',
                        style: TextStyle(
                          color: context.themeValue(
                            light: AppColors.lightSecondaryText,
                            dark: AppColors.darkSecondaryText,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  void _playOrPauseAudio() async {
    try {
      if (isPlaying) {
        await playerController.pausePlayer();
      } else {
        await playerController.startPlayer();
      }
    } catch (e) {
      debugPrint('Oynatma hatası: $e');
    }
  }

  @override
  void dispose() {
    recorderController.dispose();
    playerController.dispose();
    super.dispose();
  }
}
