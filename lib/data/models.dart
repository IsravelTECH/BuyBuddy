class User {
  final String id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'role': role,
      };
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.isFeatured = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'description': description,
        'price': price,
        'image': image,
        'category': category,
        'isFeatured': isFeatured,
      };
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productData = json['product'] is Map<String, dynamic>
        ? json['product']
        : json;
    return CartItem(
      product: Product.fromJson(productData),
      quantity: json['quantity'] ?? 1,
    );
  }

  double get subtotal => product.price * quantity;
}

class Coupon {
  final String? id;
  final String code;
  final int discountPercentage;
  final bool isActive;

  Coupon({
    this.id,
    required this.code,
    required this.discountPercentage,
    required this.isActive,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['_id'],
      code: json['code'] ?? '',
      discountPercentage: (json['discountPercentage'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) '_id': id,
        'code': code,
        'discountPercentage': discountPercentage,
        'isActive': isActive,
      };
}
