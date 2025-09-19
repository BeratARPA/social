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
  final Function(File file)? onSendRecording;
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
    this.onSendRecording,
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

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.themeValue(
          light: AppColors.lightSurface,
          dark: AppColors.darkSurface,
        ),
      ),
      child:
          isRecordingCompleted
              ? Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isRecordingCompleted = false;
                        recordedFilePath = null;
                      });
                      widget.onRecordingDeleted?.call();
                    },
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                  IconButton(
                    onPressed: _playOrPauseAudio,
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: context.themeValue(
                        light: AppColors.lightText,
                        dark: AppColors.darkText,
                      ),
                    ),
                  ),
                  Expanded(
                    child: AudioFileWaveforms(
                      playerController: playerController,
                      size: Size(200, 32),
                      enableSeekGesture: true,
                      waveformType: WaveformType.long,
                      playerWaveStyle: PlayerWaveStyle(
                        fixedWaveColor: context.themeValue(
                          light: AppColors.lightSecondaryText.withValues(
                            alpha: 0.3,
                          ),
                          dark: AppColors.darkSecondaryText.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        liveWaveColor: AppColors.primary,
                      ),
                    ),
                  ),
                  if (recordedFilePath != null)
                    IconButton(
                      onPressed: () {
                        final file = File(recordedFilePath!);
                        if (file.existsSync()) {
                          widget.onSendRecording?.call(file);
                          setState(() {
                            isRecordingCompleted = false;
                            recordedFilePath = null;
                          });
                        }
                      },
                      icon: Icon(Icons.send, color: AppColors.primary),
                    ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: AudioWaveforms(
                      recorderController: recorderController,
                      size: Size(200, 32),
                      waveStyle: WaveStyle(
                        waveColor: AppColors.primary,
                        extendWaveform: true,
                        showMiddleLine: false,
                        spacing: 6,
                        waveThickness: 2,
                        middleLineThickness: 0,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _stopRecording,
                    icon: Icon(Icons.stop, color: Colors.red),
                  ),
                ],
              ),
    );
  }

  Widget _buildPlayerWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.themeValue(
          light: AppColors.lightSurface,
          dark: AppColors.darkSurface,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _playOrPauseAudio,
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
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
                          light: AppColors.lightSecondaryText.withValues(
                            alpha: 0.3,
                          ),
                          dark: AppColors.darkSecondaryText.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        liveWaveColor: AppColors.primary,
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
        if (mounted) {
          setState(() {
            isPlaying = false;
            isPaused = true;
          });
        }
        await playerController.pausePlayer();
      } else {
        // Eğer oynatma tamamlandıysa başa sar
        if (!isPlaying && !isPaused) {
          await playerController.seekTo(0);
        }
        if (mounted) {
          setState(() {
            isPlaying = true;
            isPaused = false;
          });
        }
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
