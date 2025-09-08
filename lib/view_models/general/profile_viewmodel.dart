import 'package:social/helpers/app_seed_data.dart';
import 'package:social/view_models/general/base_viewmodel.dart';
import 'package:social/widgets/post_card.dart';

class ProfileViewModel extends BaseViewModel {
  // Current user
  final String _currentUserId = '1';
  String get currentUserId => _currentUserId;

  // Profile data
  UserModel? _profileUser;
  UserModel? get profileUser => _profileUser;

  List<PostModel> _userPosts = [];
  List<PostModel> get userPosts => _userPosts;

  String? _bio;
  String? get bio => _bio;

  // Profile states
  bool _isOwnProfile = false;
  bool get isOwnProfile => _isOwnProfile;

  bool _isFollowing = false;
  bool get isFollowing => _isFollowing;

  bool _isBlocked = false;
  bool get isBlocked => _isBlocked;

  bool _isPrivate = false;
  bool get isPrivate => _isPrivate;

  // Stats
  int _followerCount = 1000000;
  int get followerCount => _followerCount;

  int _followingCount = 1000;
  int get followingCount => _followingCount;

  // Filtered posts
  List<PostModel> get imagePosts =>
      _userPosts
          .where(
            (post) => post.media.any((media) => media.type == MediaType.image),
          )
          .toList();

  List<PostModel> get videoPosts =>
      _userPosts
          .where(
            (post) => post.media.any((media) => media.type == MediaType.video),
          )
          .toList();

  List<PostModel> get pollPosts =>
      _userPosts
          .where(
            (post) => post.media.any((media) => media.type == MediaType.poll),
          )
          .toList();

  List<PostModel> get textPosts =>
      _userPosts
          .where(
            (post) =>
                post.media.isEmpty ||
                !post.media.any(
                  (media) => [
                    MediaType.image,
                    MediaType.video,
                    MediaType.poll,
                  ].contains(media.type),
                ),
          )
          .toList();

  // Load profile data
  Future<void> loadProfile({String? userId, UserModel? user}) async {
    await runAsync(() async {
      // Determine target user
      if (user != null) {
        _profileUser = user;
      } else {
        String targetUserId = userId ?? _currentUserId;
        await _fetchUserData(targetUserId);
      }

      if (_profileUser == null) {
        throw Exception('Kullanıcı bulunamadı');
      }

      // Check if own profile
      _isOwnProfile = _profileUser!.id == _currentUserId;

      // Load all profile data
      await _loadProfileDetails();
      await _loadUserPosts();
      if (!_isOwnProfile) {
        await _loadFollowStatus();
        await _loadPrivacySettings();
      }
    });
  }

  // API Methods - Sen dolduracaksın
  Future<void> _fetchUserData(String userId) async {
    _profileUser = UserModel(
      id: "1",
      username: 'BeratARPA',
      displayName: 'Berat ARPA',
      profilePicture: 'assets/images/app_logo.png',
      isVerified: true,
    );
    // TODO: API call to get user data
    // _profileUser = await userService.getUser(userId);
  }

  Future<void> _loadProfileDetails() async {
    _bio =
        "Full Stack Developer\nberatarpa.com\nFlutter & Dart Enthusiast\nOpen Source Contributor\nTech Blogger";
    // TODO: API call to get profile details (bio, etc.)
    // final details = await profileService.getDetails(_profileUser!.id);
    // _bio = details.bio;
  }

  Future<void> _loadUserPosts() async {
    _userPosts =
        AppSeedData.posts
            .where((post) => post.user.id == _profileUser!.id)
            .toList();
    // TODO: API call to get user posts
    // _userPosts = await postService.getUserPosts(_profileUser!.id);
  }

  Future<void> _loadFollowStatus() async {
    // TODO: API call to check follow status
    // final status = await followService.getStatus(_profileUser!.id);
    // _isFollowing = status.isFollowing;
    // _followerCount = status.followerCount;
    // _followingCount = status.followingCount;
  }

  Future<void> _loadPrivacySettings() async {
    // TODO: API call to get privacy settings
    // final privacy = await privacyService.getSettings(_profileUser!.id);
    // _isPrivate = privacy.isPrivate;
    // _isBlocked = privacy.isBlocked;
  }

  // Action Methods - Sen dolduracaksın
  Future<void> toggleFollow() async {
    if (_isOwnProfile) return;

    await runAsync(() async {
      // TODO: API call to follow/unfollow
      // if (_isFollowing) {
      //   await followService.unfollow(_profileUser!.id);
      // } else {
      //   await followService.follow(_profileUser!.id);
      // }

      _isFollowing = !_isFollowing;
      if (_isFollowing) {
        _followerCount++;
      } else {
        _followerCount--;
      }
    });
  }

  Future<void> toggleBlock() async {
    if (_isOwnProfile) return;

    await runAsync(() async {
      // TODO: API call to block/unblock
      // if (_isBlocked) {
      //   await blockService.unblock(_profileUser!.id);
      // } else {
      //   await blockService.block(_profileUser!.id);
      // }

      _isBlocked = !_isBlocked;
      if (_isBlocked) {
        _isFollowing = false;
      }
    });
  }

  Future<void> editProfile() async {
    if (!_isOwnProfile) return;

    // TODO: Navigate to edit profile page
  }

  Future<void> sendMessage() async {
    if (_isOwnProfile || _isBlocked) return;

    // TODO: Navigate to chat
  }

  Future<void> shareProfile() async {
    // TODO: Share profile
  }

  Future<void> reportUser() async {
    if (_isOwnProfile) return;

    // TODO: Report user
  }

  Future<void> refreshProfile() async {
    if (_profileUser != null) {
      await loadProfile(userId: _profileUser!.id, user: _profileUser);
    }
  }
}
