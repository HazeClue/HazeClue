import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import '../widgets/glass_widgets.dart';
import '../utils/transitions.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Map<String, String>> _contents = [
    {
      'image': 'assets/images/Intro.png',
      'title': "Unlock your\nMind’s potential",
      'desc': "",
    },
    {
      'image': 'assets/images/Intro1.png',
      'title': "Understand Your\nBrain In Real Time",
      'desc': "Advanced EEG analysis for focus, engagement, and cognitive clarity.",
    },
    {
      'image': 'assets/images/Intro2.png',
      'title': "Personalized Stimulation\nFor Peak Performance",
      'desc': "Adaptive STIMULATION and binaural beats tailored to your brain's activity.",
    },
  ];

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // App Logo (White/Glass container for the logo)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)
                  ]
                ),
                child: Icon(Icons.psychology, size: 48, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                "HAZE CLUE",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _contents.length,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                      child: GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Image.asset(
                                  _contents[index]['image']!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => 
                                    const Icon(Icons.image, size: 100, color: Colors.white54),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                _contents[index]['title']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              if (_contents[index]['desc']!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  _contents[index]['desc']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.7),
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _contents.length,
                        (index) => buildDot(index, context),
                      ),
                    ),
                    const SizedBox(height: 30),
                    GlassButton(
                      text: _currentIndex == _contents.length - 1 ? "Get Started" : "Next",
                      onPressed: () {
                        if (_currentIndex == _contents.length - 1) {
                          Navigator.pushReplacement(
                            context,
                            GlassPageRoute(page: const SignInScreen()),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentIndex == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentIndex == index ? textColor : textColor.withOpacity(0.3),
      ),
    );
  }
}
