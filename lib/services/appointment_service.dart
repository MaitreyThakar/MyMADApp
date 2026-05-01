import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final _col = FirebaseFirestore.instance.collection('appointments');

  Future<void> createAppointment(AppointmentModel appt) async =>
      await _col.add(appt.toMap());

  Stream<List<AppointmentModel>> getAppointments(String userId) =>
      _col
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => AppointmentModel.fromMap(d.data(), d.id))
              .toList());

  Future<void> updateAppointment(
          String id, Map<String, dynamic> data) async =>
      await _col.doc(id).update(data);

  Future<void> deleteAppointment(String id) async =>
      await _col.doc(id).delete();
}
