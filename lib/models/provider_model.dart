class ProviderModel {
  final String providerId;
  final String name;
  final String description;
  final String location;
  final Map<String, dynamic> hours; // e.g., {"mon": {"start":"09:00","end":"17:00"}}
  final int slotDurationMinutes;
  final bool isApproved; // true if verified provider, false otherwise
  final String? approvalStatus; // 'pending', 'approved', 'rejected'

  ProviderModel({
    required this.providerId,
    required this.name,
    this.description = '',
    this.location = '',
    this.hours = const {},
    this.slotDurationMinutes = 30,
    this.isApproved = false,
    this.approvalStatus,
  });

  factory ProviderModel.fromMap(Map<String, dynamic> map, String id) {
    return ProviderModel(
      providerId: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      hours: Map<String, dynamic>.from(map['hours'] ?? {}),
      slotDurationMinutes: map['slotDurationMinutes'] ?? 30,
      isApproved: map['isApproved'] ?? false,
      approvalStatus: map['approvalStatus'],
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'location': location,
        'hours': hours,
        'slotDurationMinutes': slotDurationMinutes,
        'isApproved': isApproved,
        if (approvalStatus != null) 'approvalStatus': approvalStatus,
      };
}
