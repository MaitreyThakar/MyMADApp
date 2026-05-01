import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final _col = FirebaseFirestore.instance.collection('appointments');

    Future<void> createAppointment(AppointmentModel appt, {String? slotId}) async {
        await _col.add(appt.toMap());
        if (slotId != null && slotId.isNotEmpty) {
            try {
                await FirebaseFirestore.instance.collection('slots').doc(slotId).update({'status': 'booked'});
            } catch (_) {}
        }
        return;
    }

  Stream<List<AppointmentModel>> getAppointments(String userId) =>
      _col
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snap) {
            final list = snap.docs
                .map((d) => AppointmentModel.fromMap(d.data(), d.id))
                .toList();
            // Client-side sort avoids requiring a composite index for userId+createdAt.
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          });

  Future<void> updateAppointment(
          String id, Map<String, dynamic> data) async =>
      await _col.doc(id).update(data);

  Future<void> deleteAppointment(String id) async =>
      await _col.doc(id).delete();

    /// Reschedule an appointment and update slot statuses transactionally.
    Future<void> rescheduleAppointment({
        required String appointmentId,
        required String newDate,
        required String newTime,
        String? newSlotId,
        String? oldSlotId,
    }) async {
        final batch = FirebaseFirestore.instance.batch();
        final apptRef = _col.doc(appointmentId);
        batch.update(apptRef, {
            'date': newDate,
            'timeSlot': newTime,
            'slotId': newSlotId,
            'status': 'confirmed',
        });

        if (oldSlotId != null && oldSlotId.isNotEmpty) {
            final oldRef = FirebaseFirestore.instance.collection('slots').doc(oldSlotId);
            batch.update(oldRef, {'status': 'available'});
        }

        if (newSlotId != null && newSlotId.isNotEmpty) {
            final newRef = FirebaseFirestore.instance.collection('slots').doc(newSlotId);
            batch.update(newRef, {'status': 'booked'});
        }

        await batch.commit();
    }

    Future<void> cancelAppointment(String appointmentId, {String? slotId}) async {
        final batch = FirebaseFirestore.instance.batch();
        final apptRef = _col.doc(appointmentId);
        batch.update(apptRef, {'status': 'cancelled'});
        if (slotId != null && slotId.isNotEmpty) {
            final slotRef = FirebaseFirestore.instance.collection('slots').doc(slotId);
            batch.update(slotRef, {'status': 'available'});
        }
        await batch.commit();
    }
}
