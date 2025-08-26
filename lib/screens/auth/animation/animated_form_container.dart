import 'package:flutter/material.dart';

class AnimatedFormContainer extends StatefulWidget {
  final Widget child;
  final String title;
  final double? height;
  final double? width;
  final EdgeInsets padding;
  final Duration? animationDuration;
  final Curve? animationCurve;

  const AnimatedFormContainer({
    super.key,
    required this.child,
    required this.title,
    this.height,
    this.width,
    this.padding = const EdgeInsets.all(16.0),
    this.animationDuration = const Duration(milliseconds: 1000),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  _AnimatedFormContainerState createState() => _AnimatedFormContainerState();
}

class _AnimatedFormContainerState extends State<AnimatedFormContainer> 
with TickerProviderStateMixin {
   late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

    @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: widget.animationDuration!,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: widget.animationCurve!),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    // ✅ AUTOMATYCZNY START ANIMACJI
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return  FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color:  Colors.transparent,
          child: Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(102),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          
                          // ✅ ANIMOWANY TYTUŁ
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1200),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Text(
                                  widget.title,
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                       
                          widget.child,
                          
                          const SizedBox(height: 20),
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