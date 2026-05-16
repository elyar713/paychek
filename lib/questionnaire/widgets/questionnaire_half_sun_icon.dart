import 'package:flutter/material.dart';

/// Soleil Material coupé en deux : moitié gauche blanche, moitié droite noire.
class QuestionnaireHalfSunIcon extends StatelessWidget {
  const QuestionnaireHalfSunIcon({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: _VerticalHalfClipper(leftHalf: true),
            child: Icon(Icons.wb_sunny, color: Colors.white, size: size),
          ),
          ClipPath(
            clipper: _VerticalHalfClipper(leftHalf: false),
            child: Icon(Icons.wb_sunny, color: Colors.black, size: size),
          ),
        ],
      ),
    );
  }
}

class _VerticalHalfClipper extends CustomClipper<Path> {
  _VerticalHalfClipper({required this.leftHalf});

  final bool leftHalf;

  @override
  Path getClip(Size size) {
    final path = Path();
    if (leftHalf) {
      path.addRect(Rect.fromLTWH(0, 0, size.width / 2, size.height));
    } else {
      path.addRect(Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height));
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
