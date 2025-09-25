import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CustomCamera extends StatefulWidget {
  final Function(Uint8List? imageBytes, File? videoFile) onMediaCaptured;

  const CustomCamera({super.key, required this.onMediaCaptured});

  @override
  State<CustomCamera> createState() => _CustomCameraState();
}

class _CustomCameraState extends State<CustomCamera> {
  bool isProcessing = false;

  void _openImageEditor(String path) async {
    setState(() => isProcessing = true);

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ProImageEditor.file(
                File(path),
                callbacks: ProImageEditorCallbacks(
                  onImageEditingComplete: (Uint8List bytes) async {
                    widget.onMediaCaptured(bytes, null);
                    Navigator.pop(context);
                  },
                  onCloseEditor: (editorMode) {
                    Navigator.pop(context);
                  },
                ),
              ),
        ),
      );
    } catch (e) {
      debugPrint('Image editor error: $e');
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _openVideoEditor(String path) async {
    setState(() => isProcessing = true);

    // Video editör state değişkenleri
    bool isSeeking = false;
    TrimDurationSpan? durationSpan;
    TrimDurationSpan? tempDurationSpan;

    try {
      // Video dosyasını EditorVideo olarak oluştur
      final video = EditorVideo.file(File(path));

      // Video metadata'sını al
      final videoMetadata = await ProVideoEditor.instance.getMetadata(video);

      // VideoPlayerController'ı başlat
      final videoPlayerController = VideoPlayerController.file(File(path));
      await videoPlayerController.initialize();
      await videoPlayerController.setLooping(false);
      await videoPlayerController.setVolume(0); // Başlangıçta muted
      await videoPlayerController.pause();

      // Thumbnails oluştur
      List<ImageProvider>? thumbnails;
      try {
        var imageWidth =
            MediaQuery.sizeOf(context).width /
            10 *
            MediaQuery.devicePixelRatioOf(context);

        var thumbnailList = await ProVideoEditor.instance.getKeyFrames(
          KeyFramesConfigs(
            video: video,
            outputSize: Size.square(imageWidth),
            boxFit: ThumbnailBoxFit.cover,
            maxOutputFrames: 10,
            outputFormat: ThumbnailFormat.jpeg,
          ),
        );

        List<ImageProvider> temporaryThumbnails =
            thumbnailList.map(MemoryImage.new).toList();

        var cacheList = temporaryThumbnails.map(
          (item) => precacheImage(item, context),
        );
        await Future.wait(cacheList);
        thumbnails = temporaryThumbnails;
      } catch (e) {
        debugPrint('Thumbnail generation failed: $e');
        thumbnails = null;
      }

      // ProVideoController'ı oluştur
      final proVideoController = ProVideoController(
        videoPlayer: Center(
          child: AspectRatio(
            aspectRatio: videoPlayerController.value.size.aspectRatio,
            child: VideoPlayer(videoPlayerController),
          ),
        ),
        initialResolution: videoMetadata.resolution,
        videoDuration: videoMetadata.duration,
        fileSize: videoMetadata.fileSize,
        bitrate: videoMetadata.bitrate,
        thumbnails: thumbnails,
      );

      // Seek işlemi fonksiyonu - önce tanımla
      Future<void> seekToPosition(TrimDurationSpan span) async {
        durationSpan = span;

        if (isSeeking) {
          tempDurationSpan = span; // Store the latest seek request
          return;
        }
        isSeeking = true;

        proVideoController.pause();
        proVideoController.setPlayTime(durationSpan!.start);

        await videoPlayerController.pause();
        await videoPlayerController.seekTo(span.start);

        isSeeking = false;

        // Check if there's a pending seek request
        if (tempDurationSpan != null) {
          TrimDurationSpan nextSeek = tempDurationSpan!;
          tempDurationSpan = null; // Clear the pending seek
          await seekToPosition(nextSeek); // Process the latest request
        }
      }

      // Video duration değişim listener'ı
      void onDurationChange() {
        var totalVideoDuration = videoMetadata.duration;
        var duration = videoPlayerController.value.position;
        proVideoController.setPlayTime(duration);

        if (durationSpan != null && duration >= durationSpan!.end) {
          seekToPosition(durationSpan!);
        } else if (duration >= totalVideoDuration) {
          seekToPosition(
            TrimDurationSpan(start: Duration.zero, end: totalVideoDuration),
          );
        }
      }

      // VideoPlayerController'a listener ekle
      videoPlayerController.addListener(onDurationChange);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ProImageEditor.video(
                proVideoController,
                callbacks: ProImageEditorCallbacks(
                  onCompleteWithParameters: (parameters) async {
                    try {
                      // Video'yu render et
                      final directory = await getTemporaryDirectory();
                      final String outputPath =
                          '${directory.path}/edited_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

                      await ProVideoEditor.instance.renderVideoToFile(
                        outputPath,
                        RenderVideoModel(
                          video: video,
                          outputFormat: VideoOutputFormat.mp4,
                          // Editörden gelen parametreleri uygula
                          imageBytes:
                              parameters.layers.isNotEmpty
                                  ? parameters.image
                                  : null,
                          blur: parameters.blur,
                          colorMatrixList: [parameters.colorFiltersCombined],
                          startTime: parameters.startTime,
                          endTime: parameters.endTime,
                          transform:
                              parameters.isTransformed
                                  ? ExportTransform(
                                    width: parameters.cropWidth,
                                    height: parameters.cropHeight,
                                    rotateTurns: parameters.rotateTurns,
                                    x: parameters.cropX,
                                    y: parameters.cropY,
                                    flipX: parameters.flipX,
                                    flipY: parameters.flipY,
                                  )
                                  : null,
                          enableAudio: true,
                          bitrate: videoMetadata.bitrate,
                        ),
                      );

                      widget.onMediaCaptured(null, File(outputPath));
                      Navigator.pop(context);
                    } catch (e) {
                      debugPrint('Video rendering error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Video işleme hatası: $e')),
                      );
                    }
                  },
                  onCloseEditor: (editorMode) {
                    Navigator.pop(context);
                  },
                  videoEditorCallbacks: VideoEditorCallbacks(
                    onPause: videoPlayerController.pause,
                    onPlay: videoPlayerController.play,
                    onMuteToggle: (isMuted) {
                      videoPlayerController.setVolume(isMuted ? 0 : 100);
                    },
                    onTrimSpanUpdate: (span) {
                      if (videoPlayerController.value.isPlaying) {
                        proVideoController.pause();
                      }
                      durationSpan = span;
                      debugPrint(
                        'Trim span updated: ${span.start} - ${span.end}',
                      );
                    },
                    onTrimSpanEnd: (span) async {
                      debugPrint(
                        'Trim span ended: ${span.start} - ${span.end}',
                      );
                      await seekToPosition(span);
                    },
                  ),
                ),
                configs: ProImageEditorConfigs(
                  videoEditor: const VideoEditorConfigs(
                    initialMuted: true,
                    initialPlay: false,
                    isAudioSupported: true,
                    minTrimDuration: Duration(seconds: 1),
                    playTimeSmoothingDuration: Duration(milliseconds: 600),
                  ),
                  paintEditor: const PaintEditorConfigs(
                    // Blur ve pixelate desteklenmiyor
                    enableModePixelate: false,
                    enableModeBlur: false,
                  ),
                ),
              ),
        ),
      );

      // VideoPlayerController'ı temizle
      videoPlayerController.removeListener(onDurationChange);
      await videoPlayerController.dispose();
    } catch (e) {
      debugPrint('Video editor error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Video editör hatası: $e')));
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraAwesomeBuilder.awesome(
            saveConfig: SaveConfig.photoAndVideo(
              initialCaptureMode: CaptureMode.photo,
            ),
            onMediaTap: (mediaCapture) async {
              final String? path = mediaCapture.captureRequest.path;
              if (path == null) return;

              if (mediaCapture.isPicture) {
                _openImageEditor(path);
              } else if (mediaCapture.isVideo) {
                _openVideoEditor(path);
              }
            },
          ),
          if (isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'İşleniyor...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
