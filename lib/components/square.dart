import 'package:suyog_chess_sc/components/piece.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final bool isCapturable;
  final void Function()? onTap;
  final void Function()? onSecondaryTap; // NEW: Add this line
  final bool isKingInCheck;
  final bool isDarkMode;
  final List<Color> boardColors;
  final bool isHint;
  final bool isPreMove; // NEW: Add this line

  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.isCapturable,
    required this.onTap,
    this.onSecondaryTap, // NEW: Add this line
    this.isKingInCheck = false,
    this.isDarkMode = true,
    this.boardColors = const [Colors.grey, Colors.black],
    this.isHint = false,
    this.isPreMove = false, // NEW: Add this line
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    // UPDATED: Add pre-move to priority order
    // Priority order: hint > king in check > selected > pre-move > capturable > valid move > normal color
    if (isHint) {
      squareColor = Colors.blue[300]!.withOpacity(0.6);
    } else if (isKingInCheck) {
      squareColor = Colors.red[800];
    } else if (isSelected) {
      squareColor = Colors.green[800];
    } else if (isPreMove) { // NEW: Add this condition
      squareColor = Colors.purple[400]!.withOpacity(0.7);
    } else if (isCapturable) {
      squareColor = Colors.red[400];
    } else if (isValidMove) {
      squareColor = Colors.green[400];
    } else {
      squareColor = isWhite ? boardColors[0] : boardColors[1];
    }

    return GestureDetector(
      onTap: onTap,
      onSecondaryTap: onSecondaryTap, // NEW: Add this line
      child: Container(
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: squareColor,
          border: Border.all(
            color: squareColor!,
            width: 0.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isValidMove && piece == null)
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  shape: BoxShape.circle,
                ),
              ),
            // NEW: Add pre-move indicator
            if (isPreMove && piece != null)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.purple[600],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 8,
                  ),
                ),
              ),
            if (piece != null)
              Container(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  piece!.imagePath,
                  color: isDarkMode
                      ? (piece!.isWhite ? Colors.white : Colors.black)
                      : (piece!.isWhite
                      ? const Color(0xfff6f6f6)
                      : Colors.black),
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}