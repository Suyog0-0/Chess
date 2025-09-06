import 'package:suyog_chess_sc/components/piece.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final bool isCapturable;
  final void Function()? onTap;
  final bool isKingInCheck;
  final bool isDarkMode;
  final List<Color> boardColors;
  final bool isHintSource;
  final bool isHintDestination;

  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.isCapturable,
    required this.onTap,
    this.isKingInCheck = false,
    this.isDarkMode = true,
    this.boardColors = const [Colors.grey, Colors.black],
    this.isHintSource = false,
    this.isHintDestination = false,
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    // Updated priority order: hint source/destination > king in check > selected > capturable > valid move > normal color
    if (isHintSource || isHintDestination) {
      squareColor = Colors.blue[300]!.withOpacity(0.6);
    } else if (isKingInCheck) {
      squareColor = Colors.red[800];
    } else if (isSelected) {
      squareColor = Colors.green[800];
    } else if (isCapturable) {
      squareColor = Colors.red[400];
    } else if (isValidMove) {
      squareColor = Colors.green[400];
    } else {
      squareColor = isWhite ? boardColors[0] : boardColors[1];
    }

    return GestureDetector(
      onTap: onTap,
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
            // Hint destination circle (only shown if not already a blue background)
            if (isHintDestination && !isHintSource)
              Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  color: Colors.indigo[900],
                  shape: BoxShape.circle,
                ),
              ),

            // Valid move indicator (for normal moves)
            if (isValidMove && piece == null && !isHintDestination)
              Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  shape: BoxShape.circle,
                ),
              ),

            // Piece image
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