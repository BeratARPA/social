import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailService {
  static final Map<String, String?> _cache = {};

  static Future<String?> getThumbnail(String videoPath) async {
    if (_cache.containsKey(videoPath)) {
      return _cache[videoPath];
    }

    try {
      final thumbnailPath =
          _isAssetPath(videoPath)
              ? await _generateFromAsset(videoPath)
              : await _generateFromUrl(videoPath);

      _cache[videoPath] = thumbnailPath;
      return thumbnailPath;
    } catch (e) {
      debugPrint('Thumbnail error ($videoPath): $e');
      _cache[videoPath] = null;
      return null;
    }
  }

  static Future<String?> _generateFromAsset(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final tempVideo = File(
        '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      await tempVideo.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: tempVideo.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 75,
      );

      await tempVideo.delete();
      return thumbnailPath;
    } catch (e) {
      debugPrint('Asset thumbnail error: $e');
      return null;
    }
  }

  static Future<String?> _generateFromUrl(String videoUrl) async {
    try {
      return await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 75,
      );
    } catch (e) {
      debugPrint('URL thumbnail error: $e');
      return null;
    }
  }

  static bool _isAssetPath(String path) {
    return path.startsWith('assets/') || !path.contains('http');
  }
}
