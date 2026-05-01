import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/custom_button.dart';

class EditAppointmentScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const EditAppointmentScreen({super.key, required this.appointment});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final _notesCtrl = TextEditingController();
  late String _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.appointment.status;
    _notesCtrl.text = widget.appointment.notes;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    setState(() => _isLoading = true);
    await context.read<AppointmentProvider>().updateAppointment(
      widget.appointment.appointmentId,
      {'status': _selectedStatus, 'notes': _notesCtrl.text.trim()},
    );
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Appointment updated successfully!'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _cancel() async {
    setState(() => _isLoading = true);
    await context.read<AppointmentProvider>().cancelAppointment(widget.appointment.appointmentId, slotId: widget.appointment.slotId);
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Appointment cancelled'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
      Navigator.pop(context);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return const Color(0xFF28A745);
      case 'cancelled':
        return const Color(0xFFDC3545);
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Edit Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Provider',
                      value: widget.appointment.providerName,
                    ),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: widget.appointment.date,
                    ),
                    _InfoRow(
                      icon: Icons.access_time_outlined,
                      label: 'Time',
                      value: widget.appointment.timeSlot,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Update Status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon:
                    const Icon(Icons.flag_outlined, color: AppTheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFDDE3F0)),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(
                    value: 'confirmed', child: Text('Confirmed')),
                DropdownMenuItem(
                    value: 'cancelled', child: Text('Cancelled')),
              ],
              selectedItemBuilder: (ctx) => ['pending', 'confirmed', 'cancelled']
                  .map((s) => Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _statusColor(s),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            s[0].toUpperCase() + s.substring(1),
                            style: TextStyle(
                              color: _statusColor(s),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedStatus = v!),
            ),
            const SizedBox(height: 20),
            const Text(
              'Notes',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Update notes...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFDDE3F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              label: 'Update Appointment',
              onPressed: _update,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Cancel Appointment',
              onPressed: _isLoading ? null : _cancel,
              backgroundColor: const Color(0xFFDC3545),
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
