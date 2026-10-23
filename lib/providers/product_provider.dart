import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/api_service.dart';
import '../data/models.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Product> _featuredProducts = [];
  List<Product> _categoryProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get categoryProducts => _categoryProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFeaturedProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.dio.get('/products/featured');
      if (response.statusCode == 200) {
        final List data = response.data is List ? response.data : [];
        _featuredProducts = data.map((item) => Product.fromJson(item)).toList();
      }
    } on DioException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load featured products';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProductsByCategory(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.dio.get('/products/category/$category');
      if (response.statusCode == 200) {
        final List data = response.data['products'] ?? [];
        _categoryProducts = data.map((item) => Product.fromJson(item)).toList();
      }
    } on DioException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load products for $category';
    }

    _isLoading = false;
    notifyListeners();
  }
}
