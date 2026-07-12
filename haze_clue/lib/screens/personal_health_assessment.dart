import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/glass_widgets.dart';
import '../services/api_service.dart';
import 'tdcs_consent_screen.dart';
import '../utils/transitions.dart';

class SmoothScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class PersonalHealthAssessment extends StatefulWidget {
  const PersonalHealthAssessment({super.key});

  @override
  State<PersonalHealthAssessment> createState() =>
      _PersonalHealthAssessmentState();
}

class _PersonalHealthAssessmentState extends State<PersonalHealthAssessment> {
  final PageController _pageController = PageController();
  int _currentStep = 1;
  final int _totalSteps = 7;

  final Map<int, List<int>> _multiSelections = {};
  final Map<int, int?> _singleSelections = {};

  int? _selectedAge;
  bool _isSubmitting = false;

  Future<void> _nextStep() async {
    if (_currentStep < _totalSteps) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _isSubmitting = true);
      try {
        final payload = {
          'multiSelections': _multiSelections.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
          'singleSelections': _singleSelections.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
          'age': _selectedAge,
        };
        await ApiService.submitHealthAssessment(payload);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          GlassPageRoute(page: const TdcsConsentScreen()),
        );
      } catch (e) {
        if (!mounted) return;
        showGlassToast(context, 'Submission failed: $e');
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: SmoothScrollBehavior(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: const BackButton(color: Colors.white),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: AnimatedBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Personal Health Assessment",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _currentStep / _totalSteps,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF8B5CF6),
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "$_currentStep / $_totalSteps",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) =>
                        setState(() => _currentStep = index + 1),
                    children: [
                      SingleChildScrollView(child: _buildStep1()),
                      SingleChildScrollView(child: _buildStep2()),
                      SingleChildScrollView(child: _buildStep3()),
                      _buildStep4(), // Step 4 already has a SingleChildScrollView
                      SingleChildScrollView(child: _buildStep5()),
                      SingleChildScrollView(child: _buildStep6()),
                      SingleChildScrollView(child: _buildStep7()),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : GlassButton(
                          text: _currentStep == _totalSteps ? "FINISH" : "NEXT",
                          onPressed: _isPageValid()
                              ? _nextStep
                              : () => showGlassToast(
                                  context,
                                  "Please complete all fields before continuing",
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

  Widget _buildStep1() => _buildSelectionList(
    1,
    "Do you have any of these conditions that might affect your focus?",
    [
      "Asthma",
      "Epilepsy",
      "Anxiety / Depression",
      "Sleep disorders",
      "Vision/Hearing",
      "Diabetes",
      "Other",
      "None of the above",
    ],
    isMultiselect: true,
  );

  Widget _buildStep2() => Column(
    children: [
      _buildSelectionList(2, "What do you want to get from HazeClue?", [
        "Improve focus",
        "Track brain fog",
        "Stop distractions",
        "Other",
      ], isMultiselect: true),
      _buildSelectionList(3, "Select Your Gender", ["Female", "Male"]),
    ],
  );

  Widget _buildStep3() => Column(
    children: [
      _buildSelectionList(4, "Do you have trouble concentrating?", [
        "Never",
        "Rarely",
        "Sometimes",
        "Often",
        "Very Often",
      ]),
      _buildSelectionList(5, "Have you used brain training before?", [
        "Yes, focus apps",
        "Yes, meditation",
        "No, first time",
      ]),
    ],
  );

  Widget _buildStep4() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectionList(6, "What best describes you?", [
          "Student",
          "Freelancer",
          "Researcher",
          "Homemaker",
          "Other",
        ]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "How old are you?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedAge,
                      isDense: true,
                      menuMaxHeight: 250,
                      hint: Text(
                        "Select age",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 14,
                        ),
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: List.generate(83, (index) => index + 18)
                          .map(
                            (age) => DropdownMenuItem(
                              value: age,
                              child: Text(
                                age.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedAge = value),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      dropdownColor: const Color(0xFF1E1E2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    ),
  );

  Widget _buildStep5() => Column(
    children: [
      _buildSelectionList(7, "How many hours do you sleep?", [
        "5-7",
        "Less than 5",
        "More than 7",
      ]),
      _buildSelectionList(8, "How's your sleep quality?", [
        "Poor",
        "Okay",
        "Good",
        "Great",
      ]),
    ],
  );

  Widget _buildStep6() => Column(
    children: [
      _buildSelectionList(9, "Conditions affecting focus?", [
        "Not much",
        "Moderate",
        "Very active",
      ]),
      _buildSelectionList(10, "When do you feel most focused?", [
        "Morning",
        "Afternoon",
        "Evening",
        "It changes",
      ]),
    ],
  );

  Widget _buildStep7() => Column(
    children: [
      _buildSelectionList(11, "How active are you during the week?", [
        "Not much",
        "Moderate",
        "Very active",
      ]),
      _buildSelectionList(12, "How stressed do you usually feel?", [
        "Low",
        "Medium",
        "High",
        "Very high",
      ]),
    ],
  );

  Widget _buildSelectionList(
    int stepId,
    String title,
    List<String> options, {
    bool isMultiselect = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(options.length, (index) {
                bool isSelected = isMultiselect
                    ? (_multiSelections[stepId]?.contains(index) ?? false)
                    : (_singleSelections[stepId] == index);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () => setState(() {
                      if (isMultiselect) {
                        _multiSelections.putIfAbsent(stepId, () => []);
                        if (index == 7 && stepId == 1) {
                          // Specifically for "None of the above"
                          _multiSelections[stepId] = [7];
                        } else {
                          if (stepId == 1) _multiSelections[stepId]!.remove(7);
                          _multiSelections[stepId]!.contains(index)
                              ? _multiSelections[stepId]!.remove(index)
                              : _multiSelections[stepId]!.add(index);
                        }
                      } else {
                        _singleSelections[stepId] = index;
                      }
                    }),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF8B5CF6)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isMultiselect
                                ? (isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank)
                                : (isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off),
                            color: isSelected
                                ? const Color(0xFF8B5CF6)
                                : Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              options[index],
                              style: TextStyle(
                                fontSize: 15,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  bool _isPageValid() {
    switch (_currentStep) {
      case 1:
        return _multiSelections[1]?.isNotEmpty ?? false;
      case 2:
        return (_multiSelections[2]?.isNotEmpty ?? false) &&
            (_singleSelections[3] != null);
      case 3:
        return (_singleSelections[4] != null) && (_singleSelections[5] != null);
      case 4:
        return (_singleSelections[6] != null) && (_selectedAge != null);
      case 5:
        return (_singleSelections[7] != null) && (_singleSelections[8] != null);
      case 6:
        return (_singleSelections[9] != null) &&
            (_singleSelections[10] != null);
      case 7:
        return (_singleSelections[11] != null) &&
            (_singleSelections[12] != null);
      default:
        return false;
    }
  }
}
