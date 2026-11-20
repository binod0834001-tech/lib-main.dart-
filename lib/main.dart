import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MeraHisabApp());
}

class MeraHisabApp extends StatelessWidget {
  const MeraHisabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const HisabHomeScreen(),
    );
  }
}

class HisabHomeScreen extends StatefulWidget {
  const HisabHomeScreen({super.key});

  @override
  State<HisabHomeScreen> createState() => _HisabHomeScreenState();
}

class _HisabHomeScreenState extends State<HisabHomeScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  final List<Map<String, dynamic>> transactions = [
    {"title": "Dukaan Bikri", "amount": 2500, "isIncome": true},
    {"title": "Petrol & Travel", "amount": 300, "isIncome": false},
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6692289875226065/7822710650',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isAdLoaded = true),
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  int get totalIncome => transactions
      .where((t) => t["isIncome"])
      .fold(0, (sum, t) => sum + (t["amount"] as int));

  int get totalExpense => transactions
      .where((t) => !t["isIncome"])
      .fold(0, (sum, t) => sum + (t["amount"] as int));

  void _addEntryDialog(bool isIncome) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isIncome ? "Paisa Aaya (+ Income)" : "Kharcha Hua (- Expense)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Kiske liye?")),
            const SizedBox(height: 10),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Kitne Rupaye (₹)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isIncome ? Colors.green : Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              final amt = int.tryParse(amountCtrl.text) ?? 0;
              if (titleCtrl.text.isNotEmpty && amt > 0) {
                setState(() {
                  transactions.insert(0, {"title": titleCtrl.text, "amount": amt, "isIncome": isIncome});
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Save Karein"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int balance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mera Hisab - Khata App", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.teal, Colors.tealAccent]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text("Net Balance (Bachat)", style: TextStyle(color: Colors.white, fontSize: 16)),
                Text("₹$balance", style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [
                      const Text("Total Aaya", style: TextStyle(color: Colors.white70)),
                      Text("+ ₹$totalIncome", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ]),
                    Column(children: [
                      const Text("Total Kharcha", style: TextStyle(color: Colors.white70)),
                      Text("- ₹$totalExpense", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ]),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(12)),
                    onPressed: () => _addEntryDialog(true),
                    icon: const Icon(Icons.add_circle),
                    label: const Text("Paisa Aaya"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.all(12)),
                    onPressed: () => _addEntryDialog(false),
                    icon: const Icon(Icons.remove_circle),
                    label: const Text("Kharcha Hua"),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Align(alignment: Alignment.centerLeft, child: Text("Recent Hisab", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final item = transactions[index];
                final bool inc = item["isIncome"];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: inc ? Colors.green.shade100 : Colors.red.shade100,
                      child: Icon(inc ? Icons.arrow_downward : Icons.arrow_upward, color: inc ? Colors.green : Colors.red),
                    ),
                    title: Text(item["title"], style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${inc ? '+' : '-'} ₹${item["amount"]}", style: TextStyle(color: inc ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey), onPressed: () => setState(() => transactions.removeAt(index))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isAdLoaded
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox.shrink(),
    );
  }
}
