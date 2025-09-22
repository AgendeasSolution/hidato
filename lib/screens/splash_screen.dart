import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/index.dart';
import 'home_screen.dart';

/// Splash screen with app logo and developer credit
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _creditController;
  late Animation<double> _logoAnimation;
  late Animation<double> _creditAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _creditController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _creditAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _creditController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _creditController.forward();
    });
    
    // Navigate to home screen after splash duration
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        // Restore system UI before navigation
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Logo section - perfectly centered in the entire screen
          Center(
            child: AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoAnimation.value,
                  child: Text(
                    'Hidato Puzzle',
                    style: GoogleFonts.jua(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4F46E5),
                      letterSpacing: 3,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              },
            ),
          ),
          
          // Developer credit at bottom-center
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _creditAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - _creditAnimation.value)),
                  child: Opacity(
                    opacity: _creditAnimation.value,
                    child: Column(
                      children: [
                        Text(
                          'Developed by',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4), // Reduced gap
                        Text(
                          'FGTP Labs',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
