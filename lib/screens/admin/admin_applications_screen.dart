import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../models/provider_application_model.dart';
import '../../models/provider_model.dart';
import '../../services/application_service.dart';
import '../../services/provider_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/custom_button.dart';

class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() => _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  final _appService = ApplicationService();
  final _provService = ProviderService();

  Future<void> _approveApplication(ProviderApplicationModel app) async {
    if (!mounted) return;

    final adminNotes = await _showAdminNotesDialog('Approve Application', 'Approval notes (optional):');
    if (adminNotes == null) return; // User cancelled

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Create provider entry
      final providerRef = await FirebaseFirestore.instance.collection('providers').add({
        'name': app.applicantName,
        'description': app.bio,
        'location': 'Not set',
        'hours': {},
        'slotDurationMinutes': 30,
        'isApproved': true,
        'approvalStatus': 'approved',
        'applicantUserId': app.applicantUserId,
        'licenseNumber': app.licenseNumber,
        'certifications': app.certifications,
        'experienceYears': app.experienceYears,
        'approvedAt': DateTime.now().toIso8601String(),
      });

      // Update application with approval
      await _appService.approveApplication(app.applicationId, providerRef.id, adminNotes);

      // Update user role to provider
      await FirebaseFirestore.instance.collection('users').doc(app.applicantUserId).update({
        'role': 'provider',
      });

      // Send notification to user
      try {
        await NotificationService.showProviderApplicationApproved(app.applicantName);
      } catch (e) {
        // Notification failed but approval succeeded
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Approved application from ${app.applicantName}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    }
  }

  Future<void> _rejectApplication(ProviderApplicationModel app) async {
    if (!mounted) return;

    final reason = await _showAdminNotesDialog('Reject Application', 'Rejection reason:');
    if (reason == null || reason.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _appService.rejectApplication(app.applicationId, reason);

      // Send notification to user
      try {
        await NotificationService.showProviderApplicationRejected(app.applicantName, reason);
      } catch (e) {
        // Notification failed but rejection succeeded
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Rejected application from ${app.applicantName}'),
          backgroundColor: AppTheme.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    }
  }

  Future<String?> _showAdminNotesDialog(String title, String label) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Applications'),
        backgroundColor: AppTheme.primary,
      ),
      body: StreamBuilder<List<ProviderApplicationModel>>(
        stream: _appService.getAllApplications(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final apps = snap.data ?? [];

          if (apps.isEmpty) {
            return const Center(
              child: Text('No applications yet.'),
            );
          }

          // Separate by status
          final pending = apps.where((a) => a.status == 'pending').toList();
          final approved = apps.where((a) => a.status == 'approved').toList();
          final rejected = apps.where((a) => a.status == 'rejected').toList();

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'Pending (${pending.length})'),
                    Tab(text: 'Approved (${approved.length})'),
                    Tab(text: 'Rejected (${rejected.length})'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildApplicationsList(pending, true),
                      _buildApplicationsList(approved, false),
                      _buildApplicationsList(rejected, false),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplicationsList(List<ProviderApplicationModel> apps, bool isPending) {
    if (apps.isEmpty) {
      return const Center(child: Text('No applications in this category.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: apps.length,
      itemBuilder: (ctx, i) {
        final app = apps[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                          Text(
                            app.applicantName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            app.applicantEmail,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(app.serviceType),
                            backgroundColor: AppTheme.primary.withOpacity(0.1),
                            labelStyle: const TextStyle(fontSize: 11, color: AppTheme.primary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: app.status == 'approved'
                            ? Colors.green.shade100
                            : app.status == 'rejected'
                                ? Colors.red.shade100
                                : Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        app.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: app.status == 'approved'
                              ? Colors.green
                              : app.status == 'rejected'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Phone', app.applicantPhone),
                _buildDetailRow('License', app.licenseNumber),
                _buildDetailRow('Experience', app.experienceYears),
                _buildDetailRow('Certifications', app.certifications),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        app.bio,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (app.adminNotes != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Notes:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          app.adminNotes!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isPending) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: '✅ Approve',
                          onPressed: () => _approveApplication(app),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButton(
                          label: '❌ Reject',
                          onPressed: () => _rejectApplication(app),
                          backgroundColor: AppTheme.error,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
