bool isInBoard(int row, int col) {
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}

bool isWhite(int index) {
  final row = index ~/ 8;
  final col = index % 8;
  return (row + col) % 2 == 1;;
}
