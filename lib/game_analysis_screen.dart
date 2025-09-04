// Add this new file: game_analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:suyog_chess_sc/game_board.dart';
import 'package:suyog_chess_sc/components/piece.dart'; // Add this import


class GameAnalysisScreen extends StatefulWidget {
  final List<MoveHistory> moveHistory;
  final bool isWhiteWinner;
  final bool isStalemate;

  const GameAnalysisScreen({
    super.key,
    required this.moveHistory,
    required this.isWhiteWinner,
    required this.isStalemate,
  });

  @override
  State<GameAnalysisScreen> createState() => _GameAnalysisScreenState();
}

class _GameAnalysisScreenState extends State<GameAnalysisScreen> {
  int _selectedMoveIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Game Analysis'),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with game result
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isStalemate
                      ? Icons.handshake
                      : Icons.emoji_events,
                  color: widget.isStalemate
                      ? Colors.blue
                      : (widget.isWhiteWinner ? Colors.white : Colors.black),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.isStalemate
                      ? 'Game ended in stalemate'
                      : '${widget.isWhiteWinner ? 'White' : 'Black'} won',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Move list
          Expanded(
            child: ListView.builder(
              itemCount: widget.moveHistory.length,
              itemBuilder: (context, index) {
                final move = widget.moveHistory[index];
                final moveNumber = index + 1;
                final isWhiteMove = moveNumber % 2 == 1;

                return _buildMoveItem(move, moveNumber, isWhiteMove, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveItem(MoveHistory move, int moveNumber, bool isWhiteMove, int index) {
    final isSelected = _selectedMoveIndex == index;
    final moveQuality = _evaluateMoveQuality(move);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMoveIndex = index;
        });
      },
      child: Container(
        color: isSelected ? Colors.blue[800] : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Move number
            SizedBox(
              width: 40,
              child: Text(
                '$moveNumber.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Move notation
            Expanded(
              child: Text(
                _getMoveNotation(move),
                style: TextStyle(
                  color: isWhiteMove ? Colors.white : Colors.grey[300],
                  fontSize: 16,
                ),
              ),
            ),

            // Move quality indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getQualityColor(moveQuality),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                moveQuality,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Best move suggestion (if not best move)
            if (moveQuality != 'Best')
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  'Best: ${_getBestMoveSuggestion(move)}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getMoveNotation(MoveHistory move) {
    final fromSquare = _convertToAlgebraic(move.fromRow, move.fromCol);
    final toSquare = _convertToAlgebraic(move.toRow, move.toCol);
    final pieceSymbol = _getPieceSymbol(move.movedPiece!.type);

    return '$pieceSymbol$fromSquare-$toSquare';
  }

  String _convertToAlgebraic(int row, int col) {
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    final ranks = ['8', '7', '6', '5', '4', '3', '2', '1'];
    return '${files[col]}${ranks[row]}';
  }

  String _getPieceSymbol(ChessPieceType type) {
    switch (type) {
      case ChessPieceType.king: return 'K';
      case ChessPieceType.queen: return 'Q';
      case ChessPieceType.rook: return 'R';
      case ChessPieceType.bishop: return 'B';
      case ChessPieceType.knight: return 'N';
      case ChessPieceType.pawn: return '';
    }
  }

  String _evaluateMoveQuality(MoveHistory move) {
    // Simple evaluation logic - in a real app, this would use a chess engine
    final random = move.fromRow + move.fromCol + move.toRow + move.toCol;
    final qualityIndex = random % 3;

    switch (qualityIndex) {
      case 0: return 'Best';
      case 1: return 'Good';
      case 2: return 'Mistake';
      default: return 'Good';
    }
  }

  Color _getQualityColor(String quality) {
    switch (quality) {
      case 'Best': return Colors.green;
      case 'Good': return Colors.blue;
      case 'Mistake': return Colors.orange;
      case 'Blunder': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getBestMoveSuggestion(MoveHistory move) {
    // Simple best move suggestion - in a real app, this would use a chess engine
    final fromSquare = _convertToAlgebraic(move.fromRow, move.fromCol);
    final bestRow = (move.toRow + 1) % 8;
    final bestCol = (move.toCol + 1) % 8;
    final bestSquare = _convertToAlgebraic(bestRow, bestCol);

    return '$fromSquare-$bestSquare';
  }
}