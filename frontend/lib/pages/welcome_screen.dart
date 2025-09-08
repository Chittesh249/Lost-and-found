import 'package:amrita_retriever/pages/login.dart';
import 'package:amrita_retriever/pages/signup.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _buttonController;
  late AnimationController _goldieController;

  late Animation<double> _logoScale;
  late Animation<Offset> _loginOffset;
  late Animation<Offset> _signupOffset;
  late Animation<double> _goldieFade;

  @override
  void initState() {
    super.initState();

    // Logo animation (scale bounce)
    _logoController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _logoScale =
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut);
    _logoController.forward();

    // Button animation (slide from bottom)
    _buttonController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _loginOffset = Tween(begin: const Offset(0, 2), end: Offset.zero).animate(
        CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));
    _signupOffset = Tween(begin: const Offset(0, 2), end: Offset.zero).animate(
        CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 500), () {
      _buttonController.forward();
    });

    // Goldie fade in
    _goldieController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _goldieFade =
        CurvedAnimation(parent: _goldieController, curve: Curves.easeIn);
    Future.delayed(const Duration(milliseconds: 1000), () {
      _goldieController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _buttonController.dispose();
    _goldieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5316B),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),

              // Logo with bounce
              ScaleTransition(
                scale: _logoScale,
                child: Image.asset(
                  "assets/logo.png",
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 25),

              // Login button slide in
              SlideTransition(
                position: _loginOffset,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                        color: Color(0xFF1A237E),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Signup button slide in
              SlideTransition(
                position: _signupOffset,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupPage()),
                    );
                  },
                  child: const Text(
                    "SignUp",
                    style: TextStyle(
                        color: Color(0xFF1A237E),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Goldie fade in
              FadeTransition(
                opacity: _goldieFade,
                child: Image.asset(
                  'assets/goldie.png',
                  height: 150,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
