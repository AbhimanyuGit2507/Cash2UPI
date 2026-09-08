import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingScreen extends ConsumerWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Classification')),
      body: const Center(child: Text('No pending SMS')),
    );
  }
}
