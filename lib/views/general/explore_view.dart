import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_text_field.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final List<String> images = List.generate(
    30,
    (index) => "https://picsum.photos/id/${index + 10}/500/500",
  );

  String query = "";

  @override
  Widget build(BuildContext context) {
    final filteredImages =
        images
            .where((img) => img.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return MainLayoutView(
      currentIndex: 1,
      showAppBar: false,
      body: CustomScrollView(
        slivers: [
          // 🔍 Search alanı (scroll ile kayacak)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextField(
                hintText: "Ara",
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                prefixIcon: Icons.search,
                onChanged: (value) {
                  // Handle search
                },
              ),
            ),
          ),

          // 🔳 Grid
          SliverPadding(
            padding: const EdgeInsets.all(4),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 3, // Pinterest tarzı 2 sütun
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childCount: filteredImages.length,
              itemBuilder: (context, index) {
                final image = filteredImages[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(image: image),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(image, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String image;
  const DetailPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Image.network(image)),
    );
  }
}
