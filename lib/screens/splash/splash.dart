import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/screens/auth/login.dart';
import 'package:work_plan_front/screens/splash/app_initializer.dart';
import 'package:work_plan_front/screens/tabs.dart';
import 'package:work_plan_front/provider/authProvider.dart';

class SplashScreen extends ConsumerStatefulWidget {  // ✅ ZMIEŃ NA ConsumerStatefulWidget
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();  // ✅ ConsumerState
}

class _SplashScreenState extends ConsumerState<SplashScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  
  bool _isInitialized = false;
  String _loadingText = 'Initializing...';
  int _currentStep = 0;
  int _totalSteps = 6;

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

    _scaleController.forward();
    _fadeController.repeat(reverse: true);
  }

  Future<void> _startInitialization() async {
    try {
      // ✅ KROK 1: PODSTAWOWA INICJALIZACJA
      _updateLoadingText('Initializing app...', 1);
      await Future.delayed(Duration(milliseconds: 500));
      
      await AppInitializer.initialize();
      
      // ✅ KROK 2: SPRAWDŹ STAN LOGOWANIA
      _updateLoadingText('Checking authentication...', 2);
      await Future.delayed(Duration(milliseconds: 300));
      
      final authResponse = ref.read(authProviderLogin);
      final isLoggedIn = authResponse != null;
      
      if (isLoggedIn) {
        // ✅ KROK 3-6: ŁADUJ WSZYSTKIE DANE
        _updateLoadingText('Loading exercises...', 3);
        await Future.delayed(Duration(milliseconds: 400));
        
        _updateLoadingText('Loading workout plans...', 4);
        await Future.delayed(Duration(milliseconds: 400));
        
        _updateLoadingText('Loading training history...', 5);
        await Future.delayed(Duration(milliseconds: 400));
        
        // ✅ ŁADUJ WSZYSTKIE DANE
       
        await AppInitializer.loadAllData(ref);

        _updateLoadingText('Preparing dashboard...', 6);
        await Future.delayed(Duration(milliseconds: 500));
        
        setState(() {
          _isInitialized = true;
          _loadingText = 'Welcome back!';
        });

        await Future.delayed(Duration(milliseconds: 800));
        _navigateToMain(true); // ✅ PRZEJDŹ DO DASHBOARDU
        
      } else {
        // ✅ UŻYTKOWNIK NIEZALOGOWANY
        _updateLoadingText('Preparing login...', 6);
        await Future.delayed(Duration(milliseconds: 500));
        
        setState(() {
          _isInitialized = true;
          _loadingText = 'Welcome!';
        });

        await Future.delayed(Duration(milliseconds: 800));
        _navigateToMain(false); // ✅ PRZEJDŹ DO LOGOWANIA
      }
      
    } catch (e) {
      print('❌ Initialization error: $e');
      _updateLoadingText('Error occurred. Retrying...', _currentStep);
      await Future.delayed(Duration(seconds: 2));
      _startInitialization();
    }
  }

  void _updateLoadingText(String text, int step) {
    if (mounted) {
      setState(() {
        _loadingText = text;
        _currentStep = step;
      });
    }
  }

  void _navigateToMain(bool isLoggedIn) {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => isLoggedIn 
            ? TabsScreen(selectedPageIndex: 0) //  PRZEJDŹ DO DASHBOARDU
            : LoginScreen(), //  PRZEJDŹ DO LOGOWANIA
        ),
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
    final progressValue = _currentStep / _totalSteps;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                  
                  // ✅ LOGO
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
                  
                  // ✅ NAZWA APLIKACJI
                  AnimatedBuilder(
                    animation: _scaleController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _scaleController.value.clamp(0.0, 1.0),
                        child: Column(
                          children: [
                            Text(
                              'Flex Plan',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Your Personal Training Assistant',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 80),
                  
                  // ✅ LOADING SECTION Z POSTĘPEM
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          value: progressValue, // ✅ POKAZUJ REALNY POSTĘP
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          _loadingText,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      // ✅ POSTĘP W TEKŚCIE
                      Text(
                        'Step $_currentStep of $_totalSteps',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
                          fontSize: 12,
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // ✅ PASEK POSTĘPU
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: 4,
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
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
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
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

  // ✅ LOGO BEZ ZMIAN
  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(25),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withAlpha(50),
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
    return Image.asset(
      'assets/icon/FlexPlan.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/icon/logoFlex.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
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