class ProviderApplicationModel {
  final String applicationId;
  final String applicantUserId;       // Firebase UID of applicant
  final String applicantName;
  final String applicantEmail;
  final String applicantPhone;
  final String serviceType;           // e.g., 'Clinic', 'Salon', 'Tutor', 'Repair'
  final String licenseNumber;
  final String certifications;        // e.g., comma-separated cert names
  final String experienceYears;
  final String bio;
  final String status;                // 'pending', 'approved', 'rejected'
  final String appliedAt;             // ISO 8601
  final String? reviewedAt;           // ISO 8601, null until reviewed
  final String? adminNotes;           // Rejection reason or approval notes
  final String? approvedProviderId;   // Links to provider doc in providers collection

  ProviderApplicationModel({
    required this.applicationId,
    required this.applicantUserId,
    required this.applicantName,
    required this.applicantEmail,
    required this.applicantPhone,
    required this.serviceType,
    required this.licenseNumber,
    required this.certifications,
    required this.experienceYears,
    required this.bio,
    this.status = 'pending',
    required this.appliedAt,
    this.reviewedAt,
    this.adminNotes,
    this.approvedProviderId,
  });

  factory ProviderApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return ProviderApplicationModel(
      applicationId: id,
      applicantUserId: map['applicantUserId'] ?? '',
      applicantName: map['applicantName'] ?? '',
      applicantEmail: map['applicantEmail'] ?? '',
      applicantPhone: map['applicantPhone'] ?? '',
      serviceType: map['serviceType'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      certifications: map['certifications'] ?? '',
      experienceYears: map['experienceYears'] ?? '',
      bio: map['bio'] ?? '',
      status: map['status'] ?? 'pending',
      appliedAt: map['appliedAt'] ?? '',
      reviewedAt: map['reviewedAt'],
      adminNotes: map['adminNotes'],
      approvedProviderId: map['approvedProviderId'],
    );
  }

  Map<String, dynamic> toMap() => {
        'applicantUserId': applicantUserId,
        'applicantName': applicantName,
        'applicantEmail': applicantEmail,
        'applicantPhone': applicantPhone,
        'serviceType': serviceType,
        'licenseNumber': licenseNumber,
        'certifications': certifications,
        'experienceYears': experienceYears,
        'bio': bio,
        'status': status,
        'appliedAt': appliedAt,
        if (reviewedAt != null) 'reviewedAt': reviewedAt,
        if (adminNotes != null) 'adminNotes': adminNotes,
        if (approvedProviderId != null) 'approvedProviderId': approvedProviderId,
      };
}
