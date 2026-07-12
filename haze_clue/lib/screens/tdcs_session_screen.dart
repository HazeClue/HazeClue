import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/glass_widgets.dart';
import '../services/api_service.dart';

class TdcsSessionScreen extends StatefulWidget {
  final double initialIntensity;
  final int durationMinutes;

  const TdcsSessionScreen({
    super.key,
    required this.initialIntensity,
    required this.durationMinutes,
  });

  @override
  State<TdcsSessionScreen> createState() => _TdcsSessionScreenState();
}

class _TdcsSessionScreenState extends State<TdcsSessionScreen>
    with TickerProviderStateMixin {
  late double _currentIntensity;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isPlaying = false;
  bool _isFinished = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _statusMessages = [
    "Calibrating electrodes...",
    "Ramping up current...",
    "Stimulating DLPFC region...",
    "Maintaining target intensity...",
    "Optimizing neuroplasticity...",
  ];
  int _statusIndex = 0;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _currentIntensity = widget.initialIntensity;
    _remainingSeconds = widget.durationMinutes * 60;

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _getPulseDuration()),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startSession();
  }

  int _getPulseDuration() {
    // Higher intensity = faster pulse
    // 0.0 -> 2000ms, 1.0 -> 500ms
    return 2000 - (_currentIntensity * 1500).toInt();
  }

  void _updatePulseSpeed() {
    _pulseController.duration = Duration(milliseconds: _getPulseDuration());
    if (_isPlaying) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _startSession() {
    setState(() {
      _isPlaying = true;
    });
    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _finishSession();
        }
      });
    });

    _statusTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted && _isPlaying && _remainingSeconds > 60) {
        setState(() {
          _statusIndex = (_statusIndex + 1) % _statusMessages.length;
        });
      }
    });
  }

  void _pauseSession() {
    setState(() {
      _isPlaying = false;
    });
    _timer?.cancel();
    _statusTimer?.cancel();
    _pulseController.stop();
  }

  Future<void> _finishSession() async {
    _pauseSession();
    setState(() {
      _isFinished = true;
      _remainingSeconds = 0;
      _statusIndex =
          0; // Or set to a specific "Cooling down" message if we had one
    });

    try {
      // Save session to backend
      final sessionData = await ApiService.createSession(
        "Stimulation Stimulation",
        widget.durationMinutes,
        null,
      );
      final sessionId = sessionData['id'];
      if (sessionId != null) {
        await ApiService.completeSession(
          sessionId,
          (_currentIntensity * 100)
              .toInt(), // Use intensity as a proxy for concentration/score for now
          widget.durationMinutes * 60,
        );
      }
      if (mounted) {
        showGlassToast(context, "Session saved successfully!", isError: false);
      }
    } catch (e) {
      if (mounted) {
        showGlassToast(context, "Completed, but failed to save to server.");
      }
    }
  }

  void _stopSessionEarly() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        title: const Text(
          "Stop Session",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to stop the Stimulation stimulation early?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _finishSession();
            },
            child: const Text(
              "Stop",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: textColor),
        title: Text(
          "Stimulation Session",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Brain Pulse Animation
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF8B5CF6,
                                  ).withOpacity(0.3 * _currentIntensity),
                                  blurRadius: 50 * _pulseAnimation.value,
                                  spreadRadius: 20 * _pulseAnimation.value,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.psychology,
                                  size: 120,
                                  color: const Color(0xFF8B5CF6).withOpacity(
                                    0.8 + (0.2 * _currentIntensity),
                                  ),
                                ),
                                if (!_isPlaying && !_isFinished)
                                  Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.pause,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),

                      // Timer
                      Text(
                        _formatTime(_remainingSeconds),
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w300,
                          color: textColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Status Text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          _isFinished
                              ? "Session Completed"
                              : (_isPlaying
                                    ? _statusMessages[_statusIndex]
                                    : "Session Paused"),
                          key: ValueKey<String>(
                            _isFinished
                                ? "done"
                                : (_isPlaying
                                      ? _statusMessages[_statusIndex]
                                      : "paused"),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Controls & Slider
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Intensity",
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),
                        Text(
                          "${(_currentIntensity * 100).toInt()}%",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF8B5CF6),
                        inactiveTrackColor: textColor.withOpacity(0.1),
                        thumbColor: const Color(0xFF8B5CF6),
                        trackHeight: 4.0,
                      ),
                      child: Slider(
                        value: _currentIntensity,
                        onChanged: _isFinished
                            ? null
                            : (val) {
                                setState(() {
                                  _currentIntensity = val;
                                  _updatePulseSpeed();
                                });
                              },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.stop_rounded,
                          color: Colors.redAccent,
                          onTap: _isFinished ? null : _stopSessionEarly,
                        ),
                        _buildControlButton(
                          icon: _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: const Color(0xFF8B5CF6),
                          size: 72,
                          iconSize: 40,
                          onTap: _isFinished
                              ? null
                              : () {
                                  if (_isPlaying) {
                                    _pauseSession();
                                  } else {
                                    _startSession();
                                  }
                                },
                        ),
                        _buildControlButton(
                          icon: Icons.check_rounded,
                          color: Colors.greenAccent,
                          onTap: _isFinished
                              ? () => Navigator.pop(context)
                              : null,
                        ),
                      ],
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

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    double size = 56,
    double iconSize = 28,
  }) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDisabled ? color.withOpacity(0.2) : color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDisabled ? Colors.transparent : color.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: isDisabled ? color.withOpacity(0.5) : color,
          size: iconSize,
        ),
      ),
    );
  }
}
