import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/idcash_api.dart';
import 'main.dart' show WelcomeScreen, royalBlue;

const _firstLaunchKey = 'idcash_customer_intro_completed_v1';

class FirstLaunchGate extends StatefulWidget {
  const FirstLaunchGate({super.key, required this.api});
  final IdcashApi api;

  @override
  State<FirstLaunchGate> createState() => _FirstLaunchGateState();
}

class _FirstLaunchGateState extends State<FirstLaunchGate> {
  bool? complete;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => complete = prefs.getBool(_firstLaunchKey) ?? false);
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);
    if (mounted) setState(() => complete = true);
  }

  @override
  Widget build(BuildContext context) {
    if (complete == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (complete!) return WelcomeScreen(api: widget.api);
    return UserIntroduction(onFinish: _finish);
  }
}

class UserIntroduction extends StatefulWidget {
  const UserIntroduction({super.key, required this.onFinish});
  final Future<void> Function() onFinish;

  @override
  State<UserIntroduction> createState() => _UserIntroductionState();
}

class _UserIntroductionState extends State<UserIntroduction> {
  final PageController controller = PageController();
  int index = 0;
  static const slides = [
    'assets/images/onboarding_face.png',
    'assets/images/onboarding_idc.png',
    'assets/images/onboarding_send.png',
    'assets/images/onboarding_services.png',
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: widget.onFinish,
                      child: const Text('Skip'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: slides.length,
                  onPageChanged: (value) => setState(() => index = value),
                  itemBuilder: (context, slide) => Semantics(
                    label: 'ID-CASH introduction slide ${slide + 1} of ${slides.length}',
                    child: Image.asset(
                      slides[slide],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text('ID-CASH introduction ${slide + 1}',
                          style: const TextStyle(color: royalBlue, fontSize: 20)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (position) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 8,
                  width: index == position ? 24 : 8,
                  decoration: BoxDecoration(
                    color: index == position ? royalBlue : const Color(0xFFB7D8E3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                )),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: index == slides.length - 1
                        ? widget.onFinish
                        : () => controller.nextPage(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeInOut,
                            ),
                    child: Text(index == slides.length - 1 ? 'Get started' : 'Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
