import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

class WinCelebrationScreen extends StatefulWidget {
  final bool isWhiteWinner;
  final int moveCount;
  final Duration gameDuration;
  final int whitePiecesCaptured;
  final int blackPiecesCaptured;
  final bool wasPlayingAgainstAI;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToMenu;

  const WinCelebrationScreen({
    super.key,
    required this.isWhiteWinner,
    required this.moveCount,
    required this.gameDuration,
    required this.whitePiecesCaptured,
    required this.blackPiecesCaptured,
    required this.wasPlayingAgainstAI,
    required this.onPlayAgain,
    required this.onBackToMenu,
  });

  @override
  State<WinCelebrationScreen> createState() => _WinCelebrationScreenState();
}

class _WinCelebrationScreenState extends State<WinCelebrationScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late ConfettiController _leftConfettiController;
  late ConfettiController _rightConfettiController;
  late AnimationController _bounceController;
  late AnimationController _slideController;
  late Animation<double> _bounceAnimation;
  late Animation<Offset> _slideAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _leftConfettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    _rightConfettiController =
        ConfettiController(duration: const Duration(seconds: 4));

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _startCelebration();
  }

  Future<void> _startCelebration() async {
    // Play victory sound
    try {
      await _audioPlayer.play(AssetSource('victory.mp3'));
    } catch (e) {
      try {
        await _audioPlayer.play(AssetSource('sounds/victory.mp3'));
      } catch (e2) {
        // Handle silently
      }
    }

    // Start confetti from multiple directions
    _confettiController.play();

    await Future.delayed(const Duration(milliseconds: 300));
    _leftConfettiController.play();

    await Future.delayed(const Duration(milliseconds: 200));
    _rightConfettiController.play();

    // Start animations
    await Future.delayed(const Duration(milliseconds: 500));
    _bounceController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  String _getPerformanceRating() {
    if (widget.moveCount < 20) return "Lightning Fast!";
    if (widget.moveCount < 40) return "Excellent!";
    if (widget.moveCount < 60) return "Good Game!";
    if (widget.moveCount < 80) return "Well Played!";
    return "Epic Battle!";
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _leftConfettiController.dispose();
    _rightConfettiController.dispose();
    _bounceController.dispose();
    _slideController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.isWhiteWinner
                ? [Colors.amber[100]!, Colors.amber[600]!]
                : [Colors.grey[700]!, Colors.grey[900]!],
          ),
        ),
        child: Stack(
          children: [
            // Multiple confetti controllers for better effect
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 1.5708, // downward
                emissionFrequency: 0.03,
                numberOfParticles: 80,
                gravity: 0.08,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.cyan,
                ],
              ),
            ),

            Align(
              alignment: Alignment.topLeft,
              child: ConfettiWidget(
                confettiController: _leftConfettiController,
                blastDirection: 0.7854, // 45 degrees
                emissionFrequency: 0.05,
                numberOfParticles: 40,
                gravity: 0.1,
                colors: const [Colors.yellow, Colors.amber, Colors.orange],
              ),
            ),

            Align(
              alignment: Alignment.topRight,
              child: ConfettiWidget(
                confettiController: _rightConfettiController,
                blastDirection: 2.3562, // 135 degrees
                emissionFrequency: 0.05,
                numberOfParticles: 40,
                gravity: 0.1,
                colors: const [Colors.grey, Colors.blueGrey, Colors.white70],
              ),
            ),

            // Main content
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated trophy and title
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _bounceAnimation.value,
                          child: Column(
                            children: [
                              // Trophy icon with rotation effect
                              Transform.rotate(
                                angle: _bounceAnimation.value * 0.1,
                                child: Icon(
                                  Icons.emoji_events,
                                  size: 120,
                                  color: widget.isWhiteWinner
                                      ? Colors.amber
                                      : Colors.grey[300],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Victory text with glow effect
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.isWhiteWinner
                                          ? Colors.amber.withAlpha(128)
                                          : Colors.grey.withAlpha(128),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'VICTORY!',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: widget.isWhiteWinner
                                        ? Colors.amber[800]
                                        : Colors.white,
                                    shadows: const [
                                      Shadow(
                                        offset: Offset(3, 3),
                                        blurRadius: 6,
                                        color: Color(0x80000000),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 15),

                    Text(
                      '${widget.isWhiteWinner ? "White" : "Black"} Player Wins!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: widget.isWhiteWinner
                            ? Colors.amber[700]
                            : Colors.grey[300],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _getPerformanceRating(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[300],
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Animated game stats
                    SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: const Color(0x6D000000),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0x4DFFFFFF),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.analytics,
                                    color: Colors.blue[300], size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Game Statistics',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[200],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            _buildStatRow(
                              'Total Moves',
                              '${widget.moveCount}',
                              Icons.swap_horiz,
                              Colors.blue[300]!,
                            ),
                            _buildStatRow(
                              'Game Duration',
                              _formatDuration(widget.gameDuration),
                              Icons.timer,
                              Colors.green[300]!,
                            ),
                            _buildStatRow(
                              'White Pieces Lost',
                              '${widget.whitePiecesCaptured}',
                              Icons.close,
                              Colors.red[300]!,
                            ),
                            _buildStatRow(
                              'Black Pieces Lost',
                              '${widget.blackPiecesCaptured}',
                              Icons.close,
                              Colors.red[300]!,
                            ),
                            if (widget.wasPlayingAgainstAI)
                              _buildStatRow(
                                'Opponent',
                                'AI Bot',
                                Icons.smart_toy,
                                Colors.purple[300]!,
                              ),
                            _buildStatRow(
                              'Winner',
                              '${widget.isWhiteWinner ? "White" : "Black"} Player',
                              Icons.emoji_events,
                              Colors.amber[300]!,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Action buttons with animations
                    SlideTransition(
                      position: _slideAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            onPressed: widget.onPlayAgain,
                            icon: Icons.refresh,
                            label: 'Play Again',
                            color: Colors.green,
                            isPrimary: true,
                          ),
                          _buildActionButton(
                            onPressed: widget.onBackToMenu,
                            icon: Icons.home,
                            label: 'Main Menu',
                            color: Colors.grey[700]!,
                            isPrimary: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
      String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[300],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 15,
          ),
          textStyle: TextStyle(
            fontSize: isPrimary ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 8,
        ),
      ),
    );
  }
}
