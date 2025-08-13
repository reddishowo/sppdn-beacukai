
# SPPDN (Sistem Presensi dan Pengelolaan Data Kegiatan)

A cross-platform Flutter application for managing user activities, attendance, and room management, integrated with Firebase and Google Sign-In. Built for Beacukai.

## Features

- **Authentication:** Google Sign-In and Firebase Auth for secure login.
- **User Roles:** Admin and regular user support.
- **Activity Management:** Add, view, and export user activities.
- **Room Management:** Manage rooms for different floors.
- **Data Export:** Export activities to Excel files.
- **Image Upload:** Attach images to activities using ImageKit and Image Picker.
- **Theming:** Light and dark mode with persistent theme settings.
- **Offline Storage:** Uses GetStorage for local preferences.
- **Responsive UI:** Works on Android, iOS, Web, Windows, MacOS, and Linux.

## Tech Stack

- **Flutter** (with GetX for state management and routing)
- **Firebase** (Auth, Firestore)
- **Google Sign-In**
- **ImageKit, Image Picker**
- **Excel, OpenFileX, Path Provider**
- **GetStorage, Intl, Cached Network Image, Photo View**

## Project Structure

```
lib/
  main.dart                # App entry point
  firebase_options.dart    # Firebase config
  app/
	 modules/               # Feature modules (auth, home, export, etc.)
	 theme/                 # Theme and theme controller
	 routes/                # App routes
assets/
  logo.png, google_logo.png
```

## Getting Started

1. **Clone the repository:**
	```sh
	git clone https://github.com/reddishowo/sppdn-beacukai.git
	cd sppdn-beacukai
	```

2. **Install dependencies:**
	```sh
	flutter pub get
	```

3. **Firebase Setup:**
	- Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the respective folders.
	- Update `firebase_options.dart` if needed.

4. **Run the app:**
	```sh
	flutter run
	```

5. **Build APK:**
	```sh
	flutter build apk
	```

## Scripts

- `flutter pub get` – Install dependencies
- `flutter run` – Run the app
- `flutter build apk` – Build Android APK

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](LICENSE)
