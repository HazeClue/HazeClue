import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'my_devices_screen.dart';
import 'training_screen.dart';
import 'notification_inbox_screen.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/shimmer_loading.dart';
import '../utils/transitions.dart';

class DashboardContent extends ConsumerWidget {
  const DashboardContent({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(recentSessionsProvider);
    ref.invalidate(notificationsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final isLight = Theme.of(context).brightness == Brightness.light;
    
    final statsAsync = ref.watch(dashboardStatsProvider);
    final sessionsAsync = ref.watch(recentSessionsProvider);
    final unreadNotificationsCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Background transparent to let AnimatedBackground show
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLight ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                color: textColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "HazeClue",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_outlined,
                  color: textColor,
                  size: 28,
                ),
                if (unreadNotificationsCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).colorScheme.surface, width: 1.5),
                      ),
                      child: Text(
                        unreadNotificationsCount > 9 ? '+9' : unreadNotificationsCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                GlassPageRoute(
                  page: const NotificationInboxScreen(),
                ),
              );
              ref.invalidate(notificationsProvider);
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(ref),
        backgroundColor: Theme.of(context).colorScheme.surface,
        color: Theme.of(context).colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Stats Card
              statsAsync.when(
                data: (stats) {
                  final isDeviceConnected = ref.watch(isDeviceConnectedProvider);
                  final focusPercentage = (stats['avgAttention'] ?? 100) / 100.0;
                  final focusLabel = '${(focusPercentage * 100).toInt()}%';
                  return _buildFocusCard(context, focusPercentage, focusLabel, textColor, isDeviceConnected);
                },
                loading: () => const ShimmerFocusCard(),
                error: (error, stack) => _buildErrorCard(
                  "Failed to load stats", 
                  textColor, 
                  () => ref.invalidate(dashboardStatsProvider)
                ),
              ),

              const SizedBox(height: 40),
              
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(context, textColor),
              
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Activity",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Icon(Icons.trending_up, color: textColor.withOpacity(0.5)),
                ],
              ),
              const SizedBox(height: 16),
              
              // Recent Activity List
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: sessionsAsync.when(
                    data: (sessions) {
                      if (sessions.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "No recent activities.", 
                              style: TextStyle(color: textColor.withOpacity(0.7))
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: sessions.take(3).map((session) {
                          return _activityTile(
                            Icons.trending_up, 
                            session['title'] ?? 'Session Completed',
                            session['status'] ?? 'Recently',
                            textColor,
                          );
                        }).toList(),
                      );
                    },
                    loading: () => Column(
                      children: const [
                        ShimmerActivityTile(),
                        ShimmerActivityTile(),
                        ShimmerActivityTile(),
                      ],
                    ),
                    error: (error, stack) => _buildErrorCard(
                      "Failed to load activities", 
                      textColor, 
                      () => ref.invalidate(recentSessionsProvider),
                      isSmall: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100), // Padding for the bottom nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusCard(BuildContext context, double focusPercentage, String focusLabel, Color textColor, bool isConnected) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.more_horiz, color: textColor.withOpacity(0.5)),
            ),
            Text(
              "Current Focus",
              style: TextStyle(
                fontSize: 16,
                color: textColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            if (isConnected) ...[
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: CircularProgressIndicator(
                      value: focusPercentage, 
                      strokeWidth: 14,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        focusLabel,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        "Focused",
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Your cognitive state is optimal.\nKeep it up!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: textColor.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology, size: 20, color: textColor.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Text(
                      "Mental Workload: ",
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      "High", // Dummy data
                      style: TextStyle(
                        color: Colors.redAccent, // Red for high, green for optimal
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: textColor.withOpacity(0.2),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.headset_off_outlined, size: 48, color: textColor.withOpacity(0.4)),
                      const SizedBox(height: 8),
                      Text(
                        "No Device",
                        style: TextStyle(color: textColor.withOpacity(0.5), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Waiting for headband connection.\nPlease wear your device to see live focus.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    GlassPageRoute(page: const MyDevicesScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: textColor.withOpacity(0.1),
                  foregroundColor: textColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Connect Device"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, Color textColor, VoidCallback onRetry, {bool isSmall = false}) {
    return GlassCard(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmall ? 20 : 32),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: isSmall ? 32 : 48),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionItem(
          Icons.bolt,
          "Connect\nDevices",
          textColor,
          onTap: () {
            Navigator.push(
              context,
              GlassPageRoute(page: const MyDevicesScreen()),
            );
          },
        ),
        _actionItem(
          Icons.psychology_outlined,
          "Training\nExercises",
          textColor,
          onTap: () {
            Navigator.push(
              context,
              GlassPageRoute(page: const TrainingScreen()),
            );
          },
        ),
        _actionItem(
          Icons.music_note_outlined,
          "Binaural\nBeats",
          textColor,
          onTap: () {
            Navigator.push(
              context,
              GlassPageRoute(page: const TrainingScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _actionItem(IconData icon, String label, Color textColor, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            GlassCard(
              child: SizedBox(
                height: 70,
                width: 70,
                child: Center(
                  child: Icon(icon, color: textColor, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityTile(IconData icon, String title, String time, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
