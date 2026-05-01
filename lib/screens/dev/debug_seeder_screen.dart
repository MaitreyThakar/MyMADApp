import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/provider_service.dart';
import '../../services/slots_service.dart';
import '../../models/provider_model.dart';

class DebugSeederScreen extends StatefulWidget {
  const DebugSeederScreen({super.key});

  @override
  State<DebugSeederScreen> createState() => _DebugSeederScreenState();
}

class _DebugSeederScreenState extends State<DebugSeederScreen> {
  final _providerService = ProviderService();
  final _slotsService = SlotsService();
  bool _working = false;
  String _log = '';

  Future<void> _createAndSeed() async {
    setState(() {
      _working = true;
      _log = '';
    });

    try {
      final provider = ProviderModel(
        providerId: '',
        name: 'Test Provider',
        description: 'Auto-seeded provider for testing',
        location: 'Test Clinic',
        hours: {
          'mon': {'start': '09:00', 'end': '17:00'},
        },
        slotDurationMinutes: 30,
      );

      final id = await _providerService.createProvider(provider);
      _append('Created provider id: $id');

      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await _slotsService.generateSlotsForDate(
        providerId: id,
        date: dateStr,
        start: '09:00',
        end: '17:00',
        slotDurationMinutes: provider.slotDurationMinutes,
      );
      _append('Generated slots for $dateStr');
    } catch (e) {
      _append('Error: $e');
    } finally {
      setState(() => _working = false);
    }
  }

  void _append(String s) {
    setState(() => _log = '$_log\n$s');
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const Scaffold(body: Center(child: Text('Not available')));
    return Scaffold(
      appBar: AppBar(title: const Text('Dev Seeder')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _working ? null : _createAndSeed,
              child: Text(_working ? 'Working...' : 'Create test provider + generate today slots'),
            ),
            const SizedBox(height: 12),
            const Text('Log:'),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_log.isEmpty ? 'No actions yet' : _log),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
