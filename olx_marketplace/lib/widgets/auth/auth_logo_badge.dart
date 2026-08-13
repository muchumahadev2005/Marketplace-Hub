import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  AUTH LOGO BADGE (Tag Icon in Light Blue Circle)
// ─────────────────────────────────────────────

class AuthLogoBadge extends StatelessWidget {
  final double size;

  const AuthLogoBadge({
    super.key,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFEFF4FF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: const BoxDecoration(
            color: Color(0xFF0066FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_offer_rounded,
            color: Colors.white,
            size: size * 0.28,
          ),
        ),
      ),
    );
  }
}
