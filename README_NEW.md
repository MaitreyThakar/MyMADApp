# 📅 Smart Slot Booking System (MyMADApp)

A complete Flutter appointment booking application with provider approval workflow, role-based access control, and admin management.

## 🎯 Features

### For Users:
- ✅ Register and login with email/password
- ✅ Browse available service providers
- ✅ Book appointments with time slots
- ✅ View and manage appointments
- ✅ Apply to become a provider
- ✅ Real-time updates

### For Providers:
- ✅ All user features
- ✅ Manage services and availability
- ✅ Set time slots
- ✅ View bookings
- ✅ Analytics dashboard

### For Admins:
- ✅ Review provider applications
- ✅ Approve/Reject applications with notes
- ✅ Manage all providers
- ✅ System-wide access
- ✅ Real-time application monitoring

## 🚀 Quick Start

### 1. Setup
```bash
# Clone the repository
git clone <your-repo-url>

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### 2. Create Admin Account

**Choose one method:**

#### Method A: Firebase Console (30 seconds) ⭐ RECOMMENDED
1. Register a user in the app
2. Go to [Firebase Console](https://console.firebase.google.com)
3. Navigate to Firestore Database → `users` collection
4. Find your user document
5. Change `role` field from `"user"` to `"admin"`
6. Logout and login again

#### Method B: Dev Tools (1 minute)
1. Run app in debug mode
2. Login as any user
3. Open drawer → "Dev Tools"
4. Fill admin creation form
5. Click "Create Admin"
6. Logout and login with admin credentials

#### Method C: Registration with Code (2 minutes)
1. Open app → Register
2. Select "Admin" role
3. Enter admin code: `ADMIN2024`
4. Create account and login

### 3. Test the Workflow
1. Create a test user account
2. Login as test user
3. Apply to be a provider
4. Logout and login as admin
5. Review and approve the application
6. Verify provider was created

## 📚 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Fast reference guide
- **[ADMIN_SETUP_GUIDE.md](ADMIN_SETUP_GUIDE.md)** - Complete admin setup guide
- **[WORKFLOW_DIAGRAM.md](WORKFLOW_DIAGRAM.md)** - Visual workflow diagrams
- **[SUMMARY.md](SUMMARY.md)** - System analysis summary

## 🔄 Provider Approval Workflow

```
User Registers → Applies as Provider → Admin Reviews → Approve/Reject
                                                          ↓
                                              Provider Created + Role Updated
```

### Detailed Flow:
1. **User applies** via "Apply as Provider" form
2. **Application stored** in Firestore with status: `pending`
3. **Admin reviews** in "Provider Applications" screen
4. **Admin approves/rejects** with notes
5. **System automatically:**
   - Creates provider entry (if approved)
   - Updates user role to `provider`
   - Links provider ID to application
   - Stores approval timestamp

## 🗂️ Project Structure

```
lib/
├── models/              # Data models
│   ├── user_model.dart
│   ├── provider_application_model.dart
│   └── provider_model.dart
├── providers/           # State management
│   ├── auth_provider.dart
│   └── appointment_provider.dart
├── services/            # Business logic
│   ├── application_service.dart
│   └── provider_service.dart
├── screens/             # UI screens
│   ├── admin/          # Admin screens
│   ├── auth/           # Login/Register
│   ├── providers/      # Provider screens
│   └── home/           # Main screens
└── config/             # App configuration
```

## 🔐 Roles & Permissions

| Feature | User | Provider | Admin |
|---------|------|----------|-------|
| Book appointments | ✅ | ✅ | ✅ |
| View providers | ✅ | ✅ | ✅ |
| Apply as provider | ✅ | ✅ | ✅ |
| Manage services | ❌ | ✅ | ✅ |
| Set availability | ❌ | ✅ | ✅ |
| Review applications | ❌ | ❌ | ✅ |
| Approve/Reject | ❌ | ❌ | ✅ |
| Manage all providers | ❌ | ❌ | ✅ |

## 🗄️ Firestore Collections

### users
```json
{
  "uid": "user123",
  "name": "John Doe",
  "email": "john@example.com",
  "role": "user" | "provider" | "admin",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### providerApplications
```json
{
  "applicationId": "app123",
  "applicantUserId": "user123",
  "status": "pending" | "approved" | "rejected",
  "serviceType": "Clinic",
  "licenseNumber": "LIC-12345",
  "certifications": "Medical License",
  "experienceYears": "5 years",
  "bio": "Description...",
  "appliedAt": "2024-01-01T10:00:00Z",
  "reviewedAt": "2024-01-02T12:00:00Z",
  "adminNotes": "Approval notes"
}
```

### providers
```json
{
  "providerId": "prov123",
  "name": "John Doe",
  "description": "Description...",
  "location": "City, State",
  "hours": {},
  "slotDurationMinutes": 30,
  "isApproved": true,
  "approvedAt": "2024-01-02T12:00:00Z"
}
```

## 🛠️ Tech Stack

- **Framework:** Flutter
- **Backend:** Firebase
  - Authentication
  - Firestore Database
  - Cloud Messaging (FCM)
- **State Management:** Provider
- **UI:** Material Design

## 🔒 Security

### Recommended Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /providerApplications/{appId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /providers/{providerId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 📱 Screenshots

### User Flow
- Registration screen with role selection
- Provider application form
- Appointment booking

### Admin Flow
- Provider applications dashboard
- Approve/Reject interface
- Application details view

## 🧪 Testing

### Test User Flow:
```bash
1. Register as user
2. Apply as provider
3. Check Firestore for pending application
```

### Test Admin Flow:
```bash
1. Create admin account
2. Login as admin
3. Review pending applications
4. Approve/Reject
5. Verify provider creation
```

## 🚧 Development

### Debug Tools
Access via drawer menu (debug mode only):
- Create admin accounts
- Seed test data
- Generate sample providers and slots

### Admin Secret Code
Default: `ADMIN2024`  
Change in: `lib/screens/auth/register_screen.dart` (line 17)

## 📝 TODO

- [ ] Add Firestore security rules
- [ ] Implement email notifications
- [ ] Add application history/audit log
- [ ] Multi-level admin roles
- [ ] Bulk approve/reject
- [ ] Provider verification badges
- [ ] Application analytics

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For questions or issues:
- Check the documentation files
- Review the workflow diagrams
- Examine the code comments

## 🎓 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package](https://pub.dev/packages/provider)

---

**Built with ❤️ using Flutter and Firebase**

**Admin Code:** `ADMIN2024` (Change this in production!)
