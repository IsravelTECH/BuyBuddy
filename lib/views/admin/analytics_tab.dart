import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../../core/constants.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic> _analyticsData = {
    'users': 0,
    'products': 0,
    'totalSales': 0,
    'totalRevenue': 0.0,
  };

  List<dynamic> _dailySalesData = [];

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.dio.get('/analytics');
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _analyticsData = response.data['analyticsData'] ?? _analyticsData;
          _dailySalesData = response.data['dailySalesData'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load store analytics';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Aggregating business metrics...', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _fetchAnalytics, child: const Text('Retry')),
          ],
        ),
      );
    }

    final totalRevenue = (_analyticsData['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    final totalSales = _analyticsData['totalSales'] ?? 0;
    final totalProducts = _analyticsData['products'] ?? 0;
    final totalUsers = _analyticsData['users'] ?? 0;

    return RefreshIndicator(
      onRefresh: _fetchAnalytics,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 4 KPI Cards Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildKpiCard(
                title: 'Total Revenue',
                value: '\$${totalRevenue.toStringAsFixed(2)}',
                icon: Icons.attach_money_rounded,
                color: AppColors.success,
                lightColor: AppColors.successLight,
              ),
              _buildKpiCard(
                title: 'Total Orders',
                value: '$totalSales',
                icon: Icons.shopping_bag_rounded,
                color: AppColors.primary,
                lightColor: AppColors.primaryLight,
              ),
              _buildKpiCard(
                title: 'Total Products',
                value: '$totalProducts',
                icon: Icons.inventory_2_rounded,
                color: Colors.amber.shade700,
                lightColor: Colors.amber.shade50,
              ),
              _buildKpiCard(
                title: 'Active Users',
                value: '$totalUsers',
                icon: Icons.people_alt_rounded,
                color: Colors.purple,
                lightColor: Colors.purple.shade50,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Daily Sales Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daily Sales (Past 7 Days)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Live Metrics', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_dailySalesData.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No sales records in the current period.', style: TextStyle(color: AppColors.textSecondary))),
                  )
                else
                  ..._dailySalesData.map((item) {
                    final date = item['date'] ?? '';
                    final sales = item['sales'] ?? 0;
                    final revenue = (item['revenue'] as num?)?.toDouble() ?? 0.0;
                    final maxRevenue = _dailySalesData.fold(1.0, (prev, curr) {
                      final val = (curr['revenue'] as num?)?.toDouble() ?? 0.0;
                      return val > prev ? val : prev;
                    });
                    final percentage = (revenue / maxRevenue).clamp(0.05, 1.0);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              Text(
                                '$sales orders • \$${revenue.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: AppColors.surfaceMuted,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color lightColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
