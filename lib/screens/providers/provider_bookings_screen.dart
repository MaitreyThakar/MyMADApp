import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment_model.dart';

class ProviderBookingsScreen extends StatelessWidget {
  const ProviderBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppTheme.primary,
      ),
      body: FutureBuilder<String?>(
        future: _getProviderId(auth.userId),
        builder: (context, providerSnapshot) {
          if (providerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final providerId = providerSnapshot.data;

          if (providerId == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business_center_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'Provider Profile Not Found',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your provider profile will appear here once approved by admin.',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .where('providerId', isEqualTo: providerId)
                .snapshots(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snap.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text('Error: ${snap.error}'),
                    ],
                  ),
                );
              }

              final appointments = snap.data?.docs ?? [];
              
              // Sort by date on client side
              appointments.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aDate = aData['date'] ?? '';
                final bDate = bData['date'] ?? '';
                return aDate.compareTo(bDate);
              });

              if (appointments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        'No Bookings Yet',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bookings from customers will appear here',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              // Group by status
              final pending = appointments.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['status'] == 'pending';
              }).toList();

              final confirmed = appointments.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['status'] == 'confirmed';
              }).toList();

              final cancelled = appointments.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['status'] == 'cancelled';
              }).toList();

              return DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: 'Pending (${pending.length})'),
                        Tab(text: 'Confirmed (${confirmed.length})'),
                        Tab(text: 'Cancelled (${cancelled.length})'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildBookingsList(pending, 'pending'),
                          _buildBookingsList(confirmed, 'confirmed'),
                          _buildBookingsList(cancelled, 'cancelled'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String?> _getProviderId(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('providers')
        .where('applicantUserId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    }
    return null;
  }

  Widget _buildBookingsList(List<QueryDocumentSnapshot> bookings, String status) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          'No ${status} bookings',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (ctx, i) {
        final doc = bookings[i];
        final data = doc.data() as Map<String, dynamic>;
        final appointment = AppointmentModel.fromMap(data, doc.id);

        return _BookingCard(
          appointment: appointment,
          onConfirm: status == 'pending'
              ? () => _updateStatus(doc.id, 'confirmed')
              : null,
          onCancel: status != 'cancelled'
              ? () => _updateStatus(doc.id, 'cancelled')
              : null,
        );
      },
    );
  }

  Future<void> _updateStatus(String appointmentId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': newStatus});
  }
}

class _BookingCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _BookingCard({
    required this.appointment,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (appointment.status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'User ID: ${appointment.userId.substring(0, 8)}...',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        appointment.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: _formatDate(appointment.date),
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.access_time,
              label: 'Time',
              value: appointment.timeSlot,
            ),
            if (appointment.notes.isNotEmpty) ...[ 
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.note,
                label: 'Notes',
                value: appointment.notes,
              ),
            ],
            if (onConfirm != null || onCancel != null) ...[ 
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onConfirm != null) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onConfirm,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Confirm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onCancel != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return date;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
