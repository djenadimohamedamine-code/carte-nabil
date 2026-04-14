# 🚀 Handoff Guide: Zone 14 Membership Scanner

This project is a high-performance membership scanner for stadium entry management, built with Flutter and Firebase.

## 📋 Project Status
- **Core Features**: Functional OCR scanner, multi-zone filtering, real-time attendance tracking, permanent scan history, and attendance reset.
- **Platforms**: Android (APK), iOS (Native/Web PWA), Web.
- **CI/CD**: Fully automated via GitHub Actions (Android, iOS, Web PWA).

## 🛠 Tech Stack
- **Framework**: Flutter (Dart)
- **Database**: Firebase Firestore (`members` and `scans_history` collections).
- **OCR**: Google ML Kit Text Recognition (On-device).
- **CI/CD**: GitHub Actions (MacOS runners for iOS, Ubuntu for Android/Web).

## 📂 Key Files to Hand Over
- `lib/`: All application logic.
    - `main.dart`: Entry point & navigation.
    - `scanner_screen.dart`: OCR logic & feedback.
    - `members_list_screen.dart`: attendance view & reset.
    - `history_screen.dart`: Permanent logs.
    - `data_manager.dart`: Member seeding & database cleanup.
- `.github/workflows/`: Critical CI/CD scripts.
    - `ios.yml`: Optimized with the **"Spark Method"** (Remote Reconstruction) for 100% stability.
    - `android.yml`: Standard APK generation.
    - `web_pwa.yml`: Deployment to GitHub Pages.
- `pubspec.yaml`: Dependencies (Note: `intl: ^0.20.2` is required for compatibility).
- `google-services.json` (Android) & `GoogleService-Info.plist` (iOS): Firebase config files.

## 🤖 Guide pour l'Agent de Codage (AI Assistant)
Si vous êtes l'IA assistant du collaborateur, voici les instructions pour prendre le relais efficacement :

- 📍 **Clonage & Sync** : Clonez le repo et faites toujours un `git pull` avant de commencer. Les identifiants de collaboration ont été validés.
- 🛠️ **Scripts d'Automatisation** : Utilisez `launch_build.bat` pour synchroniser le code et déclencher les builds CI/CD (iOS/Android/Web).
- 🧬 **Pipeline iOS (STABLE)** : Le fichier `.github/workflows/ios.yml` a été stabilisé avec la **"Spark Method"**. Il recrée le dossier `ios/` à chaque build et force le `IPHONEOS_DEPLOYMENT_TARGET` à **13.0**. 
- ⚔️ **Nettoyage -G** : Le workflow scanne et supprime automatiquement toute trace du flag obsolète `-G` dans les fichiers de configuration pour éviter les erreurs Xcode (`unsupported option -G`).
- 📸 **Permissions** : La permission `NSCameraUsageDescription` est automatiquement injectée.
- 🧹 **Nettoyage des Données** : Le `DataManager` vide la collection de membres avant de re-seeder pour éviter les doublons.
- 📥 **Export History** : La fonction d'exportation vers Excel (CSV) est disponible dans l'onglet Historique.

## 📌 Next Steps
- Intégrer la liste complète des membres des 14 zones.
- Valider la précision de l'OCR en conditions réelles de stade.
- Finaliser la signature Xcode pour une distribution sur l'App Store.

---
**Maintained by Antigravity AI Agent**
*Good luck with the project!*
