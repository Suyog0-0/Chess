import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'login_screen.dart';

// ============================================
// ENHANCED SPLASH SCREEN - MODERN & CLEAN DESIGN
// ============================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ========== ANIMATION CONTROLLERS ==========
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _textSlideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _textSlideAnimation;

  // ========== AUDIO PLAYER ==========
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _initializeAnimations();
    _startAnimations();
  }

  // ========== ANIMATION INITIALIZATION ==========
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textSlideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textSlideController,
      curve: Curves.easeOutCubic,
    ));
  }

  // ========== ANIMATION SEQUENCE ==========
  Future<void> _startAnimations() async {
    // Play startup sound
    try {
      await _audioPlayer.play(AssetSource('sounds/game_start.mp3'));
    } catch (e) {
      // Fallback sound path
      try {
        await _audioPlayer.play(AssetSource('sounds/game_start.mp3'));
      } catch (e2) {
        // Handle audio error silently
      }
    }

    // Animation sequence
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    _textSlideController.forward();

    // Navigate to login screen after delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _fadeController.dispose();
    _scaleController.dispose();
    _textSlideController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ========== MODERN UI BUILD ==========
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a1a2e),
                Color(0xFF16213e),
                Color(0xFF0f3460),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              _buildBackgroundPattern(),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated chess icon
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.castle,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Slide-in text content
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // App title
                            const Text(
                              'SUYOG CHESS',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 2.5,
                                fontFamily: 'PlayfairDisplay',
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Subtitle
                            Text(
                              'Master the Game of Kings',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[300],
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            const SizedBox(height: 50),

                            // Modern loading indicator
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent.withOpacity(0.8),
                                ),
                                backgroundColor: Colors.white.withOpacity(0.2),
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
  }

  // ========== BACKGROUND PATTERN ==========
  Widget _buildBackgroundPattern() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.05,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/images/chess_pattern.png'),
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),
      ),
    );
  }
}