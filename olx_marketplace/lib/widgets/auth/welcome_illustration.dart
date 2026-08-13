import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  WELCOME VECTOR STORE ILLUSTRATION WIDGET
//  Scales proportionately with FittedBox,
//  providing clean margins and spacing.
// ─────────────────────────────────────────────

class WelcomeIllustration extends StatelessWidget {
  const WelcomeIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 340,
            height: 250,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Soft Cloud Background Shape
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CloudBgPainter(),
                  ),
                ),

                // 2. Central Smartphone Store
                Positioned(
                  left: 115,
                  top: 32,
                  width: 110,
                  height: 195,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF0066FF), width: 2.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A0066FF),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Column(
                        children: [
                          // Store Striped Awning Top
                          SizedBox(
                            height: 28,
                            child: Row(
                              children: List.generate(5, (index) {
                                return Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: index.isEven
                                          ? const Color(0xFF0066FF)
                                          : Colors.white,
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Shirt card inside phone screen
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F5FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.checkroom_rounded, color: Color(0xFF0066FF), size: 28),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(width: 22, height: 4, decoration: BoxDecoration(color: const Color(0xFF0066FF), borderRadius: BorderRadius.circular(2))),
                                    const SizedBox(width: 4),
                                    Container(width: 10, height: 4, decoration: BoxDecoration(color: const Color(0xFF0066FF).withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Lower product card inside phone screen
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F5FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.dry_cleaning_rounded, color: Color(0xFF0066FF), size: 22),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Floating Left Product Card (Blue Hanger)
                Positioned(
                  left: 18,
                  top: 65,
                  child: Container(
                    width: 62,
                    height: 66,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5EDFF), width: 1.2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0C0066FF), blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.checkroom_rounded, color: Color(0xFF0066FF), size: 34),
                    ),
                  ),
                ),

                // 4. Floating Right Product Card (Red Clothing/Tag)
                Positioned(
                  right: 18,
                  top: 60,
                  child: Container(
                    width: 58,
                    height: 62,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5EDFF), width: 1.2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0C0066FF), blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.style_rounded, color: Color(0xFFFF4D4D), size: 30),
                    ),
                  ),
                ),

                // 5. Floating Badges
                Positioned(
                  left: 157,
                  top: 4,
                  child: _buildBadge(Icons.card_giftcard_rounded, const Color(0xFF0066FF)),
                ),

                Positioned(
                  left: 218,
                  top: 55,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF4FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '\$',
                      style: TextStyle(
                        color: Color(0xFF0066FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 48,
                  top: 135,
                  child: _buildBadge(Icons.shopping_cart_outlined, const Color(0xFF0066FF)),
                ),

                // 6. Left Blue Figure
                Positioned(
                  left: 24,
                  bottom: 12,
                  child: Container(
                    width: 24,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 16),
                    ),
                  ),
                ),

                // 7. Gold Coins
                Positioned(
                  left: 58,
                  bottom: 14,
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFC107),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 2)],
                        ),
                        child: const Center(
                          child: Text(
                            '\$',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-6, 3),
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB300),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 8. Middle Orange Figure & Cart
                Positioned(
                  left: 108,
                  bottom: 12,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 22,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252),
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.shopping_cart_outlined, color: Color(0xFF0066FF), size: 24),
                    ],
                  ),
                ),

                // 9. Right Sitting Figure & Laptop
                Positioned(
                  right: 18,
                  bottom: 12,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(Icons.laptop_mac_rounded, color: Color(0xFF1A1A2E), size: 22),
                      const SizedBox(width: 6),
                      Container(
                        width: 22,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          borderRadius: BorderRadius.circular(11),
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
    );
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5EDFF), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x0C0066FF), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: color, size: 14),
    );
  }
}

class _CloudBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF3F7FE)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.12, size.height * 0.45);
    path.cubicTo(
      size.width * 0.05, size.height * 0.12,
      size.width * 0.38, size.height * 0.02,
      size.width * 0.5, size.height * 0.15,
    );
    path.cubicTo(
      size.width * 0.62, size.height * 0.02,
      size.width * 0.95, size.height * 0.12,
      size.width * 0.88, size.height * 0.55,
    );
    path.cubicTo(
      size.width * 0.96, size.height * 0.88,
      size.width * 0.65, size.height * 0.96,
      size.width * 0.5, size.height * 0.9,
    );
    path.cubicTo(
      size.width * 0.15, size.height * 0.96,
      size.width * 0.02, size.height * 0.72,
      size.width * 0.12, size.height * 0.45,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
