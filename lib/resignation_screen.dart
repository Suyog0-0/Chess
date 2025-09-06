import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

class ResignationScreen extends StatefulWidget {
  final bool isWhiteResigned;
  final int moveCount;
  final Duration gameDuration;
  final int whitePiecesCaptured;
  final int blackPiecesCaptured;
  final bool wasPlayingAgainstAI;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToMenu;

  const ResignationScreen({
    super.key,
    required this.isWhiteResigned,
    required this.moveCount,
    required this.gameDuration,
    required this.whitePiecesCaptured,
    required this.blackPiecesCaptured,
    required this.wasPlayingAgainstAI,
    required this.onPlayAgain,
    required this.onBackToMenu,
  });

  @override
  State<ResignationScreen> createState() => _ResignationScreenState();
}

class _ResignationScreenState extends State<ResignationScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Play resignation sound
    try {
      await _audioPlayer.play(AssetSource('sounds/resign.mp3'));
    } catch (e) {
      try {
        await _audioPlayer.play(AssetSource('resign.mp3'));
      } catch (e2) {
        // Handle silently
      }
    }

    // Start confetti
    _confettiController.play();

    // Start animations
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
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

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeController.dispose();
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
            colors: [
              Colors.grey[850]!,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 1.5708, // π/2 (downward)
                emissionFrequency: 0.03,
                numberOfParticles: 20,
                gravity: 0.1,
                colors: const [
                  Colors.grey,
                  Colors.blueGrey,
                  Colors.white70,
                  Colors.brown,
                ],
                particleDrag: 0.05,
                minimumSize: const Size(2, 2),
                maximumSize: const Size(5, 5),
              ),
            ),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Resignation icon with subtle shadow
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.flag_rounded,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Title with gradient
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.grey[300]!,
                            Colors.grey[400]!,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'RESIGNATION',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Message
                      Text(
                        'You Have Resigned',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Winner announcement
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.isWhiteResigned
                              ? Colors.black.withOpacity(0.7)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.isWhiteResigned ? "Black" : "White"} Wins by Resignation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.isWhiteResigned
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Game stats container
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey[800]!,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildStatRow('Total Moves', '${widget.moveCount}'),
                            const Divider(color: Colors.grey, height: 20),
                            _buildStatRow('Game Duration',
                                _formatDuration(widget.gameDuration)),
                            const Divider(color: Colors.grey, height: 20),
                            _buildStatRow(
                                'White Pieces Lost', '${widget.whitePiecesCaptured}'),
                            const Divider(color: Colors.grey, height: 20),
                            _buildStatRow('Black Pieces Lost',
                                '${widget.blackPiecesCaptured}'),
                            if (widget.wasPlayingAgainstAI) ...[
                              const Divider(color: Colors.grey, height: 20),
                              _buildStatRow('Mode', 'VS AI'),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Action buttons
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 15,
                        children: [
                          _buildActionButton(
                            onPressed: widget.onPlayAgain,
                            icon: Icons.refresh_rounded,
                            label: 'Play Again',
                            color: Colors.green[700]!,
                          ),
                          _buildActionButton(
                            onPressed: widget.onBackToMenu,
                            icon: Icons.home_rounded,
                            label: 'Main Menu',
                            color: Colors.grey[700]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
              fontWeight: FontWeight.w300,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[200],
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
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
    );
  }
}