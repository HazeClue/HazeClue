import 'dart:async';
import 'dart:math';

/// A service that simulates reading live EEG/Stimulation data from a Bluetooth headset.
/// Once the real hardware is available, replace the Timer logic with actual Bluetooth characteristic reads.
class DeviceDataService {
  Timer? _timer;
  final StreamController<int> _concentrationController = StreamController<int>.broadcast();
  final Random _random = Random();

  Stream<int> get concentrationStream => _concentrationController.stream;

  void startStreaming() {
    // Simulate initial value
    int currentValue = 40 + _random.nextInt(30); // 40% to 70%
    _concentrationController.add(currentValue);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Fluctuate the value slightly to simulate real brain waves
      int change = _random.nextInt(11) - 5; // -5 to +5
      currentValue += change;
      
      // Clamp between 0 and 100
      if (currentValue < 0) currentValue = 0;
      if (currentValue > 100) currentValue = 100;

      if (!_concentrationController.isClosed) {
        _concentrationController.add(currentValue);
      }
    });
  }

  void stopStreaming() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stopStreaming();
    _concentrationController.close();
  }
}
