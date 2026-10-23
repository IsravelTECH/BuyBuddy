import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/api_service.dart';
import '../data/models.dart';

class CartProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<CartItem> _items = [];
  Coupon? _appliedCoupon;
  Coupon? _myCoupon;
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItem> get items => _items;
  Coupon? get appliedCoupon => _appliedCoupon;
  Coupon? get myCoupon => _myCoupon;
  bool get isCouponApplied => _appliedCoupon != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalItemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get discountAmount {
    if (_appliedCoupon != null && isCouponApplied) {
      return (subtotal * _appliedCoupon!.discountPercentage) / 100;
    }
    return 0.0;
  }

  double get total => (subtotal - discountAmount).clamp(0.0, double.infinity);

  /// Fetch cart items from MongoDB backend
  Future<void> fetchCart() async {
    final token = await _api.getToken();
    if (token == null || token.isEmpty) {
      _items = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.dio.get('/cart');
      if (response.statusCode == 200) {
        final List data = response.data is List ? response.data : [];
        _items = data.map((item) => CartItem.fromJson(item)).toList();
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? e.message;
    } catch (_) {
      _errorMessage = 'Failed to load cart items';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add product to cart with backend persistence
  Future<bool> addToCart(Product product) async {
    final token = await _api.getToken();
    if (token == null || token.isEmpty) {
      _errorMessage = 'Please sign in to add items to your cart';
      notifyListeners();
      return false;
    }

    // Optimistic local update
    final existingIndex = _items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();

    try {
      final response = await _api.dio.post('/cart', data: {
        'productId': product.id,
      });
      return response.statusCode == 200;
    } catch (e) {
      // Revert if failed
      if (existingIndex >= 0) {
        _items[existingIndex].quantity -= 1;
      } else {
        _items.removeWhere((i) => i.product.id == product.id);
      }
      notifyListeners();
      return false;
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String productId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    final index = _items.indexWhere((i) => i.product.id == productId);
    final previousQuantity = index >= 0 ? _items[index].quantity : 1;

    if (index >= 0) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }

    try {
      await _api.dio.put('/cart/$productId', data: {
        'quantity': newQuantity,
      });
    } catch (e) {
      if (index >= 0) {
        _items[index].quantity = previousQuantity;
        notifyListeners();
      }
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String productId) async {
    final removed = _items.where((i) => i.product.id == productId).toList();
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();

    try {
      await _api.dio.delete('/cart', data: {
        'productId': productId,
      });
    } catch (e) {
      _items.addAll(removed);
      notifyListeners();
    }
  }

  /// Clear cart locally after checkout
  void clearCart() {
    _items.clear();
    _appliedCoupon = null;
    notifyListeners();
  }

  /// Fetch user active gift coupon
  Future<void> fetchMyCoupon() async {
    final token = await _api.getToken();
    if (token == null || token.isEmpty) {
      _myCoupon = null;
      notifyListeners();
      return;
    }

    try {
      final response = await _api.dio.get('/coupons');
      if (response.statusCode == 200 && response.data != null) {
        _myCoupon = Coupon.fromJson(response.data);
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Apply promotional coupon code against backend validation
  Future<bool> applyCoupon(String code) async {
    try {
      final response = await _api.dio.post('/coupons/validate', data: {
        'code': code.trim(),
      });
      if (response.statusCode == 200) {
        _appliedCoupon = Coupon.fromJson(response.data);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _appliedCoupon = null;
      notifyListeners();
    }
    return false;
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  /// Create Stripe checkout session
  Future<CheckoutSessionResult?> createCheckoutSession() async {
    try {
      final productsPayload = _items.map((item) => {
        '_id': item.product.id,
        'name': item.product.name,
        'price': item.product.price,
        'image': item.product.image,
        'quantity': item.quantity,
      }).toList();

      final response = await _api.dio.post('/payments/create-checkout-session', data: {
        'products': productsPayload,
        if (_appliedCoupon != null) 'couponCode': _appliedCoupon!.code,
      });

      if (response.statusCode == 200) {
        final id = response.data['id'] as String?;
        final url = response.data['url'] as String?;
        if (id != null) {
          return CheckoutSessionResult(id: id, url: url);
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? e.message;
    } catch (_) {
      _errorMessage = 'Could not create checkout session';
    }
    return null;
  }

  /// Process payment directly inside the application using Stripe Tokenization
  Future<String?> processInAppPayment({
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
    String? cardHolderName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Send card details directly to backend to tokenize via Stripe Secret Key and charge
      final productsPayload = _items.map((item) => {
        '_id': item.product.id,
        'name': item.product.name,
        'price': item.product.price,
        'image': item.product.image,
        'quantity': item.quantity,
      }).toList();

      final response = await _api.dio.post('/payments/pay-in-app', data: {
        'products': productsPayload,
        if (_appliedCoupon != null) 'couponCode': _appliedCoupon!.code,
        'cardNumber': cardNumber.replaceAll(RegExp(r'\s+'), ''),
        'expMonth': expMonth.trim(),
        'expYear': expYear.trim().length == 2 ? '20${expYear.trim()}' : expYear.trim(),
        'cvc': cvc.trim(),
        if (cardHolderName != null && cardHolderName.trim().isNotEmpty)
          'cardHolderName': cardHolderName.trim(),
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final orderId = response.data['orderId'] as String?;
        clearCart();
        _isLoading = false;
        notifyListeners();
        return orderId;
      } else {
        _errorMessage = response.data?['message'] ?? 'Payment processing failed';
      }
    } on DioException catch (e) {
      String? stripeMsg;
      String? backendMsg;
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        stripeMsg = data['error'] is Map ? data['error']['message'] : data['error']?.toString();
        backendMsg = data['message']?.toString();
      } else if (e.response?.statusCode == 404) {
        backendMsg = 'Direct in-app payment is not deployed on the live server. Please use Stripe Checkout.';
      }
      _errorMessage = stripeMsg ?? backendMsg ?? e.message ?? 'Payment failed. Please verify card details.';
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }
}

class CheckoutSessionResult {
  final String id;
  final String? url;

  CheckoutSessionResult({required this.id, this.url});
}
