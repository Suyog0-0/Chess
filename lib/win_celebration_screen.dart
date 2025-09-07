import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

// ═══════════════════════════════════════════════════════════════════
// 🏆 WIN CELEBRATION SCREEN - PROFESSIONAL UI COMPONENT
// ═══════════════════════════════════════════════════════════════════
class WinCelebrationScreen extends StatefulWidget {
  final bool isWhiteWinner;
  final int moveCount;
  final Duration gameDuration;
  final int whitePiecesCaptured;
  final int blackPiecesCaptured;
  final bool wasPlayingAgainstAI;
  final VoidCallback onPlayAgain;
  final VoidCallback onViewAnalysis;
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
    required this.onViewAnalysis,
    required this.onBackToMenu,
  });

  @override
  State<WinCelebrationScreen> createState() => _WinCelebrationScreenState();
}

class _WinCelebrationScreenState extends State<WinCelebrationScreen>
    with TickerProviderStateMixin {

  // ═══════════════════════════════════════════════════════════════════
  // 🎮 ANIMATION CONTROLLERS & STATE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════
  late final ConfettiController _confettiController;
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _slideController;
  late final AnimationController _buttonController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _buttonAnimation;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _animationComplete = false;

  // ═══════════════════════════════════════════════════════════════════
  // 🎨 DESIGN SYSTEM CONSTANTS
  // ═══════════════════════════════════════════════════════════════════
  static const _primarySpacing = 24.0;
  static const _secondarySpacing = 16.0;
  static const _borderRadius = 20.0;
  static const _cardElevation = 12.0;
  static const _animationDuration = Duration(milliseconds: 800);
  static const _delayBetweenAnimations = Duration(milliseconds: 200);

  // ═══════════════════════════════════════════════════════════════════
  // 🚀 LIFECYCLE METHODS
  // ═══════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCelebrationSequence();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // ⚙️ INITIALIZATION & SETUP
  // ═══════════════════════════════════════════════════════════════════
  void _initializeAnimations() {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    _fadeController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _buttonAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutBack,
    );
  }

  void _disposeControllers() {
    _confettiController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _buttonController.dispose();
    _audioPlayer.dispose();
  }

  Future<void> _startCelebrationSequence() async {
    // Play victory sound
    await _playVictorySound();

    // Start confetti immediately
    _confettiController.play();

    // Sequence animations with delays
    _fadeController.forward();

    await Future.delayed(_delayBetweenAnimations);
    _scaleController.forward();

    await Future.delayed(_delayBetweenAnimations);
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _buttonController.forward();

    setState(() => _animationComplete = true);
  }

  Future<void> _playVictorySound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/victory.mp3'));
    } catch (e) {
      try {
        await _audioPlayer.play(AssetSource('victory.mp3'));
      } catch (e) {
        debugPrint('Victory sound not found: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🎨 MAIN UI BUILD METHOD
  // ═══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(isDark),
          _buildConfettiLayer(),
          _buildMainContent(context, isDark),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🌈 BACKGROUND & VISUAL EFFECTS
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildGradientBackground(bool isDark) {
    final winnerColors = _getWinnerColorScheme();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            winnerColors.primary.withOpacity(0.15),
            winnerColors.secondary.withOpacity(0.08),
            Colors.black.withOpacity(0.9),
          ]
              : [
            winnerColors.primary.withOpacity(0.1),
            winnerColors.secondary.withOpacity(0.05),
            Colors.white.withOpacity(0.95),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildConfettiLayer() {
    return Positioned.fill(
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: 1.57, // π/2 (downward)
        emissionFrequency: 0.05,
        numberOfParticles: 25,
        gravity: 0.08,
        shouldLoop: false,
        colors: const [
          Colors.amber,
          Colors.orange,
          Colors.red,
          Colors.pink,
          Colors.purple,
          Colors.blue,
          Colors.cyan,
          Colors.green,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 📱 RESPONSIVE MAIN CONTENT
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildMainContent(BuildContext context, bool isDark) {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 700;
            final isMobile = constraints.maxWidth < 600;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : _primarySpacing,
                vertical: isCompact ? 16 : _primarySpacing,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight -
                      (isMobile ? 40 : _primarySpacing * 2),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Hero Trophy Section
                      _buildHeroSection(isCompact, isDark),

                      SizedBox(height: isCompact ? 24 : 32),

                      // Winner Announcement
                      _buildWinnerAnnouncement(isDark),

                      SizedBox(height: isCompact ? 24 : 32),

                      // Game Statistics Card
                      _buildStatisticsCard(isMobile, isDark),

                      const Spacer(),

                      SizedBox(height: isCompact ? 24 : 40),

                      // Action Buttons
                      _buildActionButtons(isMobile, isDark),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🏆 HERO TROPHY SECTION
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildHeroSection(bool isCompact, bool isDark) {
    final winnerColors = _getWinnerColorScheme();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              winnerColors.primary.withOpacity(isDark ? 0.25 : 0.2),
              Colors.transparent,
            ],
            stops: const [0.1, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: winnerColors.primary.withOpacity(isDark ? 0.3 : 0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          Icons.emoji_events_rounded,
          size: isCompact ? 80 : 100,
          color: winnerColors.primary,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🎊 WINNER ANNOUNCEMENT
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildWinnerAnnouncement(bool isDark) {
    final winnerColors = _getWinnerColorScheme();
    final textColor = isDark ? Colors.white : Colors.grey[850];

    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          // Checkmate Text
          Text(
            'CHECKMATE!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: winnerColors.primary,
              letterSpacing: 2.5,
              shadows: isDark
                  ? [
                Shadow(
                  color: Colors.black.withOpacity(0.4),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ]
                  : null,
            ),
          ),

          const SizedBox(height: 12),

          // Winner Text
          Text(
            '${widget.isWhiteWinner ? 'White' : 'Black'} Wins!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: textColor?.withOpacity(0.95),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 📊 GAME STATISTICS CARD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildStatisticsCard(bool isMobile, bool isDark) {
    final cardColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);
    final borderColor = isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1);
    final textColor = isDark ? Colors.white : Colors.grey[850];

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 400,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(_primarySpacing),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.1),
              blurRadius: _cardElevation,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Text(
              'Game Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor?.withOpacity(0.95),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),

            const SizedBox(height: _secondarySpacing),

            // Divider
            Divider(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
              thickness: 1,
              height: 24,
            ),

            // Statistics List
            ..._buildStatisticsList(isDark),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatisticsList(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.grey[850];
    final dividerColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);

    final stats = [
      _StatisticData(
        icon: Icons.swap_horiz_rounded,
        label: 'Total Moves',
        value: widget.moveCount.toString(),
      ),
      _StatisticData(
        icon: Icons.timer_outlined,
        label: 'Duration',
        value: _formatDuration(widget.gameDuration),
      ),
      _StatisticData(
        icon: Icons.remove_circle_outline,
        label: 'White Captured',
        value: widget.whitePiecesCaptured.toString(),
      ),
      _StatisticData(
        icon: Icons.remove_circle_outline,
        label: 'Black Captured',
        value: widget.blackPiecesCaptured.toString(),
      ),
      if (widget.wasPlayingAgainstAI)
        _StatisticData(
          icon: Icons.smart_toy_outlined,
          label: 'Game Mode',
          value: 'VS AI',
        ),
    ];

    return stats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final isLast = index == stats.length - 1;

      return Column(
        children: [
          _buildStatisticRow(stat, isDark),
          if (!isLast)
            Divider(
              color: dividerColor,
              height: 20,
              thickness: 1,
            ),
        ],
      );
    }).toList();
  }

  Widget _buildStatisticRow(_StatisticData data, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.grey[850];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            data.icon,
            size: 20,
            color: textColor?.withOpacity(0.8),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              data.label,
              style: TextStyle(
                color: textColor?.withOpacity(0.8),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            data.value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🎯 ACTION BUTTONS SECTION
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildActionButtons(bool isMobile, bool isDark) {
    return FadeTransition(
      opacity: _buttonAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_buttonAnimation),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: isMobile ? _buildVerticalButtons(isDark) : _buildHorizontalButtons(isDark),
        ),
      ),
    );
  }

  Widget _buildHorizontalButtons(bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildPlayAgainButton(isDark)),
        const SizedBox(width: 12),
        Expanded(child: _buildAnalysisButton(isDark)),
        const SizedBox(width: 12),
        Expanded(child: _buildMenuButton(isDark)),
      ],
    );
  }

  Widget _buildVerticalButtons(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPlayAgainButton(isDark),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildAnalysisButton(isDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildMenuButton(isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayAgainButton(bool isDark) {
    return _buildActionButton(
      onPressed: widget.onPlayAgain,
      label: 'Play Again',
      icon: Icons.refresh_rounded,
      isPrimary: true,
      isDark: isDark,
    );
  }

  Widget _buildAnalysisButton(bool isDark) {
    return _buildActionButton(
      onPressed: widget.onViewAnalysis,
      label: 'Analysis',
      icon: Icons.analytics_outlined,
      isDark: isDark,
    );
  }

  Widget _buildMenuButton(bool isDark) {
    return _buildActionButton(
      onPressed: widget.onBackToMenu,
      label: 'Menu',
      icon: Icons.home_rounded,
      isDark: isDark,
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    bool isPrimary = false,
    required bool isDark,
  }) {
    final winnerColors = _getWinnerColorScheme();
    final backgroundColor = isPrimary
        ? winnerColors.primary
        : (isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06));
    final foregroundColor = isPrimary
        ? Colors.white
        : (isDark ? Colors.white.withOpacity(0.95) : Colors.grey[850]!.withOpacity(0.95));
    final borderColor = isPrimary
        ? Colors.transparent
        : (isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15));

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: borderColor,
            width: isPrimary ? 0 : 1.5,
          ),
        ),
        elevation: isPrimary ? 6 : 1,
        shadowColor: isPrimary
            ? winnerColors.primary.withOpacity(0.4)
            : Colors.transparent,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🎨 DESIGN SYSTEM & UTILITIES
  // ═══════════════════════════════════════════════════════════════════
  _ColorScheme _getWinnerColorScheme() {
    if (widget.isWhiteWinner) {
      return _ColorScheme(
        primary: Colors.amber.shade600,
        secondary: Colors.orange.shade400,
      );
    } else {
      return _ColorScheme(
        primary: Colors.grey.shade700,
        secondary: Colors.blueGrey.shade500,
      );
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════════════════════════
// 📊 DATA MODELS & HELPERS
// ═══════════════════════════════════════════════════════════════════
class _StatisticData {
  final IconData icon;
  final String label;
  final String value;

  const _StatisticData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _ColorScheme {
  final Color primary;
  final Color secondary;

  const _ColorScheme({
    required this.primary,
    required this.secondary,
  });
}