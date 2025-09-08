import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/helpers/app_seed_data.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_text_field.dart';
import 'package:social/widgets/post_card.dart';
import 'package:social/widgets/post_preview.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      currentIndex: 1,
      showAppBar: false,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 2));
        },
        child: CustomScrollView(
          slivers: [_buildSearchBar(), _buildPostsGrid()],
        ),
      ),
    );
  }

  // 🔹 Search Bar Widget
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CustomTextField(
          hintText: "Ara",
          prefixIcon: Icons.search,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Posts Grid Widget
  Widget _buildPostsGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(2.0),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childCount: AppSeedData.posts.length,
        itemBuilder:
            (context, index) => PostPreview(
              post: AppSeedData.posts[index],
              layout: PreviewLayout.adaptive,
              size: PreviewSize.small,
              onTap: () => _navigateToPost(AppSeedData.posts[index]),
              onLongPress: () => _showPostPreview(AppSeedData.posts[index]),
            ),
      ),
    );
  }

  // 🔹 Navigation Methods
  void _navigateToPost(PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MainLayoutView(
              showNavbar: false,
              title: Text('Keşfet'),
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
