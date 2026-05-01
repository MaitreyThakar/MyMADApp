import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/provider_model.dart';

class ProviderService {
  final _col = FirebaseFirestore.instance.collection('providers');

  /// Get all providers (admin view)
  Stream<List<ProviderModel>> getAllProviders() => _col.snapshots().map((s) =>
      s.docs.map((d) => ProviderModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());

  /// Get only approved providers (for booking/customer view)
  Stream<List<ProviderModel>> getApprovedProviders() => _col
      .where('isApproved', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs
          .map((d) => ProviderModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList());

  Future<ProviderModel?> getProvider(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return ProviderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<String> createProvider(ProviderModel p) async {
    final docRef = await _col.add(p.toMap());
    return docRef.id;
  }

  Future<void> updateProvider(String id, Map<String, dynamic> data) async => await _col.doc(id).update(data);

  Future<void> deleteProvider(String id) async => await _col.doc(id).delete();
}
