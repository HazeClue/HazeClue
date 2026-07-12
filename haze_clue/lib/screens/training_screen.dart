import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'concentration_puzzle_screen.dart';
import 'memory_training_screen.dart';
import 'my_devices_screen.dart';
import '../widgets/glass_widgets.dart';
import '../utils/transitions.dart';
import 'tdcs_session_screen.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  double _intensityLevel = 0.5;
  bool _isLoading = true;
  String? _currentlyPlaying;

  @override
  void initState() {
    super.initState();
    _loadDeviceSettings();
  }

  Future<void> _loadDeviceSettings() async {
    try {
      final settings = await ApiService.getDeviceSettings();
      if (mounted) {
        setState(() {
          _intensityLevel = (settings['intensityLevel'] as num?)?.toDouble() ?? 0.5;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Failed to load device settings: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateIntensity(double value) {
    setState(() => _intensityLevel = value);
  }

  Future<void> _saveIntensity(double value) async {
    try {
      await ApiService.updateDeviceSettings(value);
    } catch (e) {
      debugPrint("Failed to save intensity: $e");
      if (mounted) {
        showGlassToast(context, "Failed to save settings: $e");
      }
    }
  }

  void _toggleAudio(String title) {
    setState(() {
      if (_currentlyPlaying == title) {
        _currentlyPlaying = null; // Pause
      } else {
        _currentlyPlaying = title; // Play
        showGlassToast(context, "Now playing: $title...", isError: false);
      }
    });
  }

  Future<void> _startTdcsSession() async {
    // Show duration picker directly without checking for connected device

    showDialog(
      context: context,
      builder: (ctx) {
        int selectedDuration = 2;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text("Session Duration", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Choose the duration for your Stimulation stimulation session:",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [1, 2, 3].map((duration) {
                      final isSelected = selectedDuration == duration;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() => selectedDuration = duration);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
                            border: Border.all(color: const Color(0xFF8B5CF6)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$duration min",
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF8B5CF6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      this.context,
                      GlassPageRoute(
                        page: TdcsSessionScreen(
                          initialIntensity: _intensityLevel,
                          durationMinutes: selectedDuration,
                        ),
                      ),
                    );
                  },
                  child: const Text("Start Session", style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background transparent to let AnimatedBackground show
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Training & Setting",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            "Cognitive Training Modules",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 16),
          _trainingItem(
            "Focus Enhancement",
            "Exercises designed to sharpen focus",
            Icons.center_focus_strong,
            textColor,
            onTap: () {
              Navigator.push(
                context,
                GlassPageRoute(page: const ConcentrationPuzzleScreen()),
              );
            },
          ),
          _trainingItem(
            "Memory Training",
            "Improve recall and retention",
            Icons.extension,
            textColor,
            onTap: () {
              Navigator.push(
                context,
                GlassPageRoute(page: const MemoryTrainingScreen()),
              );
            },
          ),

          const SizedBox(height: 40),
          Text(
            "Binaural Beats Presets",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 16),
          _audioPresetCard(
            "Alpha Wave Relaxation",
            "30 min",
            "Ideal for stress relief",
            textColor,
          ),
          _audioPresetCard(
            "Theta Wave Meditation",
            "45 min",
            "Enhances creative thinking",
            textColor,
          ),

          const SizedBox(height: 40),
          Text(
            "Stimulation Settings",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? Center(child: CircularProgressIndicator(color: textColor))
              : _buildStimulationSettings(textColor),
          const SizedBox(height: 100), // Padding for bottom nav
        ],
      ),
    );
  }

  Widget _trainingItem(String title, String sub, IconData icon, Color textColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF8B5CF6), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sub,
                        style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: textColor.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _audioPresetCard(String title, String time, String desc, Color textColor) {
    bool isPlaying = _currentlyPlaying == title;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        time,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B5CF6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _toggleAudio(title),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isPlaying ? Colors.redAccent : const Color(0xFF8B5CF6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isPlaying ? Colors.redAccent : const Color(0xFF8B5CF6)).withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white, // Keep icon white due to red/purple background
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStimulationSettings(Color textColor) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Intensity Level",
                  style: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontSize: 16),
                ),
                Text(
                  "${(_intensityLevel * 100).toInt()}%",
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF8B5CF6),
                inactiveTrackColor: textColor.withOpacity(0.1),
                thumbColor: textColor,
                overlayColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                trackHeight: 6.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              ),
              child: Slider(
                value: _intensityLevel,
                onChanged: _updateIntensity,
                onChangeEnd: _saveIntensity,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                text: "Start Stimulation Session",
                onPressed: _startTdcsSession,
                icon: Icons.bolt,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
