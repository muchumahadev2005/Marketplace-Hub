import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../core/theme.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/monetization_service.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  late Razorpay _razorpay;
  bool _isLoading = true;
  String? _pendingPlanName;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadDashboard();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final planName = _pendingPlanName ?? 'PREMIUM';
    final verified = await MonetizationService.instance.verifySubscriptionPayment(
      orderId: response.orderId ?? '',
      paymentId: response.paymentId ?? '',
      signature: response.signature ?? '',
      planName: planName,
    );

    if (mounted) {
      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Payment Verified! Successfully upgraded to $planName Plan!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadDashboard();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Payment verification failed on server.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment cancelled or failed: ${response.message ?? "Error"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External Wallet selected: ${response.walletName}')),
      );
    }
  }

  Future<void> _loadDashboard() async {
    await MonetizationService.instance.fetchSellerDashboard();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _upgradePlan(String planName) async {
    _pendingPlanName = planName;
    final order = await MonetizationService.instance.createSubscriptionOrder(planName);

    if (order == null || order['orderId'] == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create Razorpay Order. Please try again.')),
        );
      }
      return;
    }

    final user = AuthService.instance.currentUser;
    var options = {
      'key': order['keyId'] ?? 'rzp_test_TRfDAtRyhSdBym',
      'amount': order['amount'], // Amount in paise
      'name': 'OLX Marketplace',
      'description': '$planName Seller Plan Upgrade',
      'order_id': order['orderId'],
      'prefill': {
        'contact': user?.phone ?? '9876543210',
        'email': user?.email ?? 'seller@example.com',
        'name': user?.name ?? 'Seller',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay checkout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = MonetizationService.instance.dashboardData;

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
          'Seller Dashboard',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.divider, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (AuthService.instance.currentUser == null || !ApiClient.instance.hasToken)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_circle_outlined, size: 64, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        Text(
                          'Log in to view Seller Dashboard',
                          style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Track active ad limits, total views, and manage seller plans.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Go Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                )
              : dashboard == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.dashboard_customize_outlined, size: 54, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          const Text('Could not load seller metrics.'),
                          const SizedBox(height: 8),
                          TextButton(onPressed: _loadDashboard, child: const Text('Retry')),
                        ],
                      ),
                    )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan Header Banner
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'CURRENT SELLER PLAN',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: Text(
                                    '${dashboard.activeAdsCount} / ${dashboard.adLimit} Ads Used',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  '${dashboard.sellerType} PLAN',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (dashboard.businessVerified) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.verified, color: Colors.amber, size: 22),
                                ],
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Progress Gauge Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: dashboard.adLimit > 0
                                    ? (dashboard.activeAdsCount / dashboard.adLimit).clamp(0.0, 1.0)
                                    : 0.0,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Metric Grid Cards
                      Text('Analytics & Activity', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.1,
                        children: [
                          _buildMetricCard('Total Ad Views', '${dashboard.totalViews}', Icons.visibility_outlined, Colors.blue),
                          _buildMetricCard('Active Ads', '${dashboard.activeAdsCount}', Icons.inventory_2_outlined, Colors.green),
                          _buildMetricCard('Featured Ads', '${dashboard.featuredAdsCount}', Icons.star_outline, Colors.amber),
                          _buildMetricCard('Promotions', '${dashboard.totalPromotionsCount}', Icons.campaign_outlined, Colors.purple),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Subscription Plans Upgrade Section
                      Text('Upgrade Seller Subscription', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Choose a plan that fits your selling business needs', style: AppTextStyles.productMeta.copyWith(fontSize: 12)),
                      const SizedBox(height: 16),

                      _buildRichPlanCard(
                        name: 'PREMIUM PLAN',
                        price: '₹499',
                        period: '/ month',
                        icon: Icons.bolt,
                        gradientColors: [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                        accentColor: const Color(0xFF2563EB),
                        featureList: const [
                          '25 Active Ads Listing Limit',
                          '5x Search & Category Visibility Boost',
                          'Featured Badge Credits Included',
                          'Detailed View Analytics & Lead Metrics',
                        ],
                        isCurrent: dashboard.sellerType == 'PREMIUM',
                        isPopular: true,
                        onTap: () => _upgradePlan('PREMIUM'),
                      ),

                      _buildRichPlanCard(
                        name: 'BUSINESS PRO PLAN',
                        price: '₹1,499',
                        period: '/ month',
                        icon: Icons.workspace_premium,
                        gradientColors: [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
                        accentColor: const Color(0xFF4F46E5),
                        featureList: const [
                          '100 Active Ads Listing Limit',
                          'Verified Business Badge on Profile & Ads',
                          'Top Placement Priority in Search Results',
                          'Dedicated Priority Support & Direct Enquiries',
                        ],
                        isCurrent: dashboard.sellerType == 'BUSINESS',
                        isPopular: false,
                        onTap: () => _upgradePlan('BUSINESS'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichPlanCard({
    required String name,
    required String price,
    required String period,
    required IconData icon,
    required List<Color> gradientColors,
    required Color accentColor,
    required List<String> featureList,
    required bool isCurrent,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? accentColor
              : isPopular
                  ? const Color(0xFF2563EB).withValues(alpha: 0.5)
                  : AppColors.divider,
          width: isCurrent || isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isPopular || isCurrent ? 0.15 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'ACTIVE PLAN',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'MOST POPULAR',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Price & Features Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      period,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Features Checklist
                ...featureList.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, size: 14, color: accentColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrent
                          ? Colors.grey.shade200
                          : accentColor,
                      foregroundColor: isCurrent ? Colors.grey.shade600 : Colors.white,
                      elevation: isCurrent ? 0 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isCurrent ? null : onTap,
                    child: Text(
                      isCurrent
                          ? 'Current Active Plan'
                          : 'Upgrade to $name',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
