import 'package:flutter/material.dart';
import 'package:suyog_chess_sc/components/piece.dart';
import 'package:suyog_chess_sc/components/square.dart';
import 'package:suyog_chess_sc/helper/helper_methods.dart';
import 'package:suyog_chess_sc/values/colors.dart';

import 'components/dead_piece.dart';

class GameBoard extends StatefulWidget {


  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // A two dimesnional list represting the chesboard
  late List<List<ChessPiece?>> board;

  //The currently selected piece on the chess board,
  // If no piece selected it is null
  ChessPiece? selectedPiece;

  //The row index of the selected piece
  //Default value -1 indicated no piece ic currently selected
  int selectedRow = -1;


  //The row index of the selected piece
  //Default value -1 indicated no piece ic currently selected
  int selectedCol = -1;

// A list of valid moves for the currently selected piece
  // Each move is represented as a list with 2 elements : row and columns
  List<List<int>> validMoves = [];

  // a list of white pieces that have been taken by opponent
  List<ChessPiece> whitePiecesTaken = [];

  // a list of black pieces that have been taken by opponent
  List<ChessPiece> blackPiecesTaken = [];

// A BOOLEAN TO incicate whose turn it is
  bool isWhiteTurn = true;

  // initial posiiton of kings (keeping track of this to make it easier turn)
  List<int> whiteKingPosition = [7,4];
  List<int> blackKingPosition = [0,4];
  bool checkStatus = false;

  @override
  void initState(){
    super.initState();
    _initializeBoard();
  }

