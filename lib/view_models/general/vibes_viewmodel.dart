import 'dart:ui';

import 'package:social/helpers/app_seed_data.dart';
import 'package:social/view_models/general/base_viewmodel.dart';
import 'package:social/widgets/custom_post_card.dart';

class VibesViewModel extends BaseViewModel {
  final String _currentUserId = '1';
  String get currentUserId => _currentUserId;

  List<PostModel> _videos = [];
  List<PostModel> get videos => _videos;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Map<String, bool> _videoLiked = {};
  Map<String, bool> _videoSaved = {};
  Map<String, bool> _userFollowed = {};

  bool isVideoLiked(String postId) => _videoLiked[postId] ?? false;
  bool isVideoSaved(String postId) => _videoSaved[postId] ?? false;
  bool isUserFollowed(String userId) => _userFollowed[userId] ?? false;

  Future<void> loadVideos() async {
    await runAsync(() async {
      // TODO: API call to get video posts
      _videos = _getVideoPostsFromSeed();
      _initializeVideoStates();
    });
  }

  Future<void> loadMoreVideos() async {
    if (!_hasMore || isLoading) return;

    await runAsync(() async {
      // TODO: API call for pagination
      final newVideos = _getMoreVideoPostsFromSeed();

      if (newVideos.isEmpty) {
        _hasMore = false;
      } else {
        _videos.addAll(newVideos);
        _initializeVideoStates();
      }
    }, showLoading: false);
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();

    if (index >= _videos.length - 2) {
      loadMoreVideos();
    }
  }

  Future<void> toggleLike(String postId) async {
    _optimisticUpdate(() {
      final post = _videos.firstWhere((v) => v.id == postId);
      final isLiked = _videoLiked[postId] ?? false;

      _videoLiked[postId] = !isLiked;
      if (!isLiked) {
        post.likeCount++;
      } else {
        post.likeCount--;
      }
    });

    try {
      // TODO: API call
    } catch (e) {
      _revertLike(postId);
      setError('Beğeni işlemi başarısız');
    }
  }

  Future<void> toggleSave(String postId) async {
    _optimisticUpdate(() {
      _videoSaved[postId] = !(_videoSaved[postId] ?? false);
    });

    try {
      // TODO: API call
    } catch (e) {
      _videoSaved[postId] = !_videoSaved[postId]!;
      notifyListeners();
      setError('Kaydetme işlemi başarısız');
    }
  }

  Future<void> toggleFollow(String userId) async {
    if (userId == _currentUserId) return;

    _optimisticUpdate(() {
      _userFollowed[userId] = !(_userFollowed[userId] ?? false);
    });

    try {
      // TODO: API call
    } catch (e) {
      _userFollowed[userId] = !_userFollowed[userId]!;
      notifyListeners();
      setError('Takip işlemi başarısız');
    }
  }

  void openComments(String postId) {
    // TODO: Navigate to comments
  }

  void openUserProfile(String userId) {
    // TODO: Navigate to profile
  }

  Future<void> shareVideo(String postId) async {
    try {
      // TODO: Share functionality
    } catch (e) {
      setError('Paylaşım başarısız');
    }
  }

  Future<void> reportVideo(String postId) async {
    try {
      // TODO: Report functionality
    } catch (e) {
      setError('Rapor gönderimi başarısız');
    }
  }

  Future<void> refreshVideos() async {
    _videos.clear();
    _currentIndex = 0;
    _hasMore = true;
    _videoLiked.clear();
    _videoSaved.clear();
    _userFollowed.clear();

    await loadVideos();
  }

  void _optimisticUpdate(VoidCallback update) {
    update();
    notifyListeners();
  }

  void _revertLike(String postId) {
    final post = _videos.firstWhere((v) => v.id == postId);
    final isLiked = _videoLiked[postId] ?? false;

    _videoLiked[postId] = !isLiked;
    if (isLiked) {
      post.likeCount++;
    } else {
      post.likeCount--;
    }
    notifyListeners();
  }

  List<PostModel> _getVideoPostsFromSeed() {
    return AppSeedData.posts
        .where(
          (post) => post.media.any((media) => media.type == MediaType.video),
        )
        .toList();
  }

  List<PostModel> _getMoreVideoPostsFromSeed() {
    // TODO: Return more videos for pagination
    return [];
  }

  void _initializeVideoStates() {
    for (final video in _videos) {
      _videoLiked[video.id] ??= false;
      _videoSaved[video.id] ??= false;
      _userFollowed[video.user.id] ??= false;
    }
  }
}
