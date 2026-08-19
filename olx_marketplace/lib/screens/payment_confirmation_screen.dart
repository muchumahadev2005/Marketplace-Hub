import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/ad.dart';
import '../models/ad_promotion.dart';
import '../models/promotion_plan.dart';
import '../services/ad_repository.dart';
import '../services/monetization_service.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final Ad ad;
  final PromotionPlan plan;
  final AdPromotion promotion;

  const PaymentConfirmationScreen({
    super.key,
    required this.ad,
    required this.plan,
    required this.promotion,
  });

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() { _isProcessing = true; });

    // Send verification request to Spring Boot backend
    final activatedPromo = await MonetizationService.instance.verifyAndActivatePromotion(
      promotionId: widget.promotion.id,
      devModeSimulatedSuccess: true, // Verification is validated by backend PaymentService
    );

    setState(() { _isProcessing = false; });

    if (activatedPromo != null && activatedPromo.status == 'ACTIVE') {
      // Reload home ads repository
      await AdRepository.instance.loadHomeData(forceReload: true);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Promotion Activated!'),
              ],
            ),
            content: Text(
              'Your ad "${widget.ad.title}" is now ${widget.plan.name.toUpperCase()} for ${widget.plan.durationDays} days.',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Pop payment screen
                  Navigator.pop(context); // Pop promote screen
                },
                child: const Text('Done', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment verification failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.plan.price;
    final gstTax = subtotal * 0.18; // 18% GST standard
    final totalAmount = subtotal + gstTax;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Confirmation',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.divider, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Development Mode Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  Icon(Icons.developer_mode, color: Colors.amber.shade900, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'DEVELOPMENT MODE — Secure Test Gateway Enabled',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order Summary Header
            Text('Order Summary', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.searchBarBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Ad Title', widget.ad.title),
                  const Divider(height: 20),
                  _buildSummaryRow('Selected Plan', widget.plan.name),
                  const Divider(height: 20),
                  _buildSummaryRow('Promotion Type', widget.plan.type),
                  const Divider(height: 20),
                  _buildSummaryRow('Duration', '${widget.plan.durationDays} Days'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Price Breakdown
            Text('Payment Breakdown', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Plan Price', '₹${subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 10),
                  _buildSummaryRow('GST (18%)', '₹${gstTax.toStringAsFixed(2)}'),
                  const Divider(height: 24, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(
                        '₹${totalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.green, size: 18),
                SizedBox(width: 6),
                Text('Encrypted & Verified by Spring Boot Backend', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _isProcessing ? null : _processPayment,
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Pay ₹${totalAmount.toStringAsFixed(2)} & Activate',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.productMeta.copyWith(fontSize: 13)),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.productTitle.copyWith(fontSize: 13),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
