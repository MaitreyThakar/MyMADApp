import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/appointment_card.dart';
import '../booking/edit_appointment_screen.dart';

class AppointmentsListScreen extends StatelessWidget {
  final bool showScaffold;

  const AppointmentsListScreen({super.key, this.showScaffold = true});

  void _confirmDelete(BuildContext context, AppointmentModel appt) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 26),
            SizedBox(width: 10),
            Text('Delete Appointment'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the appointment with ${appt.providerName} on ${appt.date}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<AppointmentProvider>()
                  .deleteAppointment(appt.appointmentId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Appointment removed.'),
                    backgroundColor: const Color(0xFF2E7D32),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No appointments yet.',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to book your first appointment',
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: provider.appointments.length,
      itemBuilder: (ctx, i) {
        final appt = provider.appointments[i];
        return AppointmentCard(
          appointment: appt,
          onEdit: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditAppointmentScreen(appointment: appt),
            ),
          ),
          onDelete: () => _confirmDelete(context, appt),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (!showScaffold) return content;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      body: content,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addAppt),
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