  //Initializaing the board
  void _initializeBoard(){
    // Initializing the board with nulls, meaning that no pieces in those positions
    List<List<ChessPiece?>> newBoard =
    List.generate(8, (index) => List.generate(8, (index) => null));

    // to place random chess darts in this for checking
    // newBoard[3][3] = ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath:'lib/images/bishop.png' );

    //Placing pawns
    for (int i=0; i<8; i++){
      newBoard[1][i] = ChessPiece( //Having black piece in the first row
        type: ChessPieceType.pawn,
        isWhite: false,
        imagePath: 'lib/images/pawn.png'
      );
      newBoard[6][i] = ChessPiece( //Having white piece in the 6th row
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'lib/images/pawn.png'
      );
    }

    //Placing Rooks
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png'
    );
    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png'
    );
    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png'
    );
    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png'
    );

    //Placing KNights
    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png'
    );
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png'
    );
    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png'
    );
    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png'
    );

    //Placing Bishops
    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png'
    );
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png'
    );
    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png'
    );
    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png'
    );

    //Placing queens
    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'lib/images/queen.png'
    );
    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'lib/images/queen.png'
    );

    //Placing kings
    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'lib/images/king.png'
    );
    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'lib/images/king.png'
    );

    board= newBoard;
  }

  //User selected a piece
  void pieceSelected(int row, int col) {
    setState(() {
      // No piece has been selected yet, this is the first seclection
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite== isWhiteTurn){
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }

      // tehre is a piece that is already selected but the user can selecte anotehr one of their pieces
  else if(board[row][col] != null && board[row][col]!.isWhite == selectedPiece!.isWhite){
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
}
    // if there is a piece selected and user taps on a square that is a vlid move, move there
    else if(selectedPiece != null &&
        validMoves.any((element) => element[0] == row && element[1]==col)) {
            movePiece(row, col);
    }


    // if a piece is ssleceted, calculate its valdi mode
      validMoves = calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
    });
  }

  // Calculate Raw valid moves
  List<List<int>> calculateRawValidMoves( int row, int col, ChessPiece? piece){
    List<List<int>> candidateMoves = [];

    if (piece==null){
      return [];
    }
    //different dierections based on their color
    int direction = piece!.isWhite ? -1:1;

    switch (piece.type){
      case ChessPieceType.pawn:
        //can move forward if square not occupied
        if(isInBoard(row + direction, col) &&
            board[row+direction][col]==null) {
          candidateMoves.add([row + direction, col]);

        }
      // can move 2 forward if not occupied
      if ((row ==1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
        if (isInBoard(row+2 * direction,col) &&
            board[row+2 * direction][col] == null &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + 2 * direction, col]);
        }
      }

      // pawns can capture diagonally (left)
      if (isInBoard(row + direction, col - 1) &&
          board[row + direction][col - 1] != null &&
          board[row + direction][col - 1]!.isWhite != piece.isWhite) {
        candidateMoves.add([row + direction, col - 1]);
      }

      // pawns can capture diagonally (right)
      if (isInBoard(row + direction, col + 1) &&
          board[row + direction][col + 1] != null &&
          board[row + direction][col + 1]!.isWhite != piece.isWhite) {
        candidateMoves.add([row + direction, col + 1]);
      }

        break;

      case ChessPieceType.rook:

        // horizonal and vertical directions
      var directions = [
        [-1,0], //up
        [1,0], //down
        [0,-1], //left
        [0,1], //right
      ];

      for (var direction in directions) {
    var i=1;
    while (true){
    var newRow = row + i * direction[0];
    var newCol = col + i * direction[1];
    if (!isInBoard(newRow, newCol)) {
      break;
    }
    if (board[newRow] [newCol] != null) {
      if(board[newRow][newCol]!.isWhite != piece.isWhite){
        candidateMoves.add([newRow,newCol]); //kill
      }
      break; //blocked
    }
    candidateMoves.add([newRow, newCol]);
    i++;
      }
    }

        break;
      case ChessPieceType.knight:
      //all eight L-shaped possible moves
        var knightMoves = [
          [-2,-1], //up 2 left 1
          [-2,1],  //up 2 right 1
          [-1,-2], //up 1 left 2
          [-1,2],  //up 1 right 2
          [1,-2],  //down 1 left 2
          [1,2],   //down 1 right 2
          [2,-1],  //down 2 left 1
          [2,1],   //down 2 right 1
        ];

        for(var move in knightMoves){
          var newRow = row + move[0];
          var newCol = col + move[1];
          if(!isInBoard(newRow, newCol)){
            continue;
          }
          if(board[newRow][newCol] != null){
            if(board[newRow][newCol]!.isWhite != piece.isWhite){
              candidateMoves.add([newRow, newCol]);//this will capture
            }
            continue;//blocked
          }
          candidateMoves.add([newRow,newCol]);
        }
        break;

      case ChessPieceType.bishop:
        var directions = [
          [-1,-1], //up left
          [-1,1], //up right
          [1,-1], //down left
          [1,1],  //down right
        ];

        for(var direction in directions){
          var i= 1;
          while (true){
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if(!isInBoard(newRow, newCol)){
              break;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.king:
      //all eight directions
        var directions = [
          [-1,0],//up
          [1,0],//down
          [0,-1],//left
          [0,1],//right
          [-1,-1],//up left
          [-1,1],// up right
          [1,-1],// down left
          [1,1],// down right
        ];

        for(var direction in directions){
          var newRow = row + direction[0];
          var newCol = col +direction[1];
          if(!isInBoard(newRow, newCol)){
            continue;
          }
          if(board[newRow][newCol] != null){
            if(board[newRow][newCol]!.isWhite != piece.isWhite){
              candidateMoves.add([newRow, newCol]);//capture
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;


      case ChessPieceType.queen:
      //can move all eight directions
        var directions = [
          [-1,0],//up
          [1,0],//down
          [0,-1],//left
          [0,1],//right
          [-1,-1],//up left
          [-1,1],// up right
          [1,-1],// down left
          [1,1],// down right
        ];

        for(var direction in directions){
          var i = 1;
          while(true){
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if(!isInBoard(newRow, newCol)){
              break;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      default:
    }
    return candidateMoves;


  }

  //Calculate real valid modes
  List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation){
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // after generating all candidate moves, filter out any that would result in a  check
    if(checkSimulation){
      for (var move in candidateMoves){
        int endRow = move[0];
        int endCol = move[1];

        // this will simulate the future move to see it is safe
        if(simulatedMoveIsSafe(piece!, row, col, endRow, endCol)){
          realValidMoves.add(move);
        }
      }
    }else{
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  // Move piece
  void movePiece(int newRow, int newCol){

    //if thenew spot has an een,y
    if(board[newRow][newCol] != null) {
      //add captured piece to the plist
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite){
        whitePiecesTaken.add(capturedPiece);
      }else{
        blackPiecesTaken.add(capturedPiece);
      }
    }
// check if the peice being moves is a king
    if(selectedPiece!.type== ChessPieceType.king){
      if(selectedPiece!.isWhite){
        whiteKingPosition = [newRow, newCol];
      }else{
        blackKingPosition = [newRow, newCol];
      }
    }

    //  move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    //see if any king under attack
    if(isKingInCheck(!isWhiteTurn)){
      checkStatus = true;
    } else{
      checkStatus = false;
    }

    // clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("CHECK MATE!"),
            actions: [
              TextButton(onPressed: resetGame, child: const Text("Play Again")),
            ]
          )
      );

    // change turns

    }isWhiteTurn = !isWhiteTurn;
  }

 //is king in check
bool isKingInCheck(bool isWhiteKing){
    //get position of king
  List<int> kingPosition =
      isWhiteKing ? whiteKingPosition : blackKingPosition;
  // check if any enemy piece can attack the king
  for ( int i = 0; i<8; i++){
    for (int j=0; j<8; j++){
      // skip empty squares
      if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing){
        continue;
      }
      List<List<int>> pieceValidMoves =
        calculateRealValidMoves(i, j, board[i][j], false);

      if (pieceValidMoves.any((move)=>
      move[0] == kingPosition[0] && move[1] == kingPosition[1])){
        return true;
      }
    }
  }
  return false;
 }

 //  simulte a futuer move to see if its safe doesnt put your own under attack
  bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol){
    //save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    // if the piece is the king, save its current positiona dnupdate it ot the new one
    List<int>? originalKingPosition;
    if(piece.type == ChessPieceType.king){
      originalKingPosition =
          piece.isWhite? whiteKingPosition:blackKingPosition;

      if(piece.isWhite){
        whiteKingPosition= [endRow, endCol];
      }else{
        blackKingPosition = [endRow, endCol];
      }
    }

    //simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // and chekc if king is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);
    //restore board to original stta
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;


    // if the piece was the king, restore it original position
    if (piece.type == ChessPieceType.king){
      if(piece.isWhite){
        whiteKingPosition = originalKingPosition!;
      }else{
        blackKingPosition = originalKingPosition!;
      }
    }
    // jhjh
    return !kingInCheck;
  }
  // is it check mate
  bool isCheckMate(bool isWhiteKing){
    if(!isKingInCheck(isWhiteKing)){
      return false;
    }
    for (int i=0; i<8; i++){
      for(int j=0; j<8; j++){
        if(board[i][j]==null || board[i][j]!.isWhite != isWhiteKing){
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i,j,board[i][j], true);


      if(pieceValidMoves.isNotEmpty){
        return false;
      }
    }
    }
    return true;
  }

  //rest to new game
  void resetGame(){
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7,4];
    blackKingPosition = [0,4];
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // white pieces taken
          Expanded(
            child: GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index)=> DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),
//game status
        Text(checkStatus ? "CHECK!" : ""),

          // chess board
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) {

                //get the row and column position of this square
                int row = index ~/ 8;
                int col = index % 8;

                //check if this square is selected
                bool isSelected = selectedRow == row && selectedCol == col;

                //check if the square is a valid move
                bool isValidMove= false;
                for(var position in validMoves) {
                  // compare row and col
                  if (position[0] == row && position[1] == col){
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(row, col),
                ); // Square
              },
            ),
          ),
          //black pieces taken
          Expanded(
            child: GridView.builder(
              itemCount: blackPiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index)=> DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ), // GridView.builder
    ); // Scaffold
  }
}