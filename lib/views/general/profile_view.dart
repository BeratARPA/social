import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/services/format_service.dart';
import 'package:social/view_models/general/profile_viewmodel.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_elevated_button.dart';
import 'package:social/widgets/custom_profile.dart';
import 'package:social/widgets/custom_post_card.dart';
import 'package:social/widgets/custom_post_preview.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _loadProfile() {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    viewModel.loadProfile(userId: null, user: null);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);

    if (viewModel.isLoading || viewModel.profileUser == null) {
      return MainLayoutView(
        currentIndex: 4,
        showAppBar: false,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MainLayoutView(
      currentIndex: 4,
      showAppBar: false,
      body: RefreshIndicator(
        onRefresh: () async {},
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildProfileHeader(viewModel),
                  SizedBox(height: 8),
                  _buildStatistics(viewModel),
                  SizedBox(height: 8),
                  _buildActionButton(viewModel),
                  SizedBox(height: 8),
                  _buildPostsGrid(viewModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileViewModel viewModel) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.accent,
                    AppColors.darkDisabled,
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.add_box_outlined, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.share, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.settings, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        CustomProfile(
          displayName: viewModel.profileUser!.displayName,
          username: viewModel.profileUser!.username,
          profilePicture: viewModel.profileUser!.profilePicture,
          isVerified: viewModel.profileUser!.isVerified,
          hasStory: true,
          storyGradientColors: [
            AppColors.primary,
            AppColors.accent,
            AppColors.darkDisabled,
          ],
          avatarRadius: 35,
          nameTextSize: 24,
          usernameTextSize: 16,
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: context.themeValue(
              light: AppColors.lightSurface,
              dark: AppColors.darkSurface,
            ),
            border: Border.all(
              color: context.themeValue(
                light: AppColors.lightBorder,
                dark: AppColors.darkBorder,
              ),
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Text(
            viewModel.bio ?? '',
            style: TextStyle(
              fontSize: 12,
              color: context.themeValue(
                light: AppColors.lightText,
                dark: AppColors.darkText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(ProfileViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: context.themeValue(
          light: AppColors.lightSurface,
          dark: AppColors.darkSurface,
        ),
        border: Border.all(
          color: context.themeValue(
            light: AppColors.lightBorder,
            dark: AppColors.darkBorder,
          ),
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                FormatService.formatCount(viewModel.userPosts.length),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Gönderi',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Container(
            height: 40,
            width: 1,
            color: context.themeValue(
              light: AppColors.lightBorder,
              dark: AppColors.darkBorder,
            ),
          ),
          Column(
            children: [
              Text(
                FormatService.formatCount(viewModel.followerCount),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Takipçi',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Container(
            height: 40,
            width: 1,
            color: context.themeValue(
              light: AppColors.lightBorder,
              dark: AppColors.darkBorder,
            ),
          ),
          Column(
            children: [
              Text(
                FormatService.formatCount(viewModel.followingCount),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text('Takip', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(ProfileViewModel viewModel) {
    if (viewModel.isOwnProfile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CustomElevatedButton(
          width: double.infinity,
          onPressed: () {
            // Navigate to edit profile
          },
          buttonText: "Profili Düzenle",
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: CustomElevatedButton(
                onPressed: () {
                  if (viewModel.isFollowing) {
                    viewModel.toggleFollow();
                  } else {
                    viewModel.toggleFollow();
                  }
                },
                buttonText:
                    viewModel.isFollowing ? 'Takip Ediliyor' : 'Takip Et',
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.mail,
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
  }

  Widget _buildPostsGrid(ProfileViewModel viewModel) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // TabBar
          TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(icon: Icon(Icons.grid_on), text: "Görseller"),
              Tab(icon: Icon(Icons.videocam), text: "Videolar"),
              Tab(icon: Icon(Icons.article), text: "Yazılar"),
              Tab(icon: Icon(Icons.poll), text: "Anketler"),
            ],
          ),

          // TabBarView
          SizedBox(
            height:
                400, // Set a fixed height or use MediaQuery for dynamic sizing
            child: TabBarView(
              children: [
                // Görseller
                GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: viewModel.imagePosts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final image = viewModel.imagePosts[index];
                    return PostPreview(
                      post: image,
                      onLongPress: () => _showPostPreview(image),
                      onTap: () => _navigateToPost(image),
                    );
                  },
                ),

                // Videolar
                GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: viewModel.videoPosts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.5,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemBuilder: (context, index) {
                    final video = viewModel.videoPosts[index];
                    return PostPreview(
                      post: video,
                      onLongPress: () => _showPostPreview(video),
                      onTap: () => _navigateToPost(video),
                    );
                  },
                ),

                // Yazılar
                GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: viewModel.textPosts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final text = viewModel.textPosts[index];
                    return PostPreview(
                      post: text,
                      size: PreviewSize.small,
                      onLongPress: () => _showPostPreview(text),
                      onTap: () => _navigateToPost(text),
                    );
                  },
                ),

                // Anketler
                GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: viewModel.pollPosts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final poll = viewModel.pollPosts[index];
                    return PostPreview(
                      post: poll,
                      size: PreviewSize.small,
                      onLongPress: () => _showPostPreview(poll),
                      onTap: () => _navigateToPost(poll),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPost(PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MainLayoutView(
              showNavbar: false,
              title: Text('Gönderiler'),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [PostCard(post: post)],
              ),
            ),
      ),
    );
  }

  void _showPostPreview(PostModel post) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.themeValue(
                light: AppColors.lightSurface,
                dark: AppColors.darkSurface,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: PostCard(post: post)),
              ],
            ),
          ),
    );
  }
}
