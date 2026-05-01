class AppConstants {
  static const String appName = 'Appointment App';
  static const String appTagline = 'Book smarter, wait less.';
  static const String postsApiUrl =
      'https://jsonplaceholder.typicode.com/posts';

  static const String notifChannelId = 'appointment_channel';
  static const String notifChannelName = 'Appointment Alerts';

  static const List<String> serviceTypes = [
    'Clinic',
    'Salon',
    'Tutor',
    'Repair',
  ];

  static const List<String> statusTypes = [
    'pending',
    'confirmed',
    'cancelled',
  ];

  static const List<Map<String, String>> sampleSlots = [
    {'time': '09:00 AM', 'status': 'available'},
    {'time': '09:30 AM', 'status': 'booked'},
    {'time': '10:00 AM', 'status': 'available'},
    {'time': '10:30 AM', 'status': 'available'},
    {'time': '11:00 AM', 'status': 'booked'},
    {'time': '11:30 AM', 'status': 'available'},
    {'time': '02:00 PM', 'status': 'available'},
    {'time': '02:30 PM', 'status': 'available'},
  ];
}
