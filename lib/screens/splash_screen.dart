import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'dream_input_screen.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Artificial delay for splash effect
    await Future.delayed(const Duration(seconds: 2));
    
    // Initialize storage
    await StorageService.init();
    
    if (!mounted) return;

    // Always navigate to Dashboard after splash
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SplashContent(),
    );
  }
}

/// A reusable widget that renders the visual splash content.
/// This is reused in the bottom-navigation "home" tab.
class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.softGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_rounded,
              size: 80,
              color: AppTheme.primaryPink,
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .then()
            .shimmer(duration: 1200.ms, color: Colors.white),
            
            const SizedBox(height: 20),
            
            Text(
              'StepUp',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 10),
            
            Text(
              'Turn dreams into reality ✨',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.deepPlum.withValues(alpha: 0.7),
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}

/// A stateful splash widget that performs initialization and either calls
/// `onInitialized` with `true` when dreams exist or `false` otherwise.
class SplashHome extends StatefulWidget {
  final ValueChanged<bool>? onInitialized;

  const SplashHome({super.key, this.onInitialized});

  @override
  State<SplashHome> createState() => _SplashHomeState();
}

class _SplashHomeState extends State<SplashHome> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Keep the original 2s splash effect
    await Future.delayed(const Duration(seconds: 2));
    await StorageService.init();
    final dreams = await StorageService.loadDreams();
    if (!mounted) return;

    if (widget.onInitialized != null) {
      widget.onInitialized!(dreams.isNotEmpty);
    } else {
      // Fallback behavior mirrors old SplashScreen
      if (dreams.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DreamInputScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => const SplashContent();
}
