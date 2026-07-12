import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Privacy Policy",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      title: "1. Types data we collect",
                      content:
                          "We collect only the data needed to provide you with a personalized and safe focus-tracking experience.\n"
                          "This may include your focus activity, app interactions, and optional cognitive training preferences.\n"
                          "We do not collect any unnecessary or sensitive data.",
                      textColor: textColor,
                    ),
                    const SizedBox(height: 24),
                    _buildDivider(textColor),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: "2. Use of your personal data",
                      content:
                          "Your data is used to improve your cognitive insights, deliver real-time focus monitoring, and personalize training tools such as exercises and binaural beats.\n"
                          "All recommendations are generated safely using our RAG-based AI engine. Your information is never used for advertising or shared without your consent.",
                      textColor: textColor,
                    ),
                    const SizedBox(height: 24),
                    _buildDivider(textColor),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: "3. Disclosure of your personal data",
                      content:
                          "We do not share your personal data with third parties unless required to maintain core app functionality or when you explicitly choose to enable optional features such as adaptive Stimulation.\n"
                          "All data is processed with strict client-side safety controls to ensure full protection and transparency.",
                      textColor: textColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content, required Color textColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            color: textColor.withOpacity(0.8),
            height: 1.5, // Line height for readability
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(Color textColor) {
    return Divider(
      height: 1,
      thickness: 1,
      color: textColor.withOpacity(0.1),
    );
  }
}
