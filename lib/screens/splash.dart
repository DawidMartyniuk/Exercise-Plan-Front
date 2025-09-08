import 'package:flutter/material.dart';
import 'package:work_plan_front/core/app_initializer.dart';
import 'package:work_plan_front/screens/auth/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isInitialized = false;
  String _loadingText = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    _scaleController.forward();
    _fadeController.repeat(reverse: true);
  }

  Future<void> _startInitialization() async {
    try {
      _updateLoadingText('Initializing...');
      await Future.delayed(Duration(milliseconds: 500));
      
      await AppInitializer.initialize();
      
      _updateLoadingText('Loading data...');
      await Future.delayed(Duration(milliseconds: 800));
      
      _updateLoadingText('Almost ready...');
      await Future.delayed(Duration(milliseconds: 500));
      
      setState(() {
        _isInitialized = true;
        _loadingText = 'Welcome!';
      });

      await Future.delayed(Duration(milliseconds: 800));
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
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // ✅ USUŃ GRADIENT - UŻYJ STANDARDOWEGO TŁA JAK W INNYCH EKRANACH
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 80),
                  
                  AnimatedBuilder(
                    animation: _scaleController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleController.value.clamp(0.0, 1.0), 
                        child: _buildLogo(),
                      );
                    },
                  ),
                  
                  SizedBox(height: 32),
                  
                  AnimatedBuilder(
                    animation: _scaleController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _scaleController.value.clamp(0.0, 1.0), // 
                        child: Column(
                          children: [
                           
                            SizedBox(height: 8),
                            
                          ],
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 80), // ✅ ZAMIAST Spacer
                  
                  // ✅ LOADING SECTION
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          _loadingText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: 4,
                        child: AnimatedBuilder(
                          animation: _scaleController,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: _isInitialized ? 1.0 : _scaleController.value.clamp(0.0, 1.0), // ✅ CLAMP
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 80), 
                  
                  // ✅ FOOTER
                  Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ LOGO Z MULTIPLE FALLBACKS
  Widget _buildLogo() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildLogoWithFallback(),
      ),
    );
  }

  Widget _buildLogoWithFallback() {
    // ✅ PRÓBUJ RÓŻNE PLIKI W KOLEJNOŚCI
    return Image.asset(
      'assets/icon/FlexPlan.png', // ✅ PIERWSZY WYBÓR
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('❌ FlexPlan.png not found, trying logoFlex.png');
        return Image.asset(
          'assets/icon/logoFlex.png', // ✅ DRUGI WYBÓR
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ logoFlex.png not found, using icon fallback');
            return Icon(
              Icons.fitness_center,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            );
          },
        );
      },
    );
  }
}