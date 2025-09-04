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
  // Board state
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

  // UI settings
  bool showCoordinates = true;
  bool showHints = true;

  // Hint system
  List<int>? hintMove; // [fromRow, fromCol, toRow, toCol]
  bool isCalculatingHint = false;

  List<MoveHistory> moveHistory = [];
  bool _isUndoInProgress = false;

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
    const Color(0xFFBF360C), // Deep orange
    Colors.teal[800]!, // Teal (matching settings)
    Colors.brown[800]!, // Brown (matching settings)
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
      showHints = prefs.getBool('show_hints') ?? true;
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
    await prefs.setBool('show_hints', showHints);
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
    hintMove = null;
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
      // Clear any hint when selecting a piece
      hintMove = null;

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
    // Clear any hint when making a move
    if (_isUndoInProgress) return;
    moveHistory.add(MoveHistory(
      movedPiece: selectedPiece,
      capturedPiece: board[newRow][newCol],
      fromRow: selectedRow,
      fromCol: selectedCol,
      toRow: newRow,
      toCol: newCol,
      wasKingMove: selectedPiece!.type == ChessPieceType.king,
      wasRookMove: selectedPiece!.type == ChessPieceType.rook,
      wasCheck: checkStatus,
      wasCheckmate: isGameOver,
    ));

    setState(() {
      hintMove = null;
    });

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

  void _undoMove() {
    if (moveHistory.isEmpty || isAIThinking || isPromoting) return;

    setState(() {
      _isUndoInProgress = true;

      // Get and remove the last move
      if (moveHistory.isNotEmpty) {
        MoveHistory lastMove = moveHistory.removeLast();

        // Restore the board
        board[lastMove.fromRow][lastMove.fromCol] = lastMove.movedPiece;
        board[lastMove.toRow][lastMove.toCol] = lastMove.capturedPiece;

        // Handle captured piece restoration
        if (lastMove.capturedPiece != null) {
          if (lastMove.capturedPiece!.isWhite) {
            whitePiecesTaken.removeLast();
          } else {
            blackPiecesTaken.removeLast();
          }
        }

        // Update king positions for king moves or castling
        if (lastMove.wasKingMove) {
          if (lastMove.movedPiece!.isWhite) {
            whiteKingPosition = [lastMove.fromRow, lastMove.fromCol];
            whiteKingMoved =
            !whiteKingMoved; // Toggle to reflect pre-move state
            // Handle castling (if implemented)
            if (lastMove.wasCastling) {
              // Add logic to move rook back (e.g., kingside or queenside)
              if (lastMove.fromCol == 4 && lastMove.toCol == 6) {
                board[7][5] = null;
                board[7][7] = ChessPiece(
                  type: ChessPieceType.rook,
                  isWhite: true,
                  imagePath: 'lib/images/rook.png',
                );
                whiteRightRookMoved = false;
              } else if (lastMove.fromCol == 4 && lastMove.toCol == 2) {
                board[7][3] = null;
                board[7][0] = ChessPiece(
                  type: ChessPieceType.rook,
                  isWhite: true,
                  imagePath: 'lib/images/rook.png',
                );
                whiteLeftRookMoved = false;
              }
            }
          } else {
            blackKingPosition = [lastMove.fromRow, lastMove.fromCol];
            blackKingMoved = !blackKingMoved;
            if (lastMove.wasCastling) {
              if (lastMove.fromCol == 4 && lastMove.toCol == 6) {
                board[0][5] = null;
                board[0][7] = ChessPiece(
                  type: ChessPieceType.rook,
                  isWhite: false,
                  imagePath: 'lib/images/rook.png',
                );
                blackRightRookMoved = false;
              } else if (lastMove.fromCol == 4 && lastMove.toCol == 2) {
                board[0][3] = null;
                board[0][0] = ChessPiece(
                  type: ChessPieceType.rook,
                  isWhite: false,
                  imagePath: 'lib/images/rook.png',
                );
                blackLeftRookMoved = false;
              }
            }
          }
        }

        // Update rook moved status
        if (lastMove.wasRookMove) {
          if (lastMove.fromRow == 7 && lastMove.fromCol == 0)
            whiteLeftRookMoved = !whiteLeftRookMoved;
          if (lastMove.fromRow == 7 && lastMove.fromCol == 7)
            whiteRightRookMoved = !whiteRightRookMoved;
          if (lastMove.fromRow == 0 && lastMove.fromCol == 0)
            blackLeftRookMoved = !blackLeftRookMoved;
          if (lastMove.fromRow == 0 && lastMove.fromCol == 7)
            blackRightRookMoved = !blackRightRookMoved;
        }

        // Restore game state
        isWhiteTurn = !isWhiteTurn;
        moveCount--;
        checkStatus = isKingInCheck(!isWhiteTurn); // Recalculate check
        isGameOver = _isCheckmate(!isWhiteTurn); // Recalculate checkmate
        winner = isGameOver ? (isWhiteTurn ? 'Black' : 'White') : null;

        // Clear selection
        selectedPiece = null;
        selectedRow = -1;
        selectedCol = -1;
        validMoves = [];
        hintMove = null; // Clear hint after undo

        _isUndoInProgress = false;
      }
    });

    _playSound('move.mp3');
  }

  void promotePawn(ChessPieceType newType) {
    board[promotionRow][promotionCol] = ChessPiece(
      type: newType,
      isWhite: isWhitePromoting,
      imagePath: 'lib/images/${newType.toString().split('.').last}.png',
    );

    _playSound('promote.mp3');

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

  Widget _buildEnhancedActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required bool isDisabled,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.grey[700]
                : color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDisabled
                  ? Colors.grey[600]!
                  : color.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              size: 22,
              color: isDisabled
                  ? Colors.grey[500]
                  : color,
            ),
            onPressed: onPressed,
            tooltip: label,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDisabled
                ? Colors.grey[500]
                : Colors.grey[300],
          ),
        ),
      ],
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
      hintMove = null;
      moveHistory.clear();
    });
  }

  void _showNewGameDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: backgroundThemes[selectedBackgroundTheme],
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: backgroundThemes[selectedBackgroundTheme],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title with icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.sports_esports,
                        color: Colors.green,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'New Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Enhanced divider
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey[600]!,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Warning message with better styling
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Starting a new game will reset current progress',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Game mode selection with improved design
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[700]!.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          'Game Mode',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // VS Friend Option
                      GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            isPlayingAgainstAI = false;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: !isPlayingAgainstAI
                                ? Colors.green.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !isPlayingAgainstAI
                                  ? Colors.green
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: !isPlayingAgainstAI
                                      ? Colors.green
                                      : Colors.grey[700],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.people,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'vs Friend',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Play with another person',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isPlayingAgainstAI)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),

                      // VS AI Option
                      GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            isPlayingAgainstAI = true;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isPlayingAgainstAI
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isPlayingAgainstAI
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isPlayingAgainstAI
                                      ? Colors.blue
                                      : Colors.grey[700],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.smart_toy,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'vs AI Bot',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Challenge the computer',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isPlayingAgainstAI)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Enhanced buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey[600]!, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Apply the selected AI mode from dialog state
                            // (isPlayingAgainstAI is already set by the dialog)
                          });
                          _saveSettings();
                          Navigator.pop(context);
                          resetGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: Colors.green.withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Start Game',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    int tempBoardTheme = selectedBoardTheme;
    int tempBackgroundTheme = selectedBackgroundTheme;

    // Theme names for better UX
    final List<String> boardThemeNames = [
      'Classic Gray',
      'Wooden Brown',
      'Blue Slate',
      'Pink Rose',
      'Forest Green',
      'Amber Gold',
    ];

    final List<String> backgroundThemeNames = [
      'Midnight',
      'Dark Wood',
      'Deep Ocean',
      'Royal Purple',
      'Forest',
      'Crimson',
      'Teal Ocean',
      'Rich Brown',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  color: backgroundThemes[tempBackgroundTheme],
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 10,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Enhanced Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.purple.shade600,
                              Colors.blue.shade600,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.palette,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Themes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    'Choose your perfect color combination',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content Area
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Board Themes Section
                              _buildThemeSection(
                                title: 'Chess Board Colors',
                                icon: Icons.grid_view,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                      const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.85,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                      ),
                                      itemCount: boardThemes.length,
                                      itemBuilder: (context, index) {
                                        final isSelected =
                                            tempBoardTheme == index;
                                        return GestureDetector(
                                          onTap: () {
                                            setStateDialog(() {
                                              tempBoardTheme = index;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.amber
                                                  .withOpacity(0.2)
                                                  : Colors.black
                                                  .withOpacity(0.1),
                                              borderRadius:
                                              BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.amber
                                                    : Colors.grey[600]!,
                                                width: isSelected ? 3 : 1,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                BoxShadow(
                                                  color: Colors.amber
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                                  : null,
                                            ),
                                            child: Column(
                                              children: [
                                                // Chess board preview
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8),
                                                      border: Border.all(
                                                        color:
                                                        Colors.grey[400]!,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8),
                                                      child: GridView.builder(
                                                        physics:
                                                        const NeverScrollableScrollPhysics(),
                                                        gridDelegate:
                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 4,
                                                        ),
                                                        itemCount: 16,
                                                        itemBuilder: (context,
                                                            squareIndex) {
                                                          final row =
                                                              squareIndex ~/ 4;
                                                          final col =
                                                              squareIndex % 4;
                                                          final isWhiteSquare =
                                                              (row + col) % 2 ==
                                                                  0;
                                                          return Container(
                                                            color: isWhiteSquare
                                                                ? boardThemes[
                                                            index][0]
                                                                : boardThemes[
                                                            index][1],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  boardThemeNames[index],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                if (isSelected)
                                                  Container(
                                                    margin:
                                                    const EdgeInsets.only(
                                                        top: 4),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                    ),
                                                    child: Text(
                                                      'SELECTED',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 9,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Background Themes Section - FIXED VERSION
                              _buildThemeSection(
                                title: 'Background Colors',
                                icon: Icons.format_paint,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                      const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio:
                                        0.7, // Changed from 1.1 to 0.9
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                      ),
                                      itemCount: backgroundThemes.length,
                                      itemBuilder: (context, index) {
                                        final isSelected =
                                            tempBackgroundTheme == index;
                                        return GestureDetector(
                                          onTap: () {
                                            setStateDialog(() {
                                              tempBackgroundTheme = index;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            padding: const EdgeInsets.all(
                                                4), // Changed from 6 to 4
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.blue.withOpacity(0.2)
                                                  : Colors.black
                                                  .withOpacity(0.1),
                                              borderRadius:
                                              BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.blue
                                                    : Colors.grey[600]!,
                                                width: isSelected ? 3 : 1,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                BoxShadow(
                                                  color: Colors.blue
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                                  : null,
                                            ),
                                            child: Column(
                                              mainAxisSize:
                                              MainAxisSize.min, // Added
                                              children: [
                                                // Fixed height background color preview - CHANGED TO EXPANDED
                                                Expanded(
                                                  flex:
                                                  3, // Takes 3/5 of available space
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: backgroundThemes[
                                                      index],
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.3),
                                                        width: 2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.3),
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height:
                                                    4), // Changed from 6 to 4
                                                // Text and selected indicator - WRAPPED IN EXPANDED
                                                Expanded(
                                                  flex:
                                                  2, // Takes 2/5 of available space
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Text(
                                                        backgroundThemeNames[
                                                        index],
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize:
                                                          8, // Reduced further to make space
                                                          fontWeight: isSelected
                                                              ? FontWeight.bold
                                                              : FontWeight.w500,
                                                        ),
                                                        textAlign:
                                                        TextAlign.center,
                                                        maxLines:
                                                        1, // Changed to 1 line only
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      if (isSelected) ...[
                                                        const SizedBox(
                                                            height: 2),
                                                        Container(
                                                          padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                            horizontal: 3,
                                                            vertical: 1,
                                                          ),
                                                          decoration:
                                                          BoxDecoration(
                                                            color: Colors.blue,
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                4),
                                                          ),
                                                          child: Text(
                                                            'ACTIVE',
                                                            style: TextStyle(
                                                              color:
                                                              Colors.white,
                                                              fontSize:
                                                              5, // Made even smaller
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ] else ...[
                                                        // Add invisible spacer when not selected to maintain consistent height
                                                        const SizedBox(
                                                            height: 1),
                                                        Container(
                                                          height:
                                                          10, // Reduced from 12 to 10
                                                          width: 1,
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Action Buttons
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                      color: Colors.grey[500]!, width: 2),
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.close, size: 18),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedBoardTheme = tempBoardTheme;
                                    selectedBackgroundTheme =
                                        tempBackgroundTheme;
                                  });
                                  _saveSettings();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.green.withOpacity(0.3),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check, size: 18),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Apply Theme',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper method for theme sections
  Widget _buildThemeSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[600]!.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  // Simple evaluation function to score the board
  double _evaluateBoard(List<List<ChessPiece?>> board) {
    double score = 0;

    // Piece values
    const Map<ChessPieceType, double> pieceValues = {
      ChessPieceType.pawn: 1,
      ChessPieceType.knight: 3,
      ChessPieceType.bishop: 3.5,
      ChessPieceType.rook: 5,
      ChessPieceType.queen: 9,
      ChessPieceType.king: 100,
    };

    // Count material
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null) {
          final value = pieceValues[piece.type]!;
          score += piece.isWhite ? value : -value;
        }
      }
    }

    return score;
  }

  // Minimax algorithm with alpha-beta pruning
  Map<String, dynamic> _minimax(
      int depth, bool isMaximizing, double alpha, double beta) {
    // Base case: reached maximum depth or game over
    if (depth == 0) {
      return {'score': _evaluateBoard(board)};
    }

    // Get all possible moves for current player
    List<Map<String, dynamic>> allMoves = [];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.isWhite == isMaximizing) {
          final moves = calculateValidMoves(row, col, piece);
          for (final move in moves) {
            allMoves.add({
              'fromRow': row,
              'fromCol': col,
              'toRow': move[0],
              'toCol': move[1],
              'piece': piece,
            });
          }
        }
      }
    }

    // Sort moves to improve alpha-beta pruning (captures first)
    allMoves.sort((a, b) {
      final aCapture = board[a['toRow']][a['toCol']] != null;
      final bCapture = board[b['toRow']][b['toCol']] != null;
      if (aCapture && !bCapture) return -1;
      if (!aCapture && bCapture) return 1;
      return 0;
    });

    Map<String, dynamic> bestMove = {
      'score': isMaximizing ? double.negativeInfinity : double.infinity
    };

    for (final move in allMoves) {
      // Simulate move
      final originalPiece = board[move['toRow']][move['toCol']];
      board[move['toRow']][move['toCol']] = move['piece'];
      board[move['fromRow']][move['fromCol']] = null;

      // Update king position if king moved
      List<int>? originalWhiteKingPos;
      List<int>? originalBlackKingPos;
      if (move['piece'].type == ChessPieceType.king) {
        if (move['piece'].isWhite) {
          originalWhiteKingPos = List.from(whiteKingPosition);
          whiteKingPosition = [move['toRow'], move['toCol']];
        } else {
          originalBlackKingPos = List.from(blackKingPosition);
          blackKingPosition = [move['toRow'], move['toCol']];
        }
      }

      // Recursive call
      final result = _minimax(depth - 1, !isMaximizing, alpha, beta);

      // Undo move
      board[move['fromRow']][move['fromCol']] = move['piece'];
      board[move['toRow']][move['toCol']] = originalPiece;

      // Restore king position if needed
      if (move['piece'].type == ChessPieceType.king) {
        if (move['piece'].isWhite) {
          whiteKingPosition = originalWhiteKingPos!;
        } else {
          blackKingPosition = originalBlackKingPos!;
        }
      }

      // Update best move
      if (isMaximizing) {
        if (result['score'] > bestMove['score']) {
          bestMove = {
            'score': result['score'],
            'fromRow': move['fromRow'],
            'fromCol': move['fromCol'],
            'toRow': move['toRow'],
            'toCol': move['toCol'],
          };
        }
        alpha = max(alpha, bestMove['score']);
      } else {
        if (result['score'] < bestMove['score']) {
          bestMove = {
            'score': result['score'],
            'fromRow': move['fromRow'],
            'fromCol': move['fromCol'],
            'toRow': move['toRow'],
            'toCol': move['toCol'],
          };
        }
        beta = min(beta, bestMove['score']);
      }

      // Alpha-beta pruning
      if (beta <= alpha) {
        break;
      }
    }

    return bestMove;
  }

  // Improved hint method using minimax
  void _showHint() {
    if (isGameOver ||
        isPromoting ||
        (isPlayingAgainstAI && !isWhiteTurn) ||
        !showHints) return;

    setState(() {
      hintMove = null;
      isCalculatingHint = true;
    });

    // Use a future to avoid blocking the UI
    Future.delayed(const Duration(milliseconds: 100), () {
      final bestMove =
      _minimax(2, isWhiteTurn, double.negativeInfinity, double.infinity);

      setState(() {
        hintMove = [
          bestMove['fromRow'],
          bestMove['fromCol'],
          bestMove['toRow'],
          bestMove['toCol'],
        ];
        isCalculatingHint = false;
      });

      _playSound('hint.mp3');
    });
  }

  void _toggleAIMode() {
    setState(() {
      isPlayingAgainstAI = !isPlayingAgainstAI;
    });
    _saveSettings();
    resetGame();
  }

  void _toggleCoordinates() {
    setState(() {
      showCoordinates = !showCoordinates;
    });
    _saveSettings();
  }

  void _toggleHints() {
    setState(() {
      showHints = !showHints;
      if (!showHints) {
        hintMove = null;
      }
    });
    _saveSettings();
  }

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
          // Add a slight shadow for better visibility
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 2,
              color: isDarkMode ? Colors.black : Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          // Hint button
          IconButton(
            onPressed: isCalculatingHint ? null : _showHint,
            icon: isCalculatingHint
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.lightbulb_outline),
            tooltip: 'Show hint',
          ),
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
                    showHints: showHints,
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
                    onHintsChanged: (value) {
                      setState(() {
                        showHints = value;
                      });
                      _saveSettings();
                    },
                    onBackgroundColorChanged: (index) {
                      setState(() {
                        selectedBackgroundTheme = index;
                      });
                      _saveSettings();
                    },
                    onBoardThemeChanged: (index) {
                      setState(() {
                        selectedBoardTheme = index;
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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Turn indicator with animated chess piece
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isWhiteTurn ? Colors.white : Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isWhiteTurn ? Colors.amber : Colors.grey[600]!,
                              width: 2,
                            ),
                          ),
                          child: Image.asset(
                            'lib/images/king.png',
                            width: 24,
                            height: 24,
                            color: isWhiteTurn ? Colors.black : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TURN',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              isWhiteTurn ? 'WHITE' : 'BLACK',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isWhiteTurn ? Colors.white : Colors.grey[300],
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: isWhiteTurn
                                        ? Colors.white.withOpacity(0.6)
                                        : Colors.black.withOpacity(0.6),
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                            if (isPlayingAgainstAI && isAIThinking)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.yellow[400]!,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'AI Thinking...',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.yellow[400],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    // Game info with icons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.loop,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Moves: $moveCount',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[300],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPlayingAgainstAI
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isPlayingAgainstAI
                                  ? Colors.blue[700]!
                                  : Colors.green[700]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isPlayingAgainstAI ? Icons.smart_toy : Icons.people,
                                size: 14,
                                color: isPlayingAgainstAI
                                    ? Colors.blue[300]
                                    : Colors.green[300],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPlayingAgainstAI ? 'VS AI' : 'VS FRIEND',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isPlayingAgainstAI
                                      ? Colors.blue[300]
                                      : Colors.green[300],
                                ),
                              ),
                            ],
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boardSide =
                    constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight;
                    final margin = 8.0;
                    final coordSize = 20.0;

                    return Center(
                      child: SizedBox(
                        width: boardSide,
                        height: boardSide,
                        child: Stack(
                          children: [
                            // BOARD (inside the border)
                            Container(
                              margin: EdgeInsets.fromLTRB(
                                  coordSize, coordSize, coordSize, coordSize),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.grey[600]!
                                      : Colors.grey[400]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: GridView.builder(
                                  itemCount: 8 * 8,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8),
                                  itemBuilder: (context, index) {
                                    final row = index ~/ 8;
                                    final col = index % 8;
                                    final isSelected = selectedRow == row &&
                                        selectedCol == col;
                                    final isValidMove = validMoves
                                        .any((p) => p[0] == row && p[1] == col);
                                    final isCapturable = isValidMove &&
                                        board[row][col] != null &&
                                        board[row][col]!.isWhite != isWhiteTurn;

                                    // Check if this square is part of the hint
                                    final isHintSquare = hintMove != null &&
                                        ((row == hintMove![0] &&
                                            col == hintMove![1]) ||
                                            (row == hintMove![2] &&
                                                col == hintMove![3]));

                                    bool isKingInCheck = false;
                                    if (checkStatus) {
                                      if (isWhiteTurn &&
                                          board[row][col]?.type ==
                                              ChessPieceType.king &&
                                          board[row][col]?.isWhite == true &&
                                          row == whiteKingPosition[0] &&
                                          col == whiteKingPosition[1]) {
                                        isKingInCheck = true;
                                      } else if (!isWhiteTurn &&
                                          board[row][col]?.type ==
                                              ChessPieceType.king &&
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
                                      boardColors:
                                      boardThemes[selectedBoardTheme],
                                      isHint: isHintSquare,
                                    );
                                  },
                                ),
                              ),
                            ),

                            // COORDINATES (drawn on top, exact size)
                            if (showCoordinates) ...[
                              // TOP files
                              Positioned(
                                left: coordSize,
                                right: coordSize,
                                top: 0,
                                height: coordSize,
                                child: Row(
                                  children: List.generate(
                                      8,
                                          (i) => Expanded(
                                          child:
                                          _buildCoordinateLabel(true, i))),
                                ),
                              ),
                              // BOTTOM files
                              Positioned(
                                left: coordSize,
                                right: coordSize,
                                bottom: 0,
                                height: coordSize,
                                child: Row(
                                  children: List.generate(
                                      8,
                                          (i) => Expanded(
                                          child:
                                          _buildCoordinateLabel(true, i))),
                                ),
                              ),
                              // LEFT ranks
                              Positioned(
                                top: coordSize,
                                bottom: coordSize,
                                left: 0,
                                width: coordSize,
                                child: Column(
                                  children: List.generate(
                                      8,
                                          (i) => Expanded(
                                          child:
                                          _buildCoordinateLabel(false, i))),
                                ),
                              ),
                              // RIGHT ranks
                              Positioned(
                                top: coordSize,
                                bottom: coordSize,
                                right: 0,
                                width: coordSize,
                                child: Column(
                                  children: List.generate(
                                      8,
                                          (i) => Expanded(
                                          child:
                                          _buildCoordinateLabel(false, i))),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
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
// Enhanced Bottom action bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // New Game Button
                    _buildEnhancedActionButton(
                      icon: Icons.restart_alt,
                      label: 'New Game',
                      color: Colors.green[600]!,
                      onPressed: _showNewGameDialog,
                      isDisabled: false,
                    ),

                    // Themes Button
                    _buildEnhancedActionButton(
                      icon: Icons.palette,
                      label: 'Themes',
                      color: Colors.blue[600]!,
                      onPressed: _showThemeDialog,
                      isDisabled: false,
                    ),

                    // Hints Toggle Button
                    _buildEnhancedActionButton(
                      icon: showHints ? Icons.visibility : Icons.visibility_off,
                      label: showHints ? 'Hints On' : 'Hints Off',
                      color: Colors.purple[600]!,
                      onPressed: _toggleHints,
                      isDisabled: false,
                    ),

                    // Undo Button
                    _buildEnhancedActionButton(
                      icon: Icons.undo,
                      label: 'Undo',
                      color: moveHistory.isEmpty ? Colors.grey[600]! : Colors.orange[600]!,
                      onPressed: moveHistory.isEmpty ? null : _undoMove,
                      isDisabled: moveHistory.isEmpty,
                    ),

                    // Main Menu Button
                    _buildEnhancedActionButton(
                      icon: Icons.home,
                      label: 'Main Menu',
                      color: Colors.orange[600]!,
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                        );
                      },
                      isDisabled: false,
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

class MoveHistory {
  ChessPiece? movedPiece;
  ChessPiece? capturedPiece;
  int fromRow;
  int fromCol;
  int toRow;
  int toCol;
  bool wasPromotion;
  bool wasKingMove;
  bool wasRookMove;
  bool wasCastling;
  bool wasEnPassant;
  bool wasCheck;
  bool wasCheckmate;

  MoveHistory({
    required this.movedPiece,
    this.capturedPiece,
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    this.wasPromotion = false,
    this.wasKingMove = false,
    this.wasRookMove = false,
    this.wasCastling = false,
    this.wasEnPassant = false,
    this.wasCheck = false,
    this.wasCheckmate = false,
  });
}
