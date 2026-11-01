import 'package:flutter/material.dart';
import 'services/idcash_api.dart';
import 'first_launch.dart';

const royalBlue = Color(0xFF073B67);
const cyanBlue = Color(0xFF76BED2);

void main() {
  const baseUrl = String.fromEnvironment('IDC_API_BASE_URL');
  runApp(IdcashApp(api: IdcashApi(baseUrl: baseUrl)));
}

class IdcashApp extends StatelessWidget {
  const IdcashApp({super.key, required this.api});
  final IdcashApi api;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ID-CASH',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: royalBlue),
      scaffoldBackgroundColor: const Color(0xFFF5F9FC),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
    home: FirstLaunchGate(api: api),
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.api});
  final IdcashApi api;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_balance_wallet_rounded, size: 86, color: royalBlue),
            const SizedBox(height: 20),
            const Text('ID-CASH', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: royalBlue)),
            const Text('YOUR IDENTITY IS YOUR CASH', textAlign: TextAlign.center),
            const SizedBox(height: 64),
            FilledButton(onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => RegistrationScreen(api: api))),
              child: const Text('Create account')),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => LoginScreen(api: api))),
              child: const Text('Log in')),
          ],
        ),
      ),
    ),
  );
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, required this.api});
  final IdcashApi api;
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final phone = TextEditingController();
  final otp = TextEditingController();
  final passcode = TextEditingController();
  final confirm = TextEditingController();
  int step = 0;
  bool busy = false;
  String? error;
  @override
  void dispose() {
    phone.dispose(); otp.dispose(); passcode.dispose(); confirm.dispose();
    super.dispose();
  }

  Future<void> advance() async {
    if (busy) return;
    if (step == 0 && !RegExp(r'^(0[789]\d{9}|\+234[789]\d{9})$').hasMatch(phone.text.trim())) {
      setState(() => error = 'Enter a valid Nigerian mobile number.'); return;
    }
    if (step == 1 && !RegExp(r'^\d{4,10}$').hasMatch(otp.text.trim())) {
      setState(() => error = 'Enter the SMS verification code.'); return;
    }
    if (step == 2 &&
        (!RegExp(r'^\d{6}$').hasMatch(passcode.text) || passcode.text != confirm.text)) {
      setState(() => error = 'Enter matching six-digit login passcodes.'); return;
    }
    setState(() { busy = true; error = null; });
    try {
      if (widget.api.baseUrl.isEmpty) {
        throw const IdcashApiException('Test backend URL is not configured.');
      }
      if (step == 0) await widget.api.requestOtp(phone.text.trim());
      if (step == 1) await widget.api.verifyOtp(phone.text.trim(), otp.text.trim());
      if (step == 2) {
        final result = await widget.api.register(phone.text.trim(), passcode.text);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => RestrictedHome(customer: result)));
        return;
      }
      if (mounted) setState(() => step++);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['Phone number', 'Verify phone', 'Create login passcode'];
    return Scaffold(
      appBar: AppBar(title: const Text('Create ID-CASH account')),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          LinearProgressIndicator(value: (step + 1) / 3, color: royalBlue),
          const SizedBox(height: 28),
          Text(titles[step], style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 18),
          if (step == 0) TextField(
            controller: phone, keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Nigerian phone number', hintText: '080XXXXXXXX')),
          if (step == 1) TextField(
            controller: otp, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'SMS verification code')),
          if (step == 2) ...[
            TextField(controller: passcode, keyboardType: TextInputType.number,
              obscureText: true, maxLength: 6,
              decoration: const InputDecoration(labelText: '6-digit login passcode')),
            const SizedBox(height: 12),
            TextField(controller: confirm, keyboardType: TextInputType.number,
              obscureText: true, maxLength: 6,
              decoration: const InputDecoration(labelText: 'Confirm passcode')),
          ],
          if (error != null) ...[
            const SizedBox(height: 14),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: busy ? null : advance,
            child: Text(busy ? 'Please wait...' : step == 2 ? 'Create restricted account' : 'Continue')),
          if (step > 0) TextButton(
            onPressed: busy ? null : () => setState(() { step--; error = null; }),
            child: const Text('Back to previous step')),
        ]),
      )),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.api});
  final IdcashApi api;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final identifier = TextEditingController();
  final passcode = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void dispose() { identifier.dispose(); passcode.dispose(); super.dispose(); }
  Future<void> login() async {
    if (busy) return;
    setState(() { busy = true; error = null; });
    try {
      if (widget.api.baseUrl.isEmpty) throw const IdcashApiException('Test backend URL is not configured.');
      final result = await widget.api.login(identifier.text.trim(), passcode.text);
      if (!mounted) return;
      // Token persistence will use secure storage after session controls are integrated.
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => RestrictedHome(customer: result['customer'] is Map
          ? Map<String, dynamic>.from(result['customer'] as Map) : result)));
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Log in')),
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 36),
        const Icon(Icons.lock_outline_rounded, size: 72, color: royalBlue),
        const SizedBox(height: 24),
        TextField(controller: identifier,
          decoration: const InputDecoration(labelText: 'Phone number or IDC Number')),
        const SizedBox(height: 16),
        TextField(controller: passcode, obscureText: true, keyboardType: TextInputType.number,
          maxLength: 6, decoration: const InputDecoration(labelText: '6-digit login passcode')),
        if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 24),
        FilledButton(onPressed: busy ? null : login, child: Text(busy ? 'Signing in...' : 'Log in')),
      ]))),
  );
}

class RestrictedHome extends StatelessWidget {
  const RestrictedHome({super.key, required this.customer});
  final Map<String, dynamic> customer;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ID-CASH')),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Card(child: Padding(padding: EdgeInsets.all(20), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Wallet balance', style: TextStyle(color: royalBlue)),
            SizedBox(height: 10),
            Text('₦0.00', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
          ]))),
        const SizedBox(height: 20),
        const ListTile(
          leading: Icon(Icons.verified_user_outlined, color: royalBlue),
          title: Text('Verification required'),
          subtitle: Text('Complete NIN/BVN and facial verification to activate your wallet.'),
        ),
        const SizedBox(height: 10),
        const FilledButton(onPressed: null, child: Text('Complete identity verification — coming next')),
        const SizedBox(height: 12),
        const Text('Transfers, withdrawals and bill payments are unavailable until account activation.',
          textAlign: TextAlign.center),
      ],
    )),
  );
}
