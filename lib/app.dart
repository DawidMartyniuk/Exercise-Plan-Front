import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_plan_front/core/app_router.dart';
import 'package:work_plan_front/screens/splash/splash.dart';

import 'package:work_plan_front/theme/app_theme.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
  }

  @override
  void dispose() {
    // DeepLinkHandler.dispose(); // Odkomentuj gdy stworzysz DeepLinkHandler
    super.dispose();
  }

  void _initializeDeepLinks() {
    // DeepLinkHandler.initialize(navigatorKey); // Odkomentuj gdy stworzysz DeepLinkHandler
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flex Plan',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      navigatorKey: navigatorKey,
      home: SplashScreen(), //TERAZ TO SPLASH SCREEN
      routes: AppRouter.routes,
    );
  }
}
