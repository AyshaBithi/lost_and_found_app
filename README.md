# Lost and Found Hub

<p align="center">
  <img src="assets/logo.svg" alt="Lost and Found Hub Logo" width="200"/>
</p>

A modern, cross-platform application for managing lost and found items. This application provides a centralized platform for reporting lost items and registering found items, making it easier for people to recover their belongings.

## 📱 Supported Platforms

- Web (Chrome, Firefox, Safari, Edge)
- Android
- iOS
- Windows
- macOS
- Linux

## ✨ Features

- **User-friendly Interface**: Modern, intuitive UI with smooth animations and transitions
- **Item Management**: Report lost items and register found items with detailed information
- **Search & Filter**: Easily search and filter items by category, date, location, etc.
- **Admin Dashboard**: Secure admin panel for managing items and users
- **Responsive Design**: Works seamlessly across all screen sizes and devices
- **Cloud Database**: Stores data in Firebase Firestore for real-time synchronization across devices
- **Authentication**: Secure login system for administrators

## 🛠️ Technologies Used

### Frontend
- **Flutter**: Cross-platform UI framework
- **Provider**: State management solution
- **Google Fonts**: Typography and text styling
- **Flutter Animate**: Animation library for smooth transitions
- **Intl**: Internationalization and date formatting

### Backend & Storage
- **Firebase Firestore**: Cloud database for real-time data storage
- **Firebase Authentication**: User authentication and management
- **Firebase Storage**: Cloud storage for images and files
- **Shared Preferences**: Lightweight storage for user preferences
- **Flutter Secure Storage**: Secure storage for sensitive information

### Authentication
- **Crypto**: Password hashing and security
- **Custom Auth Service**: Role-based authentication system

### UI Components
- **Material Design 3**: Modern design system
- **Custom Widgets**: Tailored components for lost and found items
- **Responsive Layouts**: Adaptive UI for different screen sizes

## 🏗️ Architecture

The application follows a clean architecture approach with separation of concerns:

- **Models**: Data structures representing items, users, etc.
- **Services**: Business logic and data operations
- **Providers**: State management and data flow
- **Screens**: UI components and user interaction
- **Widgets**: Reusable UI elements

## 📊 Data Model

### Item
- ID
- Title
- Description
- Status (Lost/Found)
- Category
- Location
- Date
- Image URL
- Reported By
- Resolution Status

### User
- ID
- Username
- Password (hashed)
- Admin Status
- Name
- Email
- Creation Date

## 🔐 Authentication

The application uses a secure authentication system:

- Password hashing with SHA-256
- Salted passwords for enhanced security
- Secure storage of credentials
- Session management

Admin credentials:
- Username: `admin`
- Password: `password`

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- IDE (VS Code, Android Studio, or IntelliJ IDEA)
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/AyshaBithi/lost_and_found_app.git
   ```

2. Navigate to the project directory:
   ```bash
   cd lost_and_found_hub
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Configure Firebase:
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Register your app with Firebase
   - Edit the `web/firebase-config.js` file with your Firebase configuration:
     ```javascript
     const firebaseConfig = {
       apiKey: "YOUR_API_KEY",
       authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
       projectId: "YOUR_PROJECT_ID",
       storageBucket: "YOUR_PROJECT_ID.appspot.com",
       messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
       appId: "YOUR_APP_ID"
     };
     ```
   - For detailed Firebase setup instructions, see the [FIREBASE_SETUP.md](FIREBASE_SETUP.md) file

5. Run the application:
   ```bash
   flutter run -d chrome  # For web
   flutter run             # For default device
   ```

## 📱 Usage

### Home Screen
- Browse lost and found items
- Filter items by category
- Search for specific items

### Reporting Items
- Click on "Report Lost Item" or "Report Found Item"
- Fill in the details (title, description, category, location, etc.)
- Upload an image (optional)
- Submit the report

### Admin Dashboard
- Access the admin panel by clicking on the "Admin" tab
- Login with admin credentials
- Manage items (view, mark as resolved, delete)
- View statistics and reports

## 🧪 Testing

Run tests using the following command:

```bash
flutter test
```

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Contact

If you have any questions or suggestions, please open an issue or contact the repository owner.

---

Built with ❤️ using Flutter
