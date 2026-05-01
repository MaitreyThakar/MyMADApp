import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
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
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                    _selectedSlot = null;
                  });
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

            // Slot chips
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

            const SizedBox(height: 28),

            if (_selectedSlot != null) ...[
              CustomButton(
                label: 'Confirm Slot – $_selectedSlot',
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.addAppt,
                  arguments: {
                    'date':
                        '${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}',
                    'timeSlot': _selectedSlot,
                  },
                ),
              ),
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
