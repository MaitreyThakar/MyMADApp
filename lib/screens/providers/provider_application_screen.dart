import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/provider_application_model.dart';
import '../../services/application_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

class ProviderApplicationScreen extends StatefulWidget {
  const ProviderApplicationScreen({super.key});

  @override
  State<ProviderApplicationScreen> createState() => _ProviderApplicationScreenState();
}

class _ProviderApplicationScreenState extends State<ProviderApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _serviceTypeCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _certCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _isLoading = false;

  final List<String> _serviceTypes = ['Clinic', 'Salon', 'Tutor', 'Repair', 'Other'];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _serviceTypeCtrl.dispose();
    _licenseCtrl.dispose();
    _certCtrl.dispose();
    _experienceCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    if (auth.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final app = ProviderApplicationModel(
        applicationId: '',
        applicantUserId: auth.userId,
        applicantName: auth.userName,
        applicantEmail: auth.userEmail,
        applicantPhone: _phoneCtrl.text.trim(),
        serviceType: _serviceTypeCtrl.text,
        licenseNumber: _licenseCtrl.text.trim(),
        certifications: _certCtrl.text.trim(),
        experienceYears: _experienceCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        appliedAt: DateTime.now().toIso8601String(),
      );

      final appService = ApplicationService();
      await appService.submitApplication(app);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Application submitted! Admins will review it shortly.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply as Provider'),
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Provider Application',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Submit your details for verification. Admins will review and approve your application.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              // Read-only fields
              TextFormField(
                initialValue: auth.userName,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: auth.userEmail,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // Phone
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1 (555) 123-4567',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Phone number required' : null,
              ),
              const SizedBox(height: 12),
              // Service Type
              DropdownButtonFormField<String>(
                value: _serviceTypeCtrl.text.isEmpty ? null : _serviceTypeCtrl.text,
                decoration: const InputDecoration(
                  labelText: 'Service Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _serviceTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _serviceTypeCtrl.text = v ?? ''),
                validator: (v) => v == null || v.isEmpty ? 'Select service type' : null,
              ),
              const SizedBox(height: 12),
              // License Number
              TextFormField(
                controller: _licenseCtrl,
                decoration: const InputDecoration(
                  labelText: 'License Number',
                  hintText: 'e.g., LIC-12345',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (v) => v == null || v.isEmpty ? 'License number required' : null,
              ),
              const SizedBox(height: 12),
              // Certifications
              TextFormField(
                controller: _certCtrl,
                decoration: const InputDecoration(
                  labelText: 'Certifications',
                  hintText: 'e.g., Certified Medical Professional, License XYZ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Certifications required' : null,
              ),
              const SizedBox(height: 12),
              // Years of Experience
              TextFormField(
                controller: _experienceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Years of Experience',
                  hintText: 'e.g., 5 years',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Experience required' : null,
              ),
              const SizedBox(height: 12),
              // Bio
              TextFormField(
                controller: _bioCtrl,
                decoration: const InputDecoration(
                  labelText: 'About You',
                  hintText: 'Tell us about your background and specialties...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Bio required' : null,
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Submit Application',
                onPressed: _submitApplication,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
