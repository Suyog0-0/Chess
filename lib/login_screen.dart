import 'package:flutter/material.dart';
import 'game_board.dart';

/* ==========================================================
 *  LoginScreen – Clean, Modern & Responsive
 *  – Subtle glass-morphism card
 *  – Soft gradient background
 *  – Light-weight stagger animations
 *  – Desktop / tablet / mobile ready
 * ========================================================== */
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  /* ---------- Controllers ---------- */
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePass = true;

  /* ---------- Animation ---------- */
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuart),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  /* ---------- Handlers ---------- */
  Future<void> _login() async {
    if (_usernameCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username and password'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameBoard()),
    );
  }

  void _playAsGuest() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameBoard()),
    );
  }

  /* ==========================================================
   *  Build – UI Layout
   * ========================================================== */
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width > 800;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D1D1D), Color(0xFF111111)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 420 : 360),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : isTablet ? 36 : 24,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /* ---------- Logo ---------- */
                    _Logo(animation: _fade),
                    const SizedBox(height: 24),

                    /* ---------- Card ---------- */
                    _GlassCard(
                      animation: _fade,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _Title(animation: _fade),
                          const SizedBox(height: 28),
                          _UsernameField(
                            ctrl: _usernameCtrl,
                            animation: _fade,
                          ),
                          const SizedBox(height: 16),
                          _PasswordField(
                            ctrl: _passwordCtrl,
                            obscure: _obscurePass,
                            onToggle: () =>
                                setState(() => _obscurePass = !_obscurePass),
                            animation: _fade,
                          ),
                          const SizedBox(height: 24),
                          _LoginButton(
                            isLoading: _isLoading,
                            onTap: _login,
                            animation: _fade,
                          ),
                          const SizedBox(height: 12),
                          _GuestButton(
                            onTap: _playAsGuest,
                            animation: _fade,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _Footer(animation: _fade),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ==========================================================
 *  Re-usable Widgets
 * ========================================================== */

class _Logo extends StatelessWidget {
  final Animation<double> animation;
  const _Logo({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, 30 * (1 - animation.value)),
        child: Opacity(
          opacity: animation.value,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(.08),
                  Colors.white.withOpacity(.02),
                ],
              ),
            ),
            child: const Icon(
              Icons.castle,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  const _GlassCard({required this.child, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, 40 * (1 - animation.value)),
        child: Opacity(
          opacity: animation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(.15)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(.08),
                  Colors.white.withOpacity(.03),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final Animation<double> animation;
  const _Title({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: animation.value,
        child: Column(
          children: [
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[200],
                letterSpacing: .5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Login to continue',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsernameField extends StatelessWidget {
  final TextEditingController ctrl;
  final Animation<double> animation;
  const _UsernameField({required this.ctrl, required this.animation});

  @override
  Widget build(BuildContext context) {
    return _Field(
      ctrl: ctrl,
      hint: 'Username or Email',
      icon: Icons.person_outline,
      animation: animation,
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController ctrl;
  final bool obscure;
  final VoidCallback onToggle;
  final Animation<double> animation;
  const _PasswordField({
    required this.ctrl,
    required this.obscure,
    required this.onToggle,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return _Field(
      ctrl: ctrl,
      hint: 'Password',
      icon: Icons.lock_outline,
      obscure: obscure,
      toggle: onToggle,
      animation: animation,
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? toggle;
  final Animation<double> animation;
  const _Field({
    required this.ctrl,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.toggle,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: animation.value,
        child: TextField(
          controller: ctrl,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(.06),
            prefixIcon: Icon(icon, color: Colors.white54),
            suffixIcon: toggle != null
                ? IconButton(
              onPressed: toggle,
              icon: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.white54,
                size: 20,
              ),
            )
                : null,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final Animation<double> animation;
  const _LoginButton({
    required this.isLoading,
    required this.onTap,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: animation.value,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            )
                : const Text(
              'Login',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestButton extends StatelessWidget {
  final VoidCallback onTap;
  final Animation<double> animation;
  const _GuestButton({required this.onTap, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: animation.value,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Play as Guest',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final Animation<double> animation;
  const _Footer({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: animation.value,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'New here?  ',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sign-up feature coming soon'),
                  backgroundColor: Colors.blueAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              ),
              child: Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.greenAccent[400],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}