import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();

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
          "Help & Support",
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                GlassTextField(
                  label: "Search",
                  hint: "Search FAQs...",
                  controller: _searchController,
                  icon: Icons.search,
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  "Frequently Asked Questions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Expansion Tiles
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        _buildFAQCategory(
                          title: "EEG & Focus Monitoring",
                          count: "3",
                          initiallyExpanded: true,
                          textColor: textColor,
                          children: [
                            _buildFAQItem(
                              question: "How does HazeClue measure my focus?",
                              answer:
                                  "HazeClue connects to EEG headbands to read your brainwaves in real-time, analyzing alpha and beta bands to accurately determine your concentration levels.",
                              textColor: textColor,
                            ),
                            _buildFAQItem(
                              question: "What do the Focus percentages mean?",
                              answer:
                                  "A higher percentage indicates deep concentration (dominance of Beta waves), while lower percentages might indicate relaxation or distraction.",
                              textColor: textColor,
                            ),
                            _buildFAQItem(
                              question: "How to wear the EEG device correctly?",
                              answer:
                                  "Ensure the sensors make direct contact with your skin, particularly your forehead, and that any reference clips are securely attached for accurate readings.",
                              textColor: textColor,
                            ),
                          ],
                        ),
                        _buildDivider(textColor),
                        _buildFAQCategory(
                          title: "Stimulation & Cognitive Training",
                          count: "3",
                          initiallyExpanded: false,
                          textColor: textColor,
                          children: [
                            _buildFAQItem(
                              question: "What is Stimulation and is it safe?",
                              answer:
                                  "Cognitive Stimulation (Stimulation) delivers a mild, safe electrical current to stimulate specific brain areas. HazeClue strictly enforces safe intensity limits (max 2mA).",
                              textColor: textColor,
                            ),
                            _buildFAQItem(
                              question: "How often should I run Stimulation sessions?",
                              answer:
                                  "We recommend starting with 2-3 sessions per week, with each session lasting between 10 to 20 minutes, depending on the cognitive training module you select.",
                              textColor: textColor,
                            ),
                            _buildFAQItem(
                              question: "Can I use Binaural Beats with Stimulation?",
                              answer:
                                  "Absolutely! Combining our Binaural Beats presets with Stimulation can synergistically enhance either relaxation or focus, depending on the frequencies selected.",
                              textColor: textColor,
                            ),
                          ],
                        ),
                        _buildDivider(textColor),
                        _buildFAQCategory(
                          title: "Troubleshooting",
                          count: "2",
                          initiallyExpanded: false,
                          textColor: textColor,
                          children: [
                            _buildFAQItem(
                              question: "My device keeps disconnecting",
                              answer:
                                  "Ensure your headset is fully charged and within Bluetooth range. You can easily manage connected devices in the 'My Devices' tab on the Dashboard.",
                              textColor: textColor,
                            ),
                            _buildFAQItem(
                              question: "App isn't showing live focus data",
                              answer:
                                  "Check the sensor quality. If the signal is poor, try wiping your forehead and the sensors with a damp cloth to improve conductivity and Bluetooth transmission.",
                              textColor: textColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCategory({
    required String title,
    required String count,
    required bool initiallyExpanded,
    required Color textColor,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent, // Remove borders
        unselectedWidgetColor: textColor.withOpacity(0.5),
        colorScheme: ColorScheme.dark(
          primary: textColor,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ),
          ],
        ),
        iconColor: textColor,
        collapsedIconColor: textColor.withOpacity(0.5),
        childrenPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        children: children,
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer, required Color textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.help_outline, color: Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color textColor) {
    return Divider(
      height: 1,
      thickness: 1,
      color: textColor.withOpacity(0.1),
      indent: 16,
      endIndent: 16,
    );
  }
}
