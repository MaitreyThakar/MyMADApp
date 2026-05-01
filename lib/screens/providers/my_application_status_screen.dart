import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/provider_application_model.dart';
import '../../services/application_service.dart';
import '../../providers/auth_provider.dart';

class MyApplicationStatusScreen extends StatelessWidget {
  const MyApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final appService = ApplicationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Application Status'),
        backgroundColor: AppTheme.primary,
      ),
      body: StreamBuilder<List<ProviderApplicationModel>>(
        stream: appService.getUserApplications(auth.userId),
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

          final applications = snap.data ?? [];

          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'No Applications Yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Apply to become a provider to see your status here',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (ctx, i) {
              final app = applications[i];
              return _ApplicationStatusCard(application: app);
            },
          );
        },
      ),
    );
  }
}

class _ApplicationStatusCard extends StatelessWidget {
  final ProviderApplicationModel application;

  const _ApplicationStatusCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final isPending = application.status == 'pending';
    final isApproved = application.status == 'approved';
    final isRejected = application.status == 'rejected';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isApproved) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'APPROVED';
    } else if (isRejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'REJECTED';
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = 'PENDING';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Status Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Applied on ${_formatDate(application.appliedAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Application Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  icon: Icons.category,
                  label: 'Service Type',
                  value: application.serviceType,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.badge,
                  label: 'License',
                  value: application.licenseNumber,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.work,
                  label: 'Experience',
                  value: application.experienceYears,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: application.applicantPhone,
                ),

                // Admin Notes (if any)
                if (application.adminNotes != null && application.adminNotes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isApproved ? Icons.note_alt : Icons.warning_amber,
                        size: 20,
                        color: statusColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isApproved ? 'Admin Notes:' : 'Rejection Reason:',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      application.adminNotes!,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                    ),
                  ),
                ],

                // Reviewed Date
                if (application.reviewedAt != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Reviewed on ${_formatDate(application.reviewedAt!)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],

                // Status Message
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your application is under review. You will be notified once admin reviews it.',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isApproved) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.celebration, size: 20, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🎉 Congratulations! You are now a provider. You can manage your services and slots.',
                            style: TextStyle(fontSize: 12, color: Colors.green.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isRejected) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your application was not approved. Please review the reason above and reapply if needed.',
                            style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoDate;
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
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
