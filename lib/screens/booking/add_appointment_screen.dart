import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/slots_provider.dart';
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
  bool _providerLocked = false;

  String? _selectedService;
  String? _selectedSlot;
  DateTime? _selectedDate;
  String? _selectedSlotId;

  @override
  void initState() {
    super.initState();
    // Pre-fill if navigated from SlotBookingScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final date = args['date'] as String?;
        final slot = args['timeSlot'] as String?;
        final slotId = args['slotId'] as String?;
        final providerName = args['providerName'] as String?;
        final providerId = args['providerId'] as String?;
        if (date != null) {
          _dateCtrl.text = date;
          _selectedDate = DateTime.parse(date);
          // Load slots for pre-filled date
          context.read<SlotsProvider>().listenToDate(date, providerId: providerId);
        }
        if (slot != null) setState(() => _selectedSlot = slot);
        if (slotId != null) setState(() => _selectedSlotId = slotId);
        if (providerName != null && providerName.trim().isNotEmpty) {
          setState(() {
            _providerCtrl.text = providerName;
            _providerLocked = true;
          });
        }
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
      
      // Load slots for the selected date
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      final providerId = args?['providerId'] as String?;
      context.read<SlotsProvider>().listenToDate(
        DateFormat('yyyy-MM-dd').format(picked),
        providerId: providerId,
      );
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
    
    // Get providerId from arguments if available
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final providerId = args?['providerId'] as String?;
    
    final appt = AppointmentModel(
      appointmentId: '',
      userId: uid,
      providerName: _providerCtrl.text.trim(),
      providerId: providerId,
      date: _dateCtrl.text.trim(),
      timeSlot: _selectedSlot!,
      slotId: _selectedSlotId,
      notes: _notesCtrl.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    await context.read<AppointmentProvider>().addAppointment(appt);

    // Notifications
    await NotificationService.showBookingConfirmation(
      _providerCtrl.text.trim(),
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
          _providerCtrl.text.trim(),
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
              const _SectionLabel('Provider Name'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _providerCtrl,
                label: 'Provider Name',
                hint: 'Dr. Anita Shah',
                prefixIcon: Icons.person_outline,
                readOnly: _providerLocked,
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
              Consumer<SlotsProvider>(builder: (context, prov, _) {
                if (_selectedDate == null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Select a date to view available time slots.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  );
                }

                if (prov.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (prov.slots.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No available slots for selected date.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  );
                }

                return Wrap(
                  children: prov.slots.map((s) {
                      final isBooked = s.status == 'booked';
                      final isSelected = _selectedSlot == s.time;
                      return SlotCard(
                        time: s.time,
                        isBooked: isBooked,
                        isSelected: isSelected,
                        onTap: () => setState(() {
                          _selectedSlot = s.time;
                          _selectedSlotId = s.slotId;
                        }),
                      );
                    }).toList(),
                );
              }),
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
