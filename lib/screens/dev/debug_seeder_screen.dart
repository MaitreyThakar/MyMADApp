import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/provider_service.dart';
import '../../services/slots_service.dart';
import '../../models/provider_model.dart';
import '../../config/theme.dart';

class DebugSeederScreen extends StatefulWidget {
  const DebugSeederScreen({super.key});

  @override
  State<DebugSeederScreen> createState() => _DebugSeederScreenState();
}

class _DebugSeederScreenState extends State<DebugSeederScreen> {
  final _providerService = ProviderService();
  final _slotsService = SlotsService();
  bool _working = false;
  String _log = '';
  
  final _adminEmailCtrl = TextEditingController();
  final _adminPassCtrl = TextEditingController();
  final _adminNameCtrl = TextEditingController();

  @override
  void dispose() {
    _adminEmailCtrl.dispose();
    _adminPassCtrl.dispose();
    _adminNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _createAndSeed() async {
    setState(() {
      _working = true;
      _log = '';
    });

    try {
      final provider = ProviderModel(
        providerId: '',
        name: 'Test Provider',
        description: 'Auto-seeded provider for testing',
        location: 'Test Clinic',
        hours: {
          'mon': {'start': '09:00', 'end': '17:00'},
        },
        slotDurationMinutes: 30,
      );

      final id = await _providerService.createProvider(provider);
      _append('Created provider id: $id');

      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await _slotsService.generateSlotsForDate(
        providerId: id,
        date: dateStr,
        start: '09:00',
        end: '17:00',
        slotDurationMinutes: provider.slotDurationMinutes,
      );
      _append('Generated slots for $dateStr');
    } catch (e) {
      _append('Error: $e');
    } finally {
      setState(() => _working = false);
    }
  }

  void _append(String s) {
    setState(() => _log = '$_log\n$s');
  }

  Future<void> _createAdminAccount() async {
    final email = _adminEmailCtrl.text.trim();
    final password = _adminPassCtrl.text.trim();
    final name = _adminNameCtrl.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      _showError('Please fill all admin fields');
      return;
    }

    setState(() {
      _working = true;
      _log = '';
    });

    try {
      // Create Firebase Auth account
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _append('✅ Created Firebase Auth account: ${cred.user?.uid}');

      // Create Firestore user document with admin role
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user?.uid)
          .set({
        'name': name,
        'email': email,
        'role': 'admin', // Set as admin
        'createdAt': DateTime.now().toIso8601String(),
      });

      _append('✅ Created admin user in Firestore');
      _append('📧 Email: $email');
      _append('🔑 Password: $password');
      _append('👤 Name: $name');
      _append('\n✅ Admin account created successfully!');
      _append('Logout and login with these credentials to access admin features.');

      // Clear fields
      _adminEmailCtrl.clear();
      _adminPassCtrl.clear();
      _adminNameCtrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Admin account created! Logout and login to use it.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = '❌ Email already registered';
          break;
        case 'invalid-email':
          msg = '❌ Invalid email format';
          break;
        case 'weak-password':
          msg = '❌ Password too weak (min 6 chars)';
          break;
        default:
          msg = '❌ Error: ${e.message}';
      }
      _append(msg);
    } catch (e) {
      _append('❌ Error: $e');
    } finally {
      setState(() => _working = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const Scaffold(body: Center(child: Text('Not available')));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Tools'),
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Creation Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Create Admin Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _adminNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Admin Name',
                      hintText: 'John Admin',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _adminEmailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Admin Email',
                      hintText: 'admin@example.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _adminPassCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Admin Password',
                      hintText: 'Min 6 characters',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _working ? null : _createAdminAccount,
                      icon: const Icon(Icons.add_moderator),
                      label: Text(_working ? 'Creating...' : 'Create Admin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            // Provider Seeder Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business_center, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Test Data Seeder',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _working ? null : _createAndSeed,
                      icon: const Icon(Icons.add_business),
                      label: Text(_working ? 'Working...' : 'Create Test Provider + Slots'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Activity Log:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _log.isEmpty ? 'No actions yet. Use the tools above.' : _log,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
