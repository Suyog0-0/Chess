import 'package:flutter/material.dart';
import 'package:suyog_chess_sc/components/square.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game Board')), // Added AppBar with a title
      body: GridView.builder(
        itemCount: 8 * 8,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
        itemBuilder: (context, index) {
          int x = index ~/ 8; // this gives us the integer division i.e. row
          int y = index % 8; // this gives us the remainder i.e. column

          // alternate colors for each square
          bool isWhite = (x + y) % 2 == 0;

          return Square(isWhite: isWhite); // Added border to each square
        },
      ), // GridView.builder
    ); // Scaffold
  }
}