import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../category/category_products_screen.dart';

class VideoHeroBanner extends StatefulWidget {
  final VoidCallback onExploreCategories;

  const VideoHeroBanner({
    super.key,
    required this.onExploreCategories,
  });

  @override
  State<VideoHeroBanner> createState() => _VideoHeroBannerState();
}

class _VideoHeroBannerState extends State<VideoHeroBanner> {
  late PageController _pageController;
  int _activePage = 0;
  Timer? _autoPlayTimer;

  // Curated hero lifestyle frames
  final List<Map<String, String>> _bannerSlides = [
    {
      'image': 'assets/images/categories/suits/suits-1.jpg',
      'tag': '🔥 SPRING / SUMMER 2026',
      'title': 'Redefine Your Everyday Style',
      'subtitle': 'Handcrafted tailoring & modern elegance',
      'category': 'suits',
      'categoryName': 'Suits',
    },
    {
      'image': 'assets/images/categories/jackets/jackets-1.jpg',
      'tag': '✨ NEW ARRIVAL',
      'title': 'Premium Leather & Outerwear',
      'subtitle': 'Weather-resistant jackets for urban exploration',
      'category': 'jackets',
      'categoryName': 'Jackets',
    },
    {
      'image': 'assets/images/categories/shoes/shoes-1.jpg',
      'tag': '⚡ POPULAR KICKS',
      'title': 'Streetwear & Athletic Footwear',
      'subtitle': 'Performance meets street-ready aesthetics',
      'category': 'shoes',
      'categoryName': 'Shoes',
    },
    {
      'image': 'assets/images/categories/jeans/jeans-1.jpg',
      'tag': '🌟 ICONIC DENIM',
      'title': 'Timeless Raw & Washed Denim',
      'subtitle': 'Tailored fit designed for maximum comfort',
      'category': 'jeans',
      'categoryName': 'Jeans',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_activePage + 1) % _bannerSlides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Slide Carousel
            PageView.builder(
              controller: _pageController,
              onPageChanged: (idx) {
                setState(() => _activePage = idx);
              },
              itemCount: _bannerSlides.length,
              itemBuilder: (context, index) {
                final slide = _bannerSlides[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    Image.asset(
                      slide['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primary,
                        child: const Center(
                          child: Icon(Icons.shopping_bag, size: 64, color: Colors.white54),
                        ),
                      ),
                    ),

                    // Cinematic Gradient Vignette
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.85),
                            Colors.black.withValues(alpha: 0.45),
                            Colors.black.withValues(alpha: 0.2),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),

                    // Slide Content
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              slide['tag']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Headline
                          Text(
                            slide['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Subtitle
                          Text(
                            slide['subtitle']!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Action Buttons
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CategoryProductsScreen(
                                        categorySlug: slide['category']!,
                                        categoryName: slide['categoryName']!,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text('Shop Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    SizedBox(width: 6),
                                    Icon(Icons.arrow_forward_rounded, size: 16),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: widget.onExploreCategories,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  'All Categories',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // Bottom Carousel Indicator Dots
            Positioned(
              bottom: 12,
              right: 20,
              child: Row(
                children: List.generate(
                  _bannerSlides.length,
                  (dotIndex) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    height: 5,
                    width: _activePage == dotIndex ? 18 : 5,
                    decoration: BoxDecoration(
                      color: _activePage == dotIndex ? Colors.white : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
