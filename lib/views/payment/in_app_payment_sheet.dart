import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../providers/cart_provider.dart';
import 'purchase_success_screen.dart';

class InAppPaymentSheet extends StatefulWidget {
  const InAppPaymentSheet({super.key});

  @override
  State<InAppPaymentSheet> createState() => _InAppPaymentSheetState();
}

class _InAppPaymentSheetState extends State<InAppPaymentSheet> {
  final _cardNumberController = TextEditingController();
  final _expController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _fillTestCard() {
    setState(() {
      _cardNumberController.text = '4242 4242 4242 4242';
      _expController.text = '12/28';
      _cvcController.text = '123';
      _nameController.text = 'Test Buyer';
      _errorMessage = null;
    });
  }

  Future<void> _submitPayment() async {
    final rawNumber = _cardNumberController.text.replaceAll(' ', '').trim();
    final expText = _expController.text.trim();
    final cvc = _cvcController.text.trim();
    final name = _nameController.text.trim();

    if (rawNumber.length < 15) {
      setState(() => _errorMessage = 'Please enter a valid 16-digit card number.');
      return;
    }

    final expParts = expText.split('/');
    if (expParts.length != 2 || expParts[0].isEmpty || expParts[1].isEmpty) {
      setState(() => _errorMessage = 'Please enter expiration date as MM/YY.');
      return;
    }

    final expMonth = expParts[0].padLeft(2, '0');
    final expYear = expParts[1];

    if (cvc.length < 3) {
      setState(() => _errorMessage = 'Please enter a valid 3 or 4-digit CVC.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final cart = context.read<CartProvider>();
    final orderId = await cart.processInAppPayment(
      cardNumber: rawNumber,
      expMonth: expMonth,
      expYear: expYear,
      cvc: cvc,
      cardHolderName: name.isNotEmpty ? name : 'Cardholder',
    );

    if (mounted) {
      setState(() => _isProcessing = false);

      if (orderId != null) {
        // Close bottom sheet
        Navigator.pop(context);

        // Navigate directly to in-app success confirmation screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PurchaseSuccessScreen(orderId: orderId),
          ),
        );
      } else {
        setState(() {
          _errorMessage = cart.errorMessage ?? 'Payment failed. Please check your card information.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.credit_card, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'In-App Card Payment',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Order Summary Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${cart.totalItemCount} items in cart', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        if (cart.discountAmount > 0)
                          Text('Coupon: -\$${cart.discountAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text(
                      '\$${cart.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Test card auto-filler button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _isProcessing ? null : _fillTestCard,
                  icon: const Icon(Icons.bolt, size: 16, color: AppColors.accent),
                  label: const Text('Fill Test Card (4242...)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
                ),
              ),

              // Card Number Input
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                enabled: !_isProcessing,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '4242 4242 4242 4242',
                  prefixIcon: const Icon(Icons.payment_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),

              // Expiry & CVC Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expController,
                      keyboardType: TextInputType.number,
                      enabled: !_isProcessing,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _CardExpiryInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Expires (MM/YY)',
                        hintText: '12/28',
                        prefixIcon: const Icon(Icons.date_range_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvcController,
                      keyboardType: TextInputType.number,
                      enabled: !_isProcessing,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(
                        labelText: 'CVC / CVV',
                        hintText: '123',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Cardholder Name Input
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                enabled: !_isProcessing,
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  hintText: 'John Doe',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
              const SizedBox(height: 14),

              // Error message & Stripe Checkout Fallback
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF635BFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      final session = await cart.createCheckoutSession();
                      if (session?.url != null) {
                        await launchUrl(Uri.parse(session!.url!), mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.lock_rounded, size: 16),
                    label: const Text('Pay with Stripe Checkout (Live)'),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Pay Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _isProcessing ? null : _submitPayment,
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            SizedBox(width: 12),
                            Text('Processing Payment...', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )
                      : Text(
                          'Pay \$${cart.total.toStringAsFixed(2)} Securely',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 10),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
                  SizedBox(width: 4),
                  Text(
                    '256-Bit Encrypted & Tokenized via Stripe',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom formatter to insert space every 4 digits: 4242 4242 4242 4242
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Custom formatter for MM/YY
class _CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
