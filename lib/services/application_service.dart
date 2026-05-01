import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/provider_application_model.dart';

class ApplicationService {
  final _col = FirebaseFirestore.instance.collection('providerApplications');

  /// Submit a new provider application
  Future<String> submitApplication(ProviderApplicationModel app) async {
    final docRef = await _col.add(app.toMap());
    return docRef.id;
  }

  /// Get all pending applications (for admin)
  Stream<List<ProviderApplicationModel>> getPendingApplications() => _col
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => ProviderApplicationModel.fromMap(d.data(), d.id))
          .toList());

  /// Get all applications by user
  Stream<List<ProviderApplicationModel>> getUserApplications(String userId) => _col
      .where('applicantUserId', isEqualTo: userId)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => ProviderApplicationModel.fromMap(d.data(), d.id))
          .toList());

  /// Get single application
  Future<ProviderApplicationModel?> getApplication(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return ProviderApplicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  /// Approve application and create provider
  Future<void> approveApplication(
    String appId,
    String providerId,
    String adminNotes,
  ) async {
    await _col.doc(appId).update({
      'status': 'approved',
      'reviewedAt': DateTime.now().toIso8601String(),
      'adminNotes': adminNotes,
      'approvedProviderId': providerId,
    });
  }

  /// Reject application
  Future<void> rejectApplication(String appId, String rejectionReason) async {
    await _col.doc(appId).update({
      'status': 'rejected',
      'reviewedAt': DateTime.now().toIso8601String(),
      'adminNotes': rejectionReason,
    });
  }

  /// Get all applications (admin view all, not filtered)
  Stream<List<ProviderApplicationModel>> getAllApplications() => _col
      .orderBy('appliedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => ProviderApplicationModel.fromMap(d.data(), d.id))
          .toList());
}
