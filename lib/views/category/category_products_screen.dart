import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../data/models.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/auth_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categorySlug;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categorySlug,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  int _selectedStyleIndex = 0;

  // 7 Signature Curated Styles for each category
  static final Map<String, List<Map<String, dynamic>>> _curatedStyles = {
    'jeans': [
      {'name': 'Raw Indigo Slim Jeans', 'price': 49.99, 'desc': 'Raw stretch denim tailored for daily durability.'},
      {'name': 'Classic Washed Straight Denim', 'price': 44.99, 'desc': 'Regular fit vintage stone-wash.'},
      {'name': 'Artisan Selvedge Flatlay Denim', 'price': 59.99, 'desc': 'Heavyweight Japanese selvedge denim.'},
      {'name': 'Urban Street Tapered Jeans', 'price': 48.00, 'desc': 'Tapered leg cut designed for sneaker stacks.'},
      {'name': 'Distressed Modern Ripped Denim', 'price': 54.99, 'desc': 'Hand-distressed accents with reinforced backing.'},
      {'name': 'Textured Dark Stretch Jeans', 'price': 42.50, 'desc': 'Midnight black flex wash.'},
      {'name': 'High-Rise Heritage Blue Jeans', 'price': 52.00, 'desc': 'Timeless structured high-rise waist.'},
    ],
    't-shirts': [
      {'name': 'Minimalist Heavyweight White Tee', 'price': 24.99, 'desc': '240 GSM combed cotton crewneck.'},
      {'name': 'Graphic Urban Print Streetwear', 'price': 29.99, 'desc': 'Screen-printed vintage-washed jersey.'},
      {'name': 'Aesthetic Washed Neutral T-Shirt', 'price': 27.50, 'desc': 'Garment-dyed muted earth tone.'},
      {'name': 'Oversized Drop-Shoulder Tee', 'price': 26.00, 'desc': 'Relaxed boxy silhouette with dropped seams.'},
      {'name': 'Pastel Organic Cotton T-Shirt', 'price': 22.99, 'desc': 'Sustainably harvested 100% organic cotton.'},
      {'name': 'Streetwear Fit Typography Tee', 'price': 31.00, 'desc': 'Subtle embroidery with athletic hem.'},
      {'name': 'Retro Athletic Striped Crewneck', 'price': 25.00, 'desc': 'Classic horizontal contrast stripe design.'},
    ],
    'shoes': [
      {'name': 'Velocity Red Sport Trainers', 'price': 89.99, 'desc': 'Shock-absorbing cushion foam sole.'},
      {'name': 'Classic Minimalist White Lows', 'price': 74.99, 'desc': 'Crisp white leather with gum rubber sole.'},
      {'name': 'Urban Street Platform Sneakers', 'price': 82.00, 'desc': 'Chunky sculpted midsole with nubuck leather.'},
      {'name': 'Old-Skool Skate Canvas Shoes', 'price': 65.00, 'desc': 'Reinforced canvas with vulcanized waffle sole.'},
      {'name': 'Chunky Colorblock Runner Sneakers', 'price': 94.99, 'desc': 'Multi-panel runner with air-pocket support.'},
      {'name': 'Retro High-Top Basketball Kicks', 'price': 99.00, 'desc': 'Padded ankle collar and vintage court leather.'},
      {'name': 'Lightweight Marathon Breathable Kicks', 'price': 79.99, 'desc': 'Engineered carbon plate bounce running shoe.'},
    ],
    'glasses': [
      {'name': 'Luxury Black Acetate Sunglasses', 'price': 39.99, 'desc': 'Italian acetate with 100% UV400 lenses.'},
      {'name': 'Classic Polarized Wayfarer Shades', 'price': 44.99, 'desc': 'Square silhouette with dark green polarized lenses.'},
      {'name': 'Modern Clear Frame Blue-Light Glasses', 'price': 32.50, 'desc': 'Crystal acetate with blue-light filter lenses.'},
      {'name': 'Gold-Trim Summer Aviator Shades', 'price': 49.00, 'desc': 'Lightweight gold wireframe with teardrop lenses.'},
      {'name': 'Retro Round Tortoise Acetate Frames', 'price': 38.00, 'desc': 'Vintage amber tortoiseshell round frames.'},
      {'name': 'Minimalist Matte Black Sport Glasses', 'price': 36.99, 'desc': 'Aerodynamic wrap-around anti-slip frame.'},
      {'name': 'Gradient Designer Oval Sunglasses', 'price': 45.00, 'desc': 'Narrow oval silhouette with gradient tint.'},
    ],
    'jackets': [
      {'name': 'Classic Faux Leather Biker Jacket', 'price': 119.99, 'desc': 'Asymmetrical zip moto with silver hardware.'},
      {'name': 'Thermal Insulated Winter Parka', 'price': 139.99, 'desc': 'Down-filled stormproof coat with fleece pockets.'},
      {'name': 'Sherpa-Lined Vintage Denim Jacket', 'price': 98.00, 'desc': 'Heavy-wash denim with plush sherpa lining.'},
      {'name': 'Streetwear Oversized Bomber Jacket', 'price': 89.99, 'desc': 'Satin nylon shell with utility arm pocket.'},
      {'name': 'Outdoor Waterproof Utility Windbreaker', 'price': 85.00, 'desc': 'Taped seams with packable hood.'},
      {'name': 'Modern Minimalist Wool Trench Coat', 'price': 149.00, 'desc': 'Double-breasted longline wool blend coat.'},
      {'name': 'Suede Tan Zip-Up Casual Jacket', 'price': 109.00, 'desc': 'Supple faux suede with brass hardware.'},
    ],
    'suits': [
      {'name': 'Modern Tailored Midnight Blue Suit', 'price': 189.99, 'desc': 'Slim notch lapel two-button tailored blazer.'},
      {'name': 'Formal Executive Charcoal 2-Piece', 'price': 219.99, 'desc': 'Pure wool blend with structured chest canvas.'},
      {'name': 'Luxury Black-Tie Evening Tuxedo', 'price': 249.00, 'desc': 'Satin shawl lapel and matching satin trousers.'},
      {'name': 'Double-Breasted Gentleman Plaid Suit', 'price': 199.99, 'desc': 'Six-button peak lapel in British glen plaid.'},
      {'name': 'Contemporary Slim Heather Gray Suit', 'price': 179.50, 'desc': 'Versatile all-season heather gray wool.'},
      {'name': 'Classic Wedding Dark Wool Tuxedo', 'price': 229.00, 'desc': 'Tailored black wool with peak silk lapels.'},
      {'name': 'Royal Linen Summer Lightweight Blazer', 'price': 159.00, 'desc': 'Unstructured breathable linen suit jacket.'},
    ],
    'bags': [
      {'name': 'Handcrafted Commuter Leather Backpack', 'price': 79.99, 'desc': 'Padded 15.6-inch laptop pocket in full-grain leather.'},
      {'name': 'Designer Crossbody Saddle Bag', 'price': 64.99, 'desc': 'Gold buckle accent with magnetic snap closure.'},
      {'name': 'Minimalist Artisan Canvas Tote', 'price': 49.00, 'desc': 'Heavyweight 16oz cotton with reinforced straps.'},
      {'name': 'Urban Travel Duffel Weekend Bag', 'price': 89.00, 'desc': '45L carry-on with dedicated shoe compartment.'},
      {'name': 'Structured Executive Laptop Satchel', 'price': 95.00, 'desc': 'Dual top handles and organized document slots.'},
      {'name': 'Water-Resistant Compact Sling Bag', 'price': 39.99, 'desc': 'Ripstop nylon chest pack with RFID pocket.'},
      {'name': 'Vintage Tan Leather Messenger Bag', 'price': 84.50, 'desc': 'Antique brass buckles and distressed leather.'},
    ],
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ProductProvider>().fetchProductsByCategory(widget.categorySlug);
      }
    });
  }

  List<Product> _getCategoryProducts(List<Product> liveProducts) {
    final slug = widget.categorySlug.toLowerCase();
    final styles = _curatedStyles[slug] ?? [];

    final List<Product> curated = List.generate(styles.length, (i) {
      final s = styles[i];
      return Product(
        id: '$slug-style-${i + 1}',
        name: s['name'] as String,
        description: s['desc'] as String,
        price: (s['price'] as num).toDouble(),
        image: 'assets/images/categories/$slug/$slug-${i + 1}.jpg',
        category: slug,
        isFeatured: i == 0,
      );
    });

    // Merge live products with curated products
    final List<Product> merged = [...liveProducts];
    for (final c in curated) {
      if (!merged.any((p) => p.name.toLowerCase() == c.name.toLowerCase())) {
        merged.add(c);
      }
    }
    return merged;
  }

  Widget _buildProductImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.primaryLight,
          child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
        ),
      );
    }
    return Image.network(
      imagePath,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.surfaceMuted,
        child: const Icon(Icons.broken_image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final allProducts = _getCategoryProducts(productProvider.categoryProducts);

    // Build the 7 image paths for this category
    final styleImages = List.generate(
      7,
      (i) => 'assets/images/categories/${widget.categorySlug}/${widget.categorySlug}-${i + 1}.jpg',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          '${widget.categoryName} (${allProducts.length})',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<ProductProvider>().fetchProductsByCategory(widget.categorySlug),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Category Lookbook Header Banner (7 Curated Styles Switcher)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      // Active preview image
                      SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: Image.asset(
                          styleImages[_selectedStyleIndex],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: AppColors.primary),
                        ),
                      ),

                      // Gradient Scrim
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.85),
                              Colors.black.withValues(alpha: 0.25),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),

                      // Banner Info & 7 Style Thumbnails
                      Positioned(
                        bottom: 12,
                        left: 14,
                        right: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.categoryName} Lookbook',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Style ${_selectedStyleIndex + 1} of 7',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // 7 Style Thumbnail Switchers
                            SizedBox(
                              height: 42,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: 7,
                                separatorBuilder: (context, index) => const SizedBox(width: 8),
                                itemBuilder: (context, idx) {
                                  final isSelected = _selectedStyleIndex == idx;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() => _selectedStyleIndex = idx);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 44,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
                                          width: isSelected ? 2.5 : 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          styleImages[idx],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(color: AppColors.primary),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Products Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All 7 Styles & Products (${allProducts.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const Text(
                      'Verified Authentic',
                      style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            // Products Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = allProducts[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                              child: _buildProductImage(product.image),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(11.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  product.description,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primary),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        final auth = context.read<AuthProvider>();
                                        if (!auth.isAuthenticated) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Please sign in to add items to your cart'),
                                              duration: const Duration(seconds: 2),
                                              backgroundColor: AppColors.warning,
                                              action: SnackBarAction(
                                                label: 'Sign In',
                                                textColor: Colors.white,
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
                                                },
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        final success = await context.read<CartProvider>().addToCart(product);
                                        if (context.mounted && success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${product.name} added to cart'),
                                              duration: const Duration(seconds: 1),
                                              backgroundColor: AppColors.primary,
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.add_shopping_cart, size: 16, color: AppColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: allProducts.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
