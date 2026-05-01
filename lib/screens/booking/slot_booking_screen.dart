import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import 'package:provider/provider.dart';
import '../../providers/slots_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../services/provider_service.dart';
import '../../models/provider_model.dart';
import '../../widgets/slot_card.dart';
import '../../widgets/custom_button.dart';

class SlotBookingScreen extends StatefulWidget {
  const SlotBookingScreen({super.key});

  @override
  State<SlotBookingScreen> createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends State<SlotBookingScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedSlot;
  bool _listening = false;
  String? _selectedSlotId;
  String? _selectedProviderId;
  String? _selectedProviderName;
  final _providerService = ProviderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Book a Slot')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar
            const Text(
              'Select Provider',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<ProviderModel>>(
              stream: _providerService.getApprovedProviders(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(minHeight: 2),
                  );
                }

                final providers = snap.data ?? [];
                if (providers.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No approved providers available yet.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _selectedProviderId,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.business_center_outlined,
                        color: AppTheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDE3F0)),
                    ),
                    hintText: 'Choose approved provider',
                  ),
                  items: providers
                      .map((p) => DropdownMenuItem<String>(
                            value: p.providerId,
                            child: Text(p.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    String? selectedName;
                    for (final p in providers) {
                      if (p.providerId == value) {
                        selectedName = p.name;
                        break;
                      }
                    }
                    setState(() {
                      _selectedProviderId = value;
                      _selectedProviderName = selectedName;
                      _selectedSlot = null;
                      _selectedSlotId = null;
                      _listening = false;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 60)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(_selectedDay, day),
                onDaySelected: (selected, focused) {
                  if (_selectedProviderId == null || _selectedProviderId!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Select a provider first')),
                    );
                    return;
                  }

                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                    _selectedSlot = null;
                  });
                  final dateStr = '${selected.year}-${selected.month.toString().padLeft(2,'0')}-${selected.day.toString().padLeft(2,'0')}';
                  final slotsProv = context.read<SlotsProvider>();
                  slotsProv.listenToDate(dateStr, providerId: _selectedProviderId);
                  _listening = true;
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle:
                      const TextStyle(color: Colors.white),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Legend
            Row(
              children: [
                _LegendDot(color: AppTheme.primary, label: 'Available'),
                const SizedBox(width: 16),
                _LegendDot(
                    color: const Color(0xFFADB5BD), label: 'Booked'),
                const SizedBox(width: 16),
                _LegendDot(
                    color: AppTheme.accent, label: 'Selected'),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Available Time Slots',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),

            Consumer<SlotsProvider>(builder: (context, prov, _) {
              if (!_listening) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Select a date to load available slots',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                );
              }
              if (prov.isLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (prov.slots.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No available slots. Please check later.',
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

            const SizedBox(height: 28),

            if (_selectedSlot != null) ...[
              Builder(builder: (ctx) {
                final args = ModalRoute.of(context)?.settings.arguments;
                final isReschedule = args is Map && args['rescheduleAppointmentId'] != null;
                return CustomButton(
                  label: isReschedule ? 'Reschedule – $_selectedSlot' : 'Confirm Slot – $_selectedSlot',
                  onPressed: () async {
                    final dateStr = '${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}';
                    if (isReschedule) {
                      final apptId = args['rescheduleAppointmentId'] as String;
                      final oldSlotId = args['oldSlotId'] as String?;
                      final prov = context.read<AppointmentProvider>();
                      final navigator = Navigator.of(context);
                      final targetRoute = AppRoutes.appointments;
                      await prov.rescheduleAppointment(
                        appointmentId: apptId,
                        newDate: dateStr,
                        newTime: _selectedSlot!,
                        newSlotId: _selectedSlotId,
                        oldSlotId: oldSlotId,
                      );
                      if (!mounted) return;
                      navigator.popUntil((route) => route.settings.name == targetRoute || route.isFirst);
                    } else {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.addAppt,
                        arguments: {
                          'date': dateStr,
                          'timeSlot': _selectedSlot,
                          'slotId': _selectedSlotId,
                          'providerId': _selectedProviderId,
                          'providerName': _selectedProviderName,
                        },
                      );
                    }
                  },
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      ],
    );
  }
}
