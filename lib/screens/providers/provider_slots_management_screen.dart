import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/slots_service.dart';

class ProviderSlotsManagementScreen extends StatefulWidget {
  const ProviderSlotsManagementScreen({super.key});

  @override
  State<ProviderSlotsManagementScreen> createState() => _ProviderSlotsManagementScreenState();
}

class _ProviderSlotsManagementScreenState extends State<ProviderSlotsManagementScreen> {
  final _slotsService = SlotsService();
  DateTime _selectedDate = DateTime.now();
  String? _providerId;
  bool _isLoading = false;

  final _startTimeCtrl = TextEditingController(text: '09:00');
  final _endTimeCtrl = TextEditingController(text: '17:00');
  int _slotDuration = 30;

  @override
  void initState() {
    super.initState();
    _loadProviderId();
  }

  Future<void> _loadProviderId() async {
    final auth = context.read<AuthProvider>();
    final snapshot = await FirebaseFirestore.instance
        .collection('providers')
        .where('applicantUserId', isEqualTo: auth.userId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _providerId = snapshot.docs.first.id;
      });
    }
  }

  @override
  void dispose() {
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateSlots() async {
    if (_providerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider not found')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      await _slotsService.generateSlotsForDate(
        providerId: _providerId!,
        date: dateStr,
        start: _startTimeCtrl.text,
        end: _endTimeCtrl.text,
        slotDurationMinutes: _slotDuration,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Slots generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Slots'),
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generate Time Slots',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date Selection
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: AppTheme.primary),
                      title: const Text('Select Date'),
                      subtitle: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _selectDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start Time
                    TextField(
                      controller: _startTimeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        hintText: '09:00',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // End Time
                    TextField(
                      controller: _endTimeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        hintText: '17:00',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Slot Duration
                    const Text(
                      'Slot Duration',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [15, 30, 45, 60].map((duration) {
                        final isSelected = _slotDuration == duration;
                        return ChoiceChip(
                          label: Text('$duration min'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _slotDuration = duration);
                          },
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Generate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _generateSlots,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.add_circle_outline),
                        label: Text(_isLoading ? 'Generating...' : 'Generate Slots'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'How it works',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoItem('1. Select the date for which you want to create slots'),
                    _InfoItem('2. Set your working hours (start and end time)'),
                    _InfoItem('3. Choose slot duration (15, 30, 45, or 60 minutes)'),
                    _InfoItem('4. Click "Generate Slots" to create time slots'),
                    _InfoItem('5. Users can then book these slots for appointments'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String text;

  const _InfoItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
            ),
          ),
        ],
      ),
    );
  }
}
