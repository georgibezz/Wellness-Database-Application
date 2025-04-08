# 🌿 Wellness Database App

**A cross-platform Flutter application designed to make holistic healing accessible, informed, and safe.**  
Built using Flutter & Dart in Android Studio with ObjectBox for local and synced database storage, this app empowers users to explore natural remedies through symptom-based lookup, curated remedy plans, and community-driven reviews.  

---

## 🚀 Features

- 🔍 **Smart Remedy Lookup** based on conditions & symptoms  
- 🧾 **Admin dashboard** for adding/editing remedy plans  
- 🗣️ **User reviews & community feedback**  
- 🛠️ **Custom ObjectBox backend** with real-time sync  
- 📴 **Offline access** to trusted remedy information  
- 💾 Built for **scalability**, **security**, and **multi-language** support  

---

## 🛠️ Tech Stack

| Layer       | Tech                                             |
|------------|--------------------------------------------------|
| Frontend   | Flutter + Dart                                   |
| Backend    | Dart, ObjectBox Sync                             |
| Database   | ObjectBox (local & sync server via Docker)       |
| IDE        | Android Studio                                   |
| Testing    | Emulators & physical devices                     |

---

## ⚙️ Installation Guide

### 📦 Requirements

Install the following:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart/archive)
- [Android Studio](https://developer.android.com/studio)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)

---
### 📥 Clone and Set Up the Project

```bash
git clone https://github.com/your-username/Wellness-Database-App.git
cd Wellness-Database-App
flutter pub get
```
---
### 🐳 Set Up the ObjectBox Sync Server with Docker

Run the following prompt in the system terminal to set up Docker Desktop:

- Replace `YOUR_LOCAL_IP` with your actual local IP (e.g., 192.168.1.100)
- Choose ports that are available (e.g., `9999` for sync, `9980` for Admin UI)

```bash
cd sync-server
```
```
docker run --rm -it \
  -v "${PWD}:/data" \
  -p YOUR_LOCAL_IP:9999:9999 \
  -p YOUR_LOCAL_IP:9980:9980 \
  objectboxio/sync:sync-server-2023-06-14 \
  --model ./data/objectbox-model.json \
  --unsecured-no-authentication \
  --admin-bind 0.0.0.0:9980
```

- Open **Docker Desktop** to verify the container is running.
- Access the Admin UI via: `http://YOUR_LOCAL_IP:9980`

---
## 🧪 Running the App

Open the project in Android Studio.
Ensure `admin/` and `user/` folders are configured as separate modules.

- Run each module **individually** on an emulator or physical device.

---
## 🔁 Making Model Changes?

<ins>After editing</ins> ObjectBox entities:
```
flutter pub run build_runner build
```
Then copy the following files to the appropriate folders:

- `objectbox.g.dart` → `admin/`, `user/`

- `objectbox-model.json` → `admin/`, `user/`, `sync-server/data/`

**Restart** the Docker container after copying.

---
## 🩺 Troubleshooting

❗ Missing SDK Paths?

In Android Studio, go to:

1. `Settings > Languages & Frameworks > Dart/Flutter`

2. Set correct paths for Dart SDK and Flutter SDK

3. Add these paths to your system environment variables

---
## 🧪 Check System Readiness

The application will **not** run if flutter is incorrectly set up. Ensure flutter readiness by running the prompt in system terminal.

```
flutter doctor
```

---
## 📚 Project Background

Developed as part of a university capstone project by Team HealingTech Squad.
Recognized for exceptional teamwork and innovation.
Built with love, curiosity, and a desire to make wellness accessible to all 🌱

---
## 🤝 Contributors
Georgi Bezuidenhout (Lead Developer)

Hezel Musaringo (Project Manager)

Tariro Shonhai

Leilah Adriaanse




