import 'package:flutter/material.dart';

const _blue = Color(0xFF073B67);
const _cyan = Color(0xFF76BED2);

/// Review-only features never call payment APIs or change a real wallet.
class CustomerReviewDashboard extends StatefulWidget {
  const CustomerReviewDashboard({
    super.key,
    required this.restricted,
    this.idcNumber,
    this.phoneNumber,
    this.onExit,
  });
  final bool restricted;
  final String? idcNumber;
  final String? phoneNumber;
  final VoidCallback? onExit;

  @override
  State<CustomerReviewDashboard> createState() => _CustomerReviewDashboardState();
}

class _CustomerReviewDashboardState extends State<CustomerReviewDashboard> {
  int tab = 0;
  bool hideBalance = false;
  final entries = <String>[];

  void preview(String title) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24, 10, 24, MediaQuery.viewInsetsOf(context).bottom + 26),
          child: _ActionPreview(
            title: title,
            restricted: widget.restricted,
            onSimulate: (amount, recipient) {
              setState(() {
                entries.insert(0, '$title • ₦$amount • $recipient • simulated');
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(
                content: Text('Demo recorded locally — no real money was moved.')));
            },
          ),
        ),
      ),
    );
  }

  Widget action(String name, IconData icon, {bool small = false}) => InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () => preview(name),
    child: Padding(
      padding: const EdgeInsets.all(7),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(
          radius: small ? 22 : 25,
          backgroundColor: const Color(0xFFE8F5FA),
          child: Icon(icon, color: _blue),
        ),
        const SizedBox(height: 7),
        Text(name, textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ]),
    ),
  );

  Widget demoTag() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      color: const Color(0xFFFFE5AE)),
    child: const Text('REVIEW DEMO', style: TextStyle(
      color: Color(0xFF754B00), fontSize: 10, fontWeight: FontWeight.bold)),
  );

  Widget home() => ListView(padding: const EdgeInsets.all(18), children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('Hello, welcome back', style: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w700, color: _blue)),
      demoTag(),
    ]),
    const SizedBox(height: 16),
    Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [_blue, Color(0xFF3B82A0)])),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Available balance', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Row(children: [
          Text(hideBalance ? '₦••••••' : '₦0.00',
            style: const TextStyle(
              color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
          IconButton(
            onPressed: () => setState(() => hideBalance = !hideBalance),
            icon: Icon(hideBalance ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70)),
        ]),
        const SizedBox(height: 12),
        Text(widget.restricted ? 'Restricted — KYC required' : 'Review preview — not a live balance',
          style: const TextStyle(color: Colors.white)),
      ]),
    ),
    const SizedBox(height: 16),
    if (widget.restricted)
      Card(
        color: const Color(0xFFFFF4D9),
        child: ListTile(
          leading: const Icon(Icons.verified_user_outlined, color: _blue),
          title: const Text('Complete identity verification'),
          subtitle: const Text('NIN/BVN lookup and facial liveness are not connected yet.'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => preview('Identity verification'),
        )),
    const SizedBox(height: 22),
    const Text('Quick actions', style: TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: _blue)),
    const SizedBox(height: 10),
    GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: .8,
      children: [
        action('Send', Icons.arrow_upward),
        action('Add Money', Icons.add_circle_outline),
        action('Receive', Icons.south_west),
        action('Scan QR', Icons.qr_code_scanner),
        action('Airtime', Icons.phone_android),
        action('Data', Icons.wifi),
        action('Bills', Icons.receipt_long),
        action('My QR', Icons.qr_code),
      ],
    ),
    const SizedBox(height: 18),
    Card(child: ListTile(
      leading: const Icon(Icons.account_balance, color: _blue),
      title: const Text('Your ID-CASH account'),
      subtitle: Text(widget.idcNumber ?? 'IDC Number will appear after registration'),
      trailing: const Icon(Icons.copy),
      onTap: () => preview('Account details'),
    )),
    const SizedBox(height: 18),
    const Text('Recent activity', style: TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: _blue)),
    if (entries.isEmpty) const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text('No demo activity yet. Try a quick action to preview a flow.')),
    ...entries.take(3).map((item) => ListTile(
      leading: const Icon(Icons.history, color: _cyan), title: Text(item))),
  ]);

  Widget activity() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Activity', style: TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: _blue)),
    const SizedBox(height: 8),
    const Text('Local demo history, not bank or ledger transactions.'),
    const SizedBox(height: 16),
    if (entries.isEmpty) const Card(child: Padding(
      padding: EdgeInsets.all(24), child: Text('No transactions to display.'))),
    ...entries.map((x) => ListTile(
      leading: const Icon(Icons.receipt_long, color: _blue), title: Text(x))),
  ]);

  Widget services() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Services', style: TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: _blue)),
    const SizedBox(height: 10),
    const Text('Preview available services. Real payments are disabled.'),
    const SizedBox(height: 14),
    ...[
      ('Bank transfer', Icons.account_balance),
      ('ID-CASH transfer', Icons.swap_horiz),
      ('Airtime', Icons.phone_android),
      ('Data', Icons.wifi),
      ('Electricity', Icons.bolt),
      ('Cable TV', Icons.tv),
      ('QR payments', Icons.qr_code_scanner),
      ('Transaction PIN', Icons.pin),
    ].map((item) => Card(child: ListTile(
      leading: Icon(item.$2, color: _blue),
      title: Text(item.$1),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => preview(item.$1),
    ))),
  ]);

  Widget profile() => ListView(padding: const EdgeInsets.all(20), children: [
    const CircleAvatar(radius: 38, backgroundColor: Color(0xFFE0F3F8),
      child: Icon(Icons.person, size: 46, color: _blue)),
    const SizedBox(height: 16),
    const Center(child: Text('My profile', style: TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: _blue))),
    const SizedBox(height: 18),
    ListTile(title: const Text('IDC Number'),
      subtitle: Text(widget.idcNumber ?? 'Not available in demo')),
    ListTile(title: const Text('Phone number'),
      subtitle: Text(widget.phoneNumber ?? 'Not available in demo')),
    ListTile(title: const Text('Account verification'),
      subtitle: Text(widget.restricted ? 'Unverified / restricted' : 'Demo preview')),
    ListTile(title: const Text('Theme and security settings'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => preview('Settings')),
    ListTile(title: const Text('Support'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => preview('Support')),
    if (widget.onExit != null)
      OutlinedButton.icon(onPressed: widget.onExit,
        icon: const Icon(Icons.logout), label: const Text('Return to welcome')),
  ]);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('ID-CASH'),
      backgroundColor: Colors.white,
      foregroundColor: _blue,
      actions: [
        IconButton(onPressed: () => preview('Notifications'),
          icon: const Icon(Icons.notifications_none)),
      ],
    ),
    body: IndexedStack(index: tab, children: [
      home(), activity(), services(), profile(),
    ]),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (value) => setState(() => tab = value),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.history), label: 'Activity'),
        NavigationDestination(icon: Icon(Icons.grid_view), label: 'Services'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Me'),
      ],
    ),
  );
}

