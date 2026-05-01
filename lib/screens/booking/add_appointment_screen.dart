import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/slot_card.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _providerCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  String? _selectedService;
  String? _selectedSlot;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Pre-fill if navigated from SlotBookingScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final date = args['date'] as String?;
        final slot = args['timeSlot'] as String?;
        if (date != null) {
          _dateCtrl.text = date;
          _selectedDate = DateTime.parse(date);
        }
        if (slot != null) setState(() => _selectedSlot = slot);
      }
    });
  }

  @override
  void dispose() {
    _providerCtrl.dispose();
    _notesCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
        _selectedSlot = null;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a time slot'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final appt = AppointmentModel(
      appointmentId: '',
      userId: uid,
      serviceName: _selectedService!,
      providerName: _providerCtrl.text.trim(),
      date: _dateCtrl.text.trim(),
      timeSlot: _selectedSlot!,
      notes: _notesCtrl.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    await context.read<AppointmentProvider>().addAppointment(appt);

    // Notifications
    await NotificationService.showBookingConfirmation(
      _selectedService!,
      _dateCtrl.text,
      _selectedSlot!,
    );

    if (_selectedDate != null) {
      try {
        final timeParts = _selectedSlot!.split(':');
        final hour = int.parse(timeParts[0]);
        final minuteStr = timeParts[1].split(' ')[0];
        final minute = int.parse(minuteStr);
        final isPm = _selectedSlot!.contains('PM');
        final adjustedHour =
            isPm && hour != 12 ? hour + 12 : (!isPm && hour == 12 ? 0 : hour);

        final apptDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          adjustedHour,
          minute,
        );

        await NotificationService.scheduleAppointmentReminder(
          DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000,
          _selectedService!,
          apptDateTime,
        );
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Appointment booked successfully!'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('New Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel('Service Type'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedService,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.medical_services_outlined,
                      color: AppTheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFDDE3F0)),
                  ),
                  hintText: 'Select service type',
                ),
                items: AppConstants.serviceTypes
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedService = v),
                validator: (v) =>
                    v == null ? 'Please select a service type' : null,
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Provider Name'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _providerCtrl,
                label: 'Provider Name',
                hint: 'Dr. Anita Shah',
                prefixIcon: Icons.person_outline,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Provider name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Date'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _dateCtrl,
                label: 'Date',
                hint: 'Select a date',
                prefixIcon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _pickDate,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Time Slot'),
              const SizedBox(height: 8),
              Wrap(
                children: AppConstants.sampleSlots.map((slot) {
                  final isBooked = slot['status'] == 'booked';
                  final isSelected = _selectedSlot == slot['time'];
                  return SlotCard(
                    time: slot['time']!,
                    isBooked: isBooked,
                    isSelected: isSelected,
                    onTap: () =>
                        setState(() => _selectedSlot = slot['time']),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Notes (Optional)'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _notesCtrl,
                label: 'Notes',
                hint: 'Any special requests or notes...',
                prefixIcon: Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              CustomButton(
                label: 'Book Appointment',
                onPressed: _submit,
                isLoading: provider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Color(0xFF374151),
      ),
    );
  }
}
