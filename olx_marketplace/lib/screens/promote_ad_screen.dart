import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/ad.dart';
import '../models/promotion_plan.dart';
import '../services/monetization_service.dart';
import 'payment_confirmation_screen.dart';

class PromoteAdScreen extends StatefulWidget {
  final Ad ad;

  const PromoteAdScreen({
    super.key,
    required this.ad,
  });

  @override
  State<PromoteAdScreen> createState() => _PromoteAdScreenState();
}

class _PromoteAdScreenState extends State<PromoteAdScreen> {
  PromotionPlan? _selectedPlan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final plans = await MonetizationService.instance.fetchPromotionPlans();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (plans.isNotEmpty) {
          _selectedPlan = plans.first;
        }
      });
    }
  }

  void _proceedToPayment() async {
    if (_selectedPlan == null) return;

    // Create pending promotion order on backend
    final promotionOrder = await MonetizationService.instance.createPromotionOrder(
      adId: widget.ad.id,
      planId: _selectedPlan!.id,
    );

    if (promotionOrder == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initiate promotion order. Please check backend connection.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentConfirmationScreen(
            ad: widget.ad,
            plan: _selectedPlan!,
            promotion: promotionOrder,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = MonetizationService.instance.promotionPlans;

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
          'Promote Your Ad',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.divider, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.campaign_outlined, size: 54, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text('No promotion plans available', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadPlans,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Target Ad Summary Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.searchBarBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.ad.imageUrl,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.ad.title,
                                    style: AppTextStyles.productTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.ad.formattedPrice,
                                    style: AppTextStyles.productPrice.copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Choose a Promotion Plan',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Boost visibility and get up to 10x more buyer responses.',
                        style: AppTextStyles.productMeta,
                      ),
                      const SizedBox(height: 16),

                      // Plans List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: plans.length,
                        itemBuilder: (context, index) {
                          final plan = plans[index];
                          final isSelected = _selectedPlan?.id == plan.id;
                          final iconData = switch (plan.type) {
                            'TOP_PLACEMENT' => Icons.workspace_premium,
                            'BOOST' => Icons.rocket_launch,
                            _ => Icons.star,
                          };

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPlan = plan;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.divider,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : AppColors.searchBarBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      iconData,
                                      color: isSelected ? Colors.white : AppColors.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              plan.name,
                                              style: AppTextStyles.sectionTitle.copyWith(fontSize: 15),
                                            ),
                                            Text(
                                              plan.formattedPrice,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          plan.description,
                                          style: AppTextStyles.productMeta.copyWith(fontSize: 12, height: 1.3),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.searchBarBg,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Duration: ${plan.durationDays} ${plan.durationDays == 1 ? 'Day' : 'Days'}',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
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
            onPressed: _selectedPlan != null ? _proceedToPayment : null,
            child: const Text(
              'Continue to Payment',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
