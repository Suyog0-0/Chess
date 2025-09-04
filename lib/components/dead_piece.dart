import 'package:flutter/material.dart';

class DeadPiece extends StatelessWidget {
  final String imagePath;
  final bool isWhite;

  const DeadPiece({
    super.key,
    required this.imagePath,
    required this.isWhite,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      color: isWhite ? Colors.grey[400] : Colors.grey[800],
    );
  }
}
