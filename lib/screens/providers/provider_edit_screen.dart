import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/provider_service.dart';
import '../../services/slots_service.dart';
import '../../models/provider_model.dart';

class ProviderEditScreen extends StatefulWidget {
  const ProviderEditScreen({super.key});

  @override
  State<ProviderEditScreen> createState() => _ProviderEditScreenState();
}

class _ProviderEditScreenState extends State<ProviderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _hours = TextEditingController();
  final _slotDuration = TextEditingController(text: '30');
  final _svc = ProviderService();
  final _slotsSvc = SlotsService();
  String? _editingId;
  DateTime? _genDate;
  final _startCtrl = TextEditingController(text: '09:00');
  final _endCtrl = TextEditingController(text: '17:00');

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _hours.dispose();
    _slotDuration.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _editingId = args;
      _loadProvider(args);
    }
  }

  Future<void> _loadProvider(String id) async {
    final p = await _svc.getProvider(id);
    if (p != null && mounted) {
      setState(() {
        _name.text = p.name;
        _location.text = p.location;
        _slotDuration.text = p.slotDurationMinutes.toString();
        _hours.text = p.hours.toString();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final hoursMap = <String, dynamic>{};
    try {
      // Expecting simple JSON-like input but keep forgiving
      // If user leaves blank, use empty map
      if (_hours.text.trim().isNotEmpty) {
        // Attempt to parse as Map using Dart code is unsafe; keep as raw string in map
        hoursMap['raw'] = _hours.text.trim();
      }
    } catch (_) {}

    final provider = ProviderModel(
      providerId: _editingId ?? '',
      name: _name.text.trim(),
      location: _location.text.trim(),
      hours: hoursMap,
      slotDurationMinutes: int.tryParse(_slotDuration.text) ?? 30,
    );

    if (_editingId == null) {
      final id = await _svc.createProvider(provider);
      _editingId = id;
    } else {
      await _svc.updateProvider(_editingId!, provider.toMap());
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _generateSlots() async {
    if (_editingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save provider first')));
      return;
    }
    final date = _genDate ?? DateTime.now();
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final start = _startCtrl.text.trim();
    final end = _endCtrl.text.trim();
    final duration = int.tryParse(_slotDuration.text) ?? 30;
    try {
      await _slotsSvc.generateSlotsForDate(
        providerId: _editingId!,
        date: dateStr,
        start: start,
        end: end,
        slotDurationMinutes: duration,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Slots generated')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const Scaffold(body: Center(child: Text('Not available')));
    return Scaffold(
      appBar: AppBar(title: Text(_editingId == null ? 'New Provider' : 'Edit Provider')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                      TextFormField(controller: _location, decoration: const InputDecoration(labelText: 'Location')),
                      TextFormField(controller: _slotDuration, decoration: const InputDecoration(labelText: 'Slot duration (minutes)'), keyboardType: TextInputType.number),
                      TextFormField(controller: _hours, decoration: const InputDecoration(labelText: 'Hours (free text)'), maxLines: 3),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Save'))),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _editingId == null ? null : () async {
                                await _generateSlots();
                              },
                              child: const Text('Generate Today Slots'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ExpansionTile(
                        title: const Text('Generate slots for specific date'),
                        children: [
                          ListTile(
                            title: Text(_genDate == null ? 'Select date' : _genDate!.toIso8601String().split('T').first),
                            trailing: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null && mounted) setState(() => _genDate = picked);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                TextFormField(controller: _startCtrl, decoration: const InputDecoration(labelText: 'Start (HH:mm)')),
                                TextFormField(controller: _endCtrl, decoration: const InputDecoration(labelText: 'End (HH:mm)')),
                                const SizedBox(height: 8),
                                ElevatedButton(onPressed: _generateSlots, child: const Text('Generate')),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
