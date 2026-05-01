import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../services/notification_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final _service = AppointmentService();
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;

  void listenToAppointments(String userId) {
    _subscription?.cancel();
    _subscription = _service.getAppointments(userId).listen((list) {
      _appointments = list;
      notifyListeners();
    });
  }

  Future<void> addAppointment(AppointmentModel appt) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createAppointment(appt);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAppointment(
      String id, Map<String, dynamic> data) async {
    await _service.updateAppointment(id, data);
    notifyListeners();
  }

  Future<void> deleteAppointment(String id, {int? notifId}) async {
    await _service.deleteAppointment(id);
    if (notifId != null) {
      await NotificationService.cancelNotification(notifId);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
