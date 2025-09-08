import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:work_plan_front/core/app_initializer.dart';
import 'package:work_plan_front/screens/auth/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _isInitialized = false;
  String _loadingText = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _fadeController.repeat(reverse: true);
  }

  Future<void> _startInitialization() async {
    try {
      _updateLoadingText('Initializing Hive database...');
      await Future.delayed(Duration(milliseconds: 500));
      
      await AppInitializer.initialize();
      
      _updateLoadingText('Loading exercises...');
      await Future.delayed(Duration(milliseconds: 800));
      
      _updateLoadingText('Almost ready...');
      await Future.delayed(Duration(milliseconds: 500));
      
      setState(() {
        _isInitialized = true;
        _loadingText = 'Welcome to Flex Plan!';
      });

      await Future.wait([
        _animationController.forward(),
        Future.delayed(Duration(seconds: 2)),
      ]);

      _navigateToMain();
      
    } catch (e) {
      print('❌ Initialization error: $e');
      _updateLoadingText('Error occurred. Retrying...');
      
      await Future.delayed(Duration(seconds: 2));
      _startInitialization();
    }
  }

  void _updateLoadingText(String text) {
    if (mounted) {
      setState(() {
        _loadingText = text;
      });
    }
  }

  void _navigateToMain() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //TODO WYDŁUŻYC ZACZAS ANIMACJE ABY TRFAŁO DŁUŻEJ I WOLNIEJ 
    //  POBIERZ ROZMIAR EKRANU
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            children: [
              //  ANIMACJA - ZAJMUJE WIĘKSZOŚĆ EKRANU
              Expanded(
                flex: 5, //  ZWIĘKSZ FLEX
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.8, //  MAKSYMALNIE 80% SZEROKOŚCI
                      maxHeight: screenHeight * 0.6, //  MAKSYMALNIE 60% WYSOKOŚCI
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.0, // ✅ KWADRATOWY STOSUNEK
                      child: Lottie.asset(
                        'assets/animations/FlexPlanAnimation.json',
                        controller: _animationController,
                        fit: BoxFit.contain, // ✅ DOPASUJ DO KONTENERA
                        repeat: true,
                        onLoaded: (composition) {
                          _animationController.duration = composition.duration;
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              // ✅ LOADING SECTION - ELASTYCZNA WYSOKOŚĆ
              Expanded(
                flex: 2, // ✅ MNIEJSZY FLEX
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Loading indicator
                      Container(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Tekst ładowania z animacją fade
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          _loadingText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2, // ✅ MAKSYMALNIE 2 LINIE
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Progress bar
                      Container(
                        width: screenWidth * 0.6,
                        height: 4,
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: _isInitialized ? 1.0 : _animationController.value,
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // ✅ FOOTER - STAŁA WYSOKOŚĆ
              Container(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}