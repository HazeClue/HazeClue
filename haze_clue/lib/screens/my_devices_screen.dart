import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../services/api_service.dart';
import '../services/smartwatch_service.dart';
import '../widgets/glass_widgets.dart';

class MyDevicesScreen extends ConsumerStatefulWidget {
  const MyDevicesScreen({super.key});

  @override
  ConsumerState<MyDevicesScreen> createState() => _MyDevicesScreenState();
}

class _MyDevicesScreenState extends ConsumerState<MyDevicesScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = ["All", "EEG", "Smartwatch"];
  late Future<List<dynamic>> _devicesFuture;
  
  bool _isScanning = false;
  List<Map<String, String>> _scannedDevices = [];
  bool _isSyncing = false;
  final SmartwatchService _smartwatchService = SmartwatchService();

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() {
    setState(() {
      _devicesFuture = ApiService.getDevices().then((devices) {
        if (mounted) {
          ref.read(isDeviceConnectedProvider.notifier).setConnected(devices.isNotEmpty);
        }
        return devices;
      });
    });
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _scannedDevices.clear();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scannedDevices = [
            {"name": "Muse S (Gen 2)", "mac": "00:11:22:33:44:55"},
            {"name": "NeuroSky MindWave", "mac": "AA:BB:CC:DD:EE:FF"},
          ];
        });
      }
    });
  }

  Future<void> _connectDevice(String name, String mac) async {
    try {
      await ApiService.addDevice(name, mac);
      _loadDevices();
      setState(() {
         _scannedDevices.removeWhere((d) => d['mac'] == mac);
      });
      if (mounted) showGlassToast(context, "Device connected successfully", isError: false);
    } catch (e) {
      if (!mounted) return;
      showGlassToast(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _removeDevice(String id) async {
    try {
      await ApiService.deleteDevice(id);
      _loadDevices();
      if (mounted) showGlassToast(context, "Device removed successfully", isError: false);
    } catch (e) {
      if (!mounted) return;
      showGlassToast(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _syncSmartwatchData() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await _smartwatchService.fetchAndSyncData();
      if (mounted) showGlassToast(context, "Smartwatch data synced successfully!", isError: false);
    } catch (e) {
      if (mounted) showGlassToast(context, "Error syncing data", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

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
          "My Devices",
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
                // --- Device Categories ---
                Text(
                  "Device Categories",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      _categories.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedCategory == index 
                                  ? const Color(0xFF8B5CF6) 
                                  : textColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedCategory == index 
                                    ? const Color(0xFF8B5CF6) 
                                    : textColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_selectedCategory == index) ...[
                                  const Icon(Icons.check, size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  _categories[index],
                                  style: TextStyle(
                                    color: _selectedCategory == index ? Colors.white : textColor.withOpacity(0.7),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  "Connected Devices",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<dynamic>>(
                  future: _devicesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: textColor));
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Error loading devices", style: TextStyle(color: Colors.redAccent)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text("No devices connected.", style: TextStyle(color: textColor.withOpacity(0.6))),
                      );
                    }
                    final devices = snapshot.data!;
                    return Column(
                      children: devices.map((d) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildConnectedDeviceItem(
                            context: context,
                            id: d['id'],
                            icon: Icons.psychology_outlined,
                            name: d['name'] ?? "Unknown Device",
                            model: d['macAddress'] ?? "Unknown MAC",
                            battery: "ca. 85%", // mock
                            signal: "good", // mock
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // --- Available Devices ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Available Devices",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _isScanning ? null : _startScan,
                      icon: _isScanning 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8B5CF6))) 
                        : const Icon(Icons.bluetooth_searching, color: Color(0xFF8B5CF6)),
                      label: Text(_isScanning ? "Scanning..." : "Scan", style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                if (_scannedDevices.isEmpty && !_isScanning)
                  GlassCard(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.bluetooth_disabled, color: textColor.withOpacity(0.5), size: 40),
                          const SizedBox(height: 8),
                          Text("No devices found", style: TextStyle(color: textColor.withOpacity(0.7), fontWeight: FontWeight.w500)),
                          Text("Tap scan to search for nearby headsets", style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ..._scannedDevices.map((device) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildAvailableDeviceItem(
                    context: context,
                    icon: Icons.psychology,
                    name: device['name']!,
                    signal: "good",
                    onTap: () => _connectDevice(device['name']!, device['mac']!),
                  ),
                )),
                if (_selectedCategory == 2 || _selectedCategory == 0) ...[
                  const SizedBox(height: 32),
                  Text(
                    "Smartwatch Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isSyncing ? null : _syncSmartwatchData,
                    child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: _isSyncing
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8B5CF6)),
                                    )
                                  : const Icon(Icons.sync, size: 28, color: Color(0xFF8B5CF6)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sync Apple Health / Google Fit",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "Pull latest sleep, HRV, and activity data",
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedDeviceItem({
    required BuildContext context,
    required String id,
    required IconData icon,
    required String name,
    required String model,
    required String battery,
    required String signal,
  }) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    model,
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.battery_charging_full, size: 14, color: Colors.greenAccent),
                      const SizedBox(width: 4),
                      Text(
                        battery,
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.wifi, size: 14, color: Colors.greenAccent),
                      const SizedBox(width: 4),
                      const Text(
                        "Connected",
                        style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.settings_outlined, color: textColor, size: 20),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _removeDevice(id),
              child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableDeviceItem({
    required BuildContext context,
    required IconData icon,
    required String name,
    required String signal,
    required VoidCallback onTap,
  }) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: textColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
                ),
                child: const Text(
                  "Connect",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
