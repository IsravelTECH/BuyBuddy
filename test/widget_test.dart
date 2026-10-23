import 'package:flutter_test/flutter_test.dart';
import 'package:buybuddy_mobile/data/models.dart';

void main() {
  group('BuyBuddy Models Unit Tests', () {
    test('Product model should serialize and deserialize correctly', () {
      final json = {
        '_id': 'prod_123',
        'name': 'Premium Cotton T-Shirt',
        'description': 'High quality everyday shirt',
        'price': 29.99,
        'image': 'https://example.com/shirt.jpg',
        'category': 't-shirts',
        'isFeatured': true,
      };

      final product = Product.fromJson(json);

      expect(product.id, 'prod_123');
      expect(product.name, 'Premium Cotton T-Shirt');
      expect(product.price, 29.99);
      expect(product.category, 't-shirts');
      expect(product.isFeatured, true);
    });

    test('CartItem model calculates subtotal correctly', () {
      final product = Product(
        id: 'p1',
        name: 'Jeans',
        description: 'Denim jeans',
        price: 50.0,
        image: '',
        category: 'jeans',
        isFeatured: false,
      );

      final cartItem = CartItem(product: product, quantity: 3);

      expect(cartItem.subtotal, 150.0);
    });

    test('Coupon model holds code and percentage correctly', () {
      final coupon = Coupon(
        code: 'SAVE20',
        discountPercentage: 20,
        isActive: true,
      );

      expect(coupon.code, 'SAVE20');
      expect(coupon.discountPercentage, 20);
      expect(coupon.isActive, true);
    });
  });
}
