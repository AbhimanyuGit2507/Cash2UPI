import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManualEntryScreen extends ConsumerWidget {
  const ManualEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Entry')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(onPressed: () {}, child: const Text('Customer Payment')),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: () {}, child: const Text('Expense')),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: () {}, child: const Text('Deposit')),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: () {}, child: const Text('Withdrawal')),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: () {}, child: const Text('Transfer')),
        ],
      ),
    );
  }
}
