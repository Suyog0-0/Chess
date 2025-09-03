import 'package:flutter/material.dart';
import 'package:suyog_chess_sc/components/piece.dart';
import 'package:suyog_chess_sc/components/square.dart';
import 'package:suyog_chess_sc/helper/helper_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'components/dead_piece.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // Existing variables
  late List<List<ChessPiece?>> board;
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  List<List<int>> validMoves = [];
  final List<ChessPiece> whitePiecesTaken = [];
  final List<ChessPiece> blackPiecesTaken = [];
  bool isWhiteTurn = true;
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  // Enhanced variables
  bool isDarkMode = true;
  bool soundEnabled = true;
  int moveCount = 0;
  DateTime? gameStartTime;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  // AI and game mode
  bool isPlayingAgainstAI = false;
  bool isAIThinking = false;

  // Theme customization
  int selectedBoardTheme = 0;
  int selectedBackgroundTheme = 0;

  // Coordinates display
  bool showCoordinates = true;

  // Pawn promotion
  bool isPromoting = false;
  int promotionRow = -1;
  int promotionCol = -1;
  bool isWhitePromoting = true;

  final List<List<Color>> boardThemes = [
    [Colors.grey[300]!, Colors.grey[700]!], // Default
    [const Color(0xFFF0D9B5), const Color(0xFFB58863)], // Classic wood
    [const Color(0xFFE8EBF0), const Color(0xFF7D8796)], // Blue gray
    [const Color(0xFFFCE4EC), const Color(0xFFE91E63)], // Pink
    [const Color(0xFFE8F5E8), const Color(0xFF4CAF50)], // Green
    [const Color(0xFFFFF3E0), const Color(0xFFFF9800)], // Orange
  ];

  final List<Color> backgroundThemes = [
    Colors.grey[900]!, // Default dark
    const Color(0xFF2C1810), // Dark wood
    const Color(0xFF1A237E), // Deep blue
    const Color(0xFF4A148C), // Deep purple
    const Color(0xFF1B5E20), // Deep green
    const Color(0xFFBF360C), // Deep orange,
  ];

  // Castling tracking
  bool whiteKingMoved = false;
  bool blackKingMoved = false;
  bool whiteLeftRookMoved = false;
  bool whiteRightRookMoved = false;
  bool blackLeftRookMoved = false;
  bool blackRightRookMoved = false;

  // Game state
  bool isGameOver = false;
  String? winner;

  @override
  void initState() {
    super.initState();
    gameStartTime = DateTime.now();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadSettings();
    _initializeBoard();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('dark_mode') ?? true;
      soundEnabled = prefs.getBool('sound_enabled') ?? true;
      selectedBoardTheme = prefs.getInt('board_theme') ?? 0;
      selectedBackgroundTheme = prefs.getInt('background_theme') ?? 0;
      isPlayingAgainstAI = prefs.getBool('ai_mode') ?? false;
      showCoordinates = prefs.getBool('show_coordinates') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDarkMode);
    await prefs.setBool('sound_enabled', soundEnabled);
    await prefs.setInt('board_theme', selectedBoardTheme);
    await prefs.setInt('background_theme', selectedBackgroundTheme);
    await prefs.setBool('ai_mode', isPlayingAgainstAI);
    await prefs.setBool('show_coordinates', showCoordinates);
  }

  Future<void> _playSound(String soundFile) async {
    if (soundEnabled) {
      try {
        // Use proper asset path for web compatibility
        await _audioPlayer.play(AssetSource(soundFile));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Audio error: $e');
        }
        // Fallback: try without sounds/ prefix
        try {
          await _audioPlayer.play(AssetSource('sounds/$soundFile'));
        } catch (e2) {
          if (kDebugMode) {
            debugPrint('Audio fallback error: $e2');
          }
        }
      }
    }
  }

  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // Placing pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'lib/images/pawn.png');
      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'lib/images/pawn.png');
    }

    // Placing Rooks
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png');
    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png');
    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png');
    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png');

    // Placing Knights
    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');
    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');

    // Placing Bishops
    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');
    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');

    // Placing Queens
    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'lib/images/queen.png');
    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'lib/images/queen.png');

    // Placing Kings
    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'lib/images/king.png');
    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'lib/images/king.png');

    board = newBoard;

    // Reset game state
    whiteKingMoved = false;
    blackKingMoved = false;
    whiteLeftRookMoved = false;
    whiteRightRookMoved = false;
    blackLeftRookMoved = false;
    blackRightRookMoved = false;
    isGameOver = false;
    winner = null;
  }

  // Simple AI implementation
  Future<void> _makeAIMove() async {
    if (!isPlayingAgainstAI || isWhiteTurn || isGameOver) return;

    setState(() {
      isAIThinking = true;
    });

    await Future.delayed(const Duration(milliseconds: 800)); // Thinking delay

    final allPossibleMoves = <Map<String, dynamic>>[];

    // Get all possible moves for black pieces
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && !piece.isWhite) {
          final moves = calculateValidMoves(row, col, piece);
          for (final move in moves) {
            allPossibleMoves.add({
              'fromRow': row,
              'fromCol': col,
              'toRow': move[0],
              'toCol': move[1],
              'piece': piece,
              'capturesOpponent': board[move[0]][move[1]] != null,
            });
          }
        }
      }
    }

    if (allPossibleMoves.isNotEmpty) {
      // Simple AI logic: prioritize captures, then random moves
      final captureMoves =
          allPossibleMoves.where((move) => move['capturesOpponent']).toList();
      final selectedMove = captureMoves.isNotEmpty
          ? captureMoves[Random().nextInt(captureMoves.length)]
          : allPossibleMoves[Random().nextInt(allPossibleMoves.length)];

      setState(() {
        selectedPiece = selectedMove['piece'] as ChessPiece;
        selectedRow = selectedMove['fromRow'] as int;
        selectedCol = selectedMove['fromCol'] as int;
        validMoves = [
          [selectedMove['toRow'] as int, selectedMove['toCol'] as int]
        ];
      });

      await Future.delayed(const Duration(milliseconds: 300));
      movePiece(selectedMove['toRow'] as int, selectedMove['toCol'] as int);
    }

    setState(() {
      isAIThinking = false;
    });
  }

  bool _isCheckmate(bool isWhite) {
    // Check if the king is in check
    if (!isKingInCheck(isWhite)) return false;

    // Check if any move can get the king out of check
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.isWhite == isWhite) {
          final moves = calculateValidMoves(row, col, piece);
          if (moves.isNotEmpty) return false;
        }
      }
    }
    return true;
  }

  void pieceSelected(int row, int col) {
    if (isGameOver || (isPlayingAgainstAI && !isWhiteTurn) || isPromoting)
      return;

    setState(() {
      // If no piece is selected yet
      if (selectedPiece == null) {
        if (board[row][col] != null) {
          // Check if it's the correct player's turn
          if (board[row][col]!.isWhite == isWhiteTurn) {
            selectedPiece = board[row][col];
            selectedRow = row;
            selectedCol = col;
            validMoves = calculateValidMoves(row, col, selectedPiece!);
          }
        }
      }
      // If a piece is already selected
      else {
        // If clicking on another piece of the same color and same player's turn
        if (board[row][col] != null &&
            board[row][col]!.isWhite == selectedPiece!.isWhite &&
            board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
          validMoves = calculateValidMoves(row, col, selectedPiece!);
        }
        // If clicking on a valid move square
        else if (validMoves.any((move) => move[0] == row && move[1] == col)) {
          movePiece(row, col);
        }
        // If clicking elsewhere, deselect
        else {
          selectedPiece = null;
          selectedRow = -1;
          selectedCol = -1;
          validMoves = [];
        }
      }
    });
  }

  List<List<int>> calculateValidMoves(int row, int col, ChessPiece piece) {
    List<List<int>> candidateMoves = calculateRawMoves(row, col, piece);

    // Filter out moves that would put king in check
    candidateMoves = candidateMoves.where((move) {
      return !wouldKingBeInCheck(row, col, move[0], move[1], piece);
    }).toList();

    return candidateMoves;
  }

  List<List<int>> calculateRawMoves(int row, int col, ChessPiece piece) {
    final candidateMoves = <List<int>>[];
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // Forward move
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);

          // Initial two-square move
          if ((row == 6 && piece.isWhite) || (row == 1 && !piece.isWhite)) {
            if (isInBoard(row + 2 * direction, col) &&
                board[row + 2 * direction][col] == null) {
              candidateMoves.add([row + 2 * direction, col]);
            }
          }
        }

        // Diagonal captures
        for (int i = -1; i <= 1; i += 2) {
          int newRow = row + direction;
          int newCol = col + i;

          if (isInBoard(newRow, newCol) &&
              board[newRow][newCol] != null &&
              board[newRow][newCol]!.isWhite != piece.isWhite) {
            candidateMoves.add([newRow, newCol]);
          }
        }
        break;

      case ChessPieceType.rook:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1]
        ];
        for (var dir in directions) {
          for (int i = 1; i < 8; i++) {
            int newRow = row + i * dir[0];
            int newCol = col + i * dir[1];
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
          }
        }
        break;

      case ChessPieceType.knight:
        var knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1]
        ];
        for (var move in knightMoves) {
          int newRow = row + move[0];
          int newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) continue;
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;

      case ChessPieceType.bishop:
        var directions = [
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1]
        ];
        for (var dir in directions) {
          for (int i = 1; i < 8; i++) {
            int newRow = row + i * dir[0];
            int newCol = col + i * dir[1];
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
          }
        }
        break;

      case ChessPieceType.queen:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1]
        ];
        for (var dir in directions) {
          for (int i = 1; i < 8; i++) {
            int newRow = row + i * dir[0];
            int newCol = col + i * dir[1];
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
          }
        }
        break;

      case ChessPieceType.king:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1]
        ];
        for (var dir in directions) {
          int newRow = row + dir[0];
          int newCol = col + dir[1];
          if (!isInBoard(newRow, newCol)) continue;
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
    }

    return candidateMoves;
  }

  bool wouldKingBeInCheck(
      int fromRow, int fromCol, int toRow, int toCol, ChessPiece piece) {
    // Simulate the move
    ChessPiece? originalPiece = board[toRow][toCol];
    board[toRow][toCol] = piece;
    board[fromRow][fromCol] = null;

    // Update king position if the moving piece is a king
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        originalKingPosition = List.from(whiteKingPosition);
        whiteKingPosition = [toRow, toCol];
      } else {
        originalKingPosition = List.from(blackKingPosition);
        blackKingPosition = [toRow, toCol];
      }
    }

    // Check if king would be in check
    bool inCheck = isKingInCheck(piece.isWhite);

    // Undo the move
    board[fromRow][fromCol] = piece;
    board[toRow][toCol] = originalPiece;

    // Restore king position if necessary
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    return inCheck;
  }

  bool isKingInCheck(bool isWhite) {
    List<int> kingPosition = isWhite ? whiteKingPosition : blackKingPosition;

    // Check for attacks from all opponent pieces
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = board[row][col];
        if (piece != null && piece.isWhite != isWhite) {
          List<List<int>> moves = calculateRawMoves(row, col, piece);
          if (moves.any((move) =>
              move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void movePiece(int newRow, int newCol) {
    // Check for pawn promotion
    if (selectedPiece!.type == ChessPieceType.pawn &&
        ((selectedPiece!.isWhite && newRow == 0) ||
            (!selectedPiece!.isWhite && newRow == 7))) {
      setState(() {
        isPromoting = true;
        promotionRow = newRow;
        promotionCol = newCol;
        isWhitePromoting = selectedPiece!.isWhite;
      });
      return;
    }

    // Handle captures
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
      _playSound('capture.mp3');
    } else {
      _playSound('move.mp3');
    }

    // Update king positions
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
        whiteKingMoved = true;
      } else {
        blackKingPosition = [newRow, newCol];
        blackKingMoved = true;
      }
    }

    // Update rook positions for castling
    if (selectedPiece!.type == ChessPieceType.rook) {
      if (selectedRow == 7 && selectedCol == 0) whiteLeftRookMoved = true;
      if (selectedRow == 7 && selectedCol == 7) whiteRightRookMoved = true;
      if (selectedRow == 0 && selectedCol == 0) blackLeftRookMoved = true;
      if (selectedRow == 0 && selectedCol == 7) blackRightRookMoved = true;
    }

    // Move the piece
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // Check for check
    checkStatus = isKingInCheck(!isWhiteTurn);

    if (checkStatus) {
      _playSound('check.mp3');
    }

    // Check for checkmate
    bool checkmate = _isCheckmate(!isWhiteTurn);
    if (checkmate) {
      setState(() {
        isGameOver = true;
        winner = isWhiteTurn ? 'White' : 'Black';
      });
      _showWinDialog();
      return;
    }

    // Switch turns
    isWhiteTurn = !isWhiteTurn;

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
      moveCount++;
    });

    // Make AI move if it's AI's turn
    if (isPlayingAgainstAI && !isWhiteTurn && !isGameOver) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _makeAIMove();
      });
    }
  }

  void promotePawn(ChessPieceType newType) {
    board[promotionRow][promotionCol] = ChessPiece(
      type: newType,
      isWhite: isWhitePromoting,
      imagePath: 'lib/images/${newType.toString().split('.').last}.png',
    );

    _playSound('move.mp3');

    // Check for check after promotion
    checkStatus = isKingInCheck(!isWhiteTurn);

    if (checkStatus) {
      _playSound('check.mp3');
    }

    // Check for checkmate
    bool checkmate = _isCheckmate(!isWhiteTurn);
    if (checkmate) {
      setState(() {
        isGameOver = true;
        winner = isWhiteTurn ? 'White' : 'Black';
        isPromoting = false;
      });
      _showWinDialog();
      return;
    }

    // Switch turns
    isWhiteTurn = !isWhiteTurn;

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
      moveCount++;
      isPromoting = false;
    });

    // Make AI move if it's AI's turn
    if (isPlayingAgainstAI && !isWhiteTurn && !isGameOver) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _makeAIMove();
      });
    }
  }

  void _showPromotionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundThemes[selectedBackgroundTheme],
        title: Text(
          'Promote Pawn',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose a piece to promote to:',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPromotionOption(ChessPieceType.queen, 'Queen'),
                _buildPromotionOption(ChessPieceType.rook, 'Rook'),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPromotionOption(ChessPieceType.bishop, 'Bishop'),
                _buildPromotionOption(ChessPieceType.knight, 'Knight'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionOption(ChessPieceType type, String label) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            promotePawn(type);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: Image.asset(
              'lib/images/${type.toString().split('.').last}.png',
              width: 40,
              height: 40,
              color: isWhitePromoting
                  ? (isDarkMode ? Colors.white : const Color(0xffcfcece))
                  : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showWinDialog() {
    _confettiController.play();
    _playSound('victory.mp3');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundThemes[selectedBackgroundTheme],
        title: Column(
          children: [
            const Icon(
              Icons.emoji_events,
              size: 60,
              color: Colors.amber,
            ),
            const SizedBox(height: 10),
            Text(
              'CHECKMATE!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$winner Wins!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Game Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildStatRow('Total Moves:', '$moveCount'),
                  _buildStatRow(
                      'Game Duration:',
                      _formatDuration(
                          DateTime.now().difference(gameStartTime!))),
                  _buildStatRow(
                      'White Pieces Captured:', '${whitePiecesTaken.length}'),
                  _buildStatRow(
                      'Black Pieces Captured:', '${blackPiecesTaken.length}'),
                  if (isPlayingAgainstAI) _buildStatRow('Opponent:', 'AI Bot'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child:
                const Text('Play Again', style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child:
                const Text('Main Menu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  void resetGame() {
    setState(() {
      _initializeBoard();
      checkStatus = false;
      whitePiecesTaken.clear();
      blackPiecesTaken.clear();
      whiteKingPosition = [7, 4];
      blackKingPosition = [0, 4];
      isWhiteTurn = true;
      moveCount = 0;
      gameStartTime = DateTime.now();
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
      isGameOver = false;
      winner = null;
      isPromoting = false;
    });
  }

  void _showNewGameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundThemes[selectedBackgroundTheme],
        title: const Text(
          'New Game',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Start a new game? Current progress will be lost.',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: isPlayingAgainstAI,
                  onChanged: (value) {
                    setState(() {
                      isPlayingAgainstAI = value ?? false;
                    });
                    _saveSettings();
                  },
                  activeColor: Colors.green,
                ),
                const Text(
                  'Play against AI',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child:
                const Text('New Game', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundThemes[selectedBackgroundTheme],
        title:
            const Text('Choose Theme', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Text('Board Colors',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemCount: boardThemes.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBoardTheme = index;
                        });
                        _saveSettings();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedBoardTheme == index
                                ? Colors.yellow
                                : Colors.grey,
                            width: selectedBoardTheme == index ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                          color: boardThemes[index][0])),
                                  Expanded(
                                      child: Container(
                                          color: boardThemes[index][1])),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                          color: boardThemes[index][1])),
                                  Expanded(
                                      child: Container(
                                          color: boardThemes[index][0])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text('Background Colors',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemCount: backgroundThemes.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBackgroundTheme = index;
                        });
                        _saveSettings();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: backgroundThemes[index],
                          border: Border.all(
                            color: selectedBackgroundTheme == index
                                ? Colors.yellow
                                : Colors.grey,
                            width: selectedBackgroundTheme == index ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // New method to toggle AI mode
  void _toggleAIMode() {
    setState(() {
      isPlayingAgainstAI = !isPlayingAgainstAI;
    });
    _saveSettings();
    resetGame();
  }

  // New method to toggle coordinates
  void _toggleCoordinates() {
    setState(() {
      showCoordinates = !showCoordinates;
    });
    _saveSettings();
  }

  // Build coordinate labels
  Widget _buildCoordinateLabel(bool isFile, int index) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        isFile
            ? String.fromCharCode('a'.codeUnitAt(0) + index)
            : '${8 - index}',
        style: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show promotion dialog if promoting
    if (isPromoting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPromotionDialog();
      });
    }

    return Scaffold(
      backgroundColor: backgroundThemes[selectedBackgroundTheme],
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.castle, color: isDarkMode ? Colors.white : Colors.black),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Suyog Chess',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                overflow: TextOverflow.ellipsis, // Shows … if space is tight
              ),
            ),
          ],
        ),



        actions: [
          // Coordinates toggle button
          IconButton(
            onPressed: _toggleCoordinates,
            icon: Icon(showCoordinates ? Icons.grid_on : Icons.grid_off),
            tooltip: showCoordinates ? 'Hide coordinates' : 'Show coordinates',
          ),
          // AI Mode Toggle Button
          IconButton(
            onPressed: _toggleAIMode,
            icon: Icon(isPlayingAgainstAI ? Icons.smart_toy : Icons.people),
            tooltip: isPlayingAgainstAI
                ? 'Playing against AI - Tap to play with friend'
                : 'Playing with friend - Tap to play against AI',
          ),
          IconButton(
            onPressed: _showThemeDialog,
            icon: const Icon(Icons.palette),
            tooltip: 'Change board theme',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    isDarkMode: isDarkMode,
                    soundEnabled: soundEnabled,
                    onThemeChanged: (value) {
                      setState(() {
                        isDarkMode = value;
                      });
                      _saveSettings();
                    },
                    onSoundChanged: (value) {
                      setState(() {
                        soundEnabled = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
              _saveSettings();
            },
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle dark mode',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.5708,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
            ),
          ),

          Column(
            children: [
              // Checkmate/Check status
              if (checkStatus || isGameOver)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isGameOver ? Colors.red[700] : Colors.orange[700],
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isGameOver ? 'CHECKMATE!' : 'CHECK!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // Game status and info
              Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${isWhiteTurn ? "White" : "Black"} to move',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (isPlayingAgainstAI && isAIThinking)
                          Text(
                            'AI is thinking...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.yellow,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Moves: $moveCount',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                          ),
                        ),
                        Text(
                          isPlayingAgainstAI ? 'vs AI' : 'vs Friend',
                          style: TextStyle(
                            fontSize: 12,
                            color: isPlayingAgainstAI
                                ? Colors.blue[300]
                                : Colors.green[300],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // White pieces taken
              SizedBox(
                height: 30,
                child: GridView.builder(
                  itemCount: whitePiecesTaken.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => DeadPiece(
                    imagePath: whitePiecesTaken[index].imagePath,
                    isWhite: true,
                  ),
                ),
              ),

              // Chess board with coordinates
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      // The chess board
                      GridView.builder(
                        itemCount: 8 * 8,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 8),
                        itemBuilder: (context, index) {
                          final row = index ~/ 8;
                          final col = index % 8;
                          final isSelected =
                              selectedRow == row && selectedCol == col;
                          final isValidMove = validMoves.any((position) =>
                              position[0] == row && position[1] == col);
                          final isCapturable = isValidMove &&
                              board[row][col] != null &&
                              board[row][col]!.isWhite != isWhiteTurn;

                          // FIXED: Only show check highlight for the king that is actually in check
                          bool isKingInCheck = false;
                          if (checkStatus) {
                            // White king is in check
                            if (isWhiteTurn &&
                                board[row][col]?.type == ChessPieceType.king &&
                                board[row][col]?.isWhite == true &&
                                row == whiteKingPosition[0] &&
                                col == whiteKingPosition[1]) {
                              isKingInCheck = true;
                            }
                            // Black king is in check
                            else if (!isWhiteTurn &&
                                board[row][col]?.type == ChessPieceType.king &&
                                board[row][col]?.isWhite == false &&
                                row == blackKingPosition[0] &&
                                col == blackKingPosition[1]) {
                              isKingInCheck = true;
                            }
                          }

                          return Square(
                            isWhite: isWhite(index),
                            piece: board[row][col],
                            isSelected: isSelected,
                            isValidMove: isValidMove,
                            isCapturable: isCapturable,
                            isKingInCheck: isKingInCheck,
                            onTap: () => pieceSelected(row, col),
                            isDarkMode: isDarkMode,
                            boardColors: boardThemes[selectedBoardTheme],
                          );
                        },
                      ),

                      // Coordinate labels
// Lines around 1350-1420
// Coordinate labels
                      if (showCoordinates) ...[
                        // Top coordinates (files a-h) - positioned outside the board
                        Positioned(
                          top: -20,
                          left: 0,
                          right: 0,
                          height: 20,
                          child: Row(
                            children: List.generate(
                                8,
                                (index) => Expanded(
                                      child: _buildCoordinateLabel(true, index),
                                    )),
                          ),
                        ),

                        // Bottom coordinates (files a-h) - positioned outside the board
                        Positioned(
                          bottom: -20,
                          left: 0,
                          right: 0,
                          height: 20,
                          child: Row(
                            children: List.generate(
                                8,
                                (index) => Expanded(
                                      child: _buildCoordinateLabel(true, index),
                                    )),
                          ),
                        ),

                        // Left coordinates (ranks 8-1) - positioned outside the board
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: -20,
                          width: 20,
                          child: Column(
                            children: List.generate(
                                8,
                                (index) => Expanded(
                                      child:
                                          _buildCoordinateLabel(false, index),
                                    )),
                          ),
                        ),

                        // Right coordinates (ranks 8-1) - positioned outside the board
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: -20,
                          width: 20,
                          child: Column(
                            children: List.generate(
                                8,
                                (index) => Expanded(
                                      child:
                                          _buildCoordinateLabel(false, index),
                                    )),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Black pieces taken
              SizedBox(
                height: 30,
                child: GridView.builder(
                  itemCount: blackPiecesTaken.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => DeadPiece(
                    imagePath: blackPiecesTaken[index].imagePath,
                    isWhite: false,
                  ),
                ),
              ),

              // Bottom action bar
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showNewGameDialog,
                      icon: const Icon(Icons.refresh),
                      label: const Text('New Game'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showThemeDialog,
                      icon: const Icon(Icons.palette),
                      label: const Text('Themes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Main Menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDarkMode ? Colors.grey[600] : Colors.grey[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}