class _ActionPreview extends StatefulWidget {
  const _ActionPreview({
    required this.title, required this.restricted, required this.onSimulate,
  });
  final String title;
  final bool restricted;
  final void Function(String, String) onSimulate;

  @override
  State<_ActionPreview> createState() => _ActionPreviewState();
}

class _ActionPreviewState extends State<_ActionPreview> {
  final recipient = TextEditingController();
  final amount = TextEditingController();

  @override
  void dispose() {
    recipient.dispose();
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(widget.title, style: const TextStyle(
        fontSize: 23, color: _blue, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      const Text('SIMULATION ONLY — no real account is charged or credited.',
        style: TextStyle(color: Color(0xFF9B5700), fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      if (widget.restricted) const Text(
        'Your actual ID-CASH wallet remains frozen until KYC approval.'),
      const SizedBox(height: 14),
      TextField(controller: recipient,
        decoration: const InputDecoration(
          border: OutlineInputBorder(), labelText: 'Recipient / reference (demo)')),
      const SizedBox(height: 12),
      TextField(controller: amount, keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(), prefixText: '₦ ',
          labelText: 'Amount (demo)')),
      const SizedBox(height: 18),
      FilledButton(
        onPressed: () {
          final value = double.tryParse(amount.text);
          if (value == null || value <= 0 || recipient.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enter a recipient and a positive amount.')));
            return;
          }
          widget.onSimulate(amount.text.trim(), recipient.text.trim());
        },
        child: const Text('Simulate only'),
      ),
    ],
  );
}
