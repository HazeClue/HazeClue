import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/api_service.dart';
import 'navigation_shell.dart';
import '../widgets/glass_widgets.dart';
import '../utils/transitions.dart';

class TdcsConsentScreen extends StatefulWidget {
  const TdcsConsentScreen({super.key});

  @override
  State<TdcsConsentScreen> createState() => _TdcsConsentScreenState();
}

class _TdcsConsentScreenState extends State<TdcsConsentScreen> {
  final List<bool> _checklist = List.generate(5, (_) => false);
  final bool _consentDataUsage = false;
  final bool _consentActivateTdcs = false;
  bool _isSubmitting = false;

  Future<void> _submitConsent(bool isActivated) async {
    if (isActivated && !_checklist.every((c) => c)) {
      showGlassToast(context, 'Please check all safety boxes');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final payload = {
        'isActivated': isActivated,
        'dataUsageConsent': isActivated,
        'checklist': _checklist,
      };
      await ApiService.submitTdcsConsent(payload);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        GlassPageRoute(page: const MainNavigationShell()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      showGlassToast(context, 'Submission failed: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Stimulation Consent",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Intro Section ---
                const Text(
                  "Understanding Stimulation",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildParagraph(
                  "Stimulation is a non-invasive brain stimulation method that uses a low-level, constant electrical current to stimulate specific brain areas.",
                ),
                _buildParagraph(
                  "When used with HazeClue, Stimulation aims to enhance cognitive functions such as focus, attention, and learning, helping you achieve peak mental performance in your gamified challenges. The effects are typically subtle and cumulative.",
                ),
                _buildParagraph(
                  "It is important to use Stimulation responsibly and according to guidelines. Your safety is our top priority.",
                ),
                const SizedBox(height: 32),

                // --- Checklist Section ---
                const Text(
                  "Essential Safety Checklist",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                _buildParagraph(
                  "Before activating Stimulation, please confirm the following to ensure safe and effective use.",
                ),
                const SizedBox(height: 16),

                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildChecklistItem(
                          index: 0,
                          title: "I have consulted a medical professional",
                          subtitle:
                              "Ensure Stimulation is suitable for your individual health conditions.",
                        ),
                        _buildChecklistItem(
                          index: 1,
                          title:
                              "I have no metallic implants or electronic devices in my head/body",
                          subtitle:
                              "Such devices can interfere with Stimulation, posing safety risks.",
                        ),
                        _buildChecklistItem(
                          index: 2,
                          title:
                              "My scalp/skin is healthy and free from cuts, lesions, or irritation",
                          subtitle:
                              "Healthy skin is crucial for proper electrode contact and safety.",
                        ),
                        _buildChecklistItem(
                          index: 3,
                          title: "I am not pregnant or breastfeeding",
                          subtitle:
                              "Stimulation safety during pregnancy/breastfeeding is not established.",
                        ),
                        _buildChecklistItem(
                          index: 4,
                          title:
                              "I understand the potential risks and side effects",
                          subtitle:
                              "Familiarize yourself with possible mild sensations or rare adverse effects.",
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- Presets Section ---
                const Text(
                  "Stimulation Intensity Presets",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                _buildParagraph(
                  "Choose an intensity level based on your comfort and desired cognitive boost.",
                ),
                const SizedBox(height: 16),

                _buildPresetCard(
                  icon: Icons.flash_on,
                  title: "Low Focus",
                  subtitle:
                      "Gentle stimulation for mild cognitive enhancement and relaxation.",
                ),
                _buildPresetCard(
                  icon: Icons.psychology,
                  title: "Medium Concentration",
                  subtitle:
                      "Balanced current for enhanced attention and sustained focus.",
                ),
                _buildPresetCard(
                  icon: Icons.bolt,
                  title: "High Peak Performance",
                  subtitle:
                      "More intensive stimulation for maximum cognitive demand activities.",
                ),
                const SizedBox(height: 40),

                // --- Buttons ---
                _isSubmitting
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Column(
                        children: [
                          GlassButton(
                            text: "Activate Stimulation & Continue",
                            onPressed: () => _submitConsent(true),
                          ),
                          const SizedBox(height: 16),
                          GlassButton(
                            text: "Opt Out Completely",
                            isOutlined: true,
                            onPressed: () => _submitConsent(false),
                          ),
                        ],
                      ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required int index,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _checklist[index],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _checklist[index] = val);
                }
              },
              activeColor: const Color(0xFF8B5CF6),
              checkColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.verified_user_outlined,
            color: Color(0xFF8B5CF6),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
        CupertinoSwitch(
          value: value,
          activeTrackColor: const Color(0xFF8B5CF6),
          thumbColor: Colors.white,
          inactiveTrackColor: Colors.white.withOpacity(0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
