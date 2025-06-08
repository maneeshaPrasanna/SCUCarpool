
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _carController;
  late AnimationController _textFadeController;
  late Animation<double> _carFadeOut;
  late Animation<double> _textFadeIn;
  bool showText = false;

  @override
  void initState() {
    super.initState();

    _carController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _carFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _carController, curve: Curves.easeOut),
    );

    _textFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textFadeController, curve: Curves.easeIn),
    );

    _carController.forward();

    Timer(const Duration(seconds: 2), () {
      setState(() {
        showText = true;
      });
      _textFadeController.forward();
    });

    Timer(const Duration(seconds: 5), () {
      context.go('/signIn');
    });
  }

  @override
  void dispose() {
    _carController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF811E2D),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FadeTransition(
              opacity: _carFadeOut,
              child: Icon(
                Icons.directions_car,
                size: 100,
                color: Colors.white,
              ),
            ),
            if (showText)
              FadeTransition(
                opacity: _textFadeIn,
                child: const Text(
                  "SCU Carpool",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
