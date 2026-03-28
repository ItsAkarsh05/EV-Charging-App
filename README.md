# EVOLTSOFT — EV Charging Station App

A Flutter mobile application for discovering and navigating EV charging stations, with real-time connector status updates.

---

## 📱 Features

- **Firebase Phone OTP Authentication** — Secure login via SMS verification
- **User Onboarding** — 3-page animated intro flow on first launch
- **Charging Station Discovery** — Full-screen Google Maps with custom markers and a draggable station card sheet
- **Live Connector Status** — Polling every 30s to refresh connector availability on the details screen
- **Node.js Backend** — REST API for station data with randomised availability to simulate real-world updates
- **Riverpod State Management** — Auth state, station list, and station detail providers
- **Offline Fallback** — Loads hardcoded dummy stations if the backend is unreachable

---

## 🗂️ Project Structure

```
ev-charging-app/
├── backend/          # Node.js Express API
│   └── src/
│       ├── server.js
│       ├── routes/stations.js
│       └── data/stations.js
└── frontend/         # Flutter app
    └── lib/
        ├── core/          # Theme, colors, text styles, constants
        └── features/
            ├── auth/      # Login, OTP, Firebase auth service, Riverpod provider
            ├── home/      # Map, station cards, charging details, station service
            ├── onboarding/# 3-page onboarding flow
            └── shell/     # Persistent bottom navigation bar shell
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.x SDK
- Node.js 18+
- Android device / emulator with Google Play Services
- A Firebase project with **Phone Authentication** enabled

---

### 1. Clone the Repository

```bash
git clone https://github.com/ItsAkarsh05/EV-Charging-App.git
cd EV-Charging-App
```

---

### 2. Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Phone Authentication** under Authentication → Sign-in methods
3. Add an **Android app** and download `google-services.json`
4. Place it at `frontend/android/app/google-services.json`

---

### 3. Environment Variables

Create `frontend/.env`:

```env
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

Get a Maps API key from [Google Cloud Console](https://console.cloud.google.com) with the **Maps SDK for Android** enabled.

---

### 4. Run the Backend

```bash
cd backend
npm install
npm run dev
```

Backend starts on `http://localhost:3000`.

**API Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/stations` | List all charging stations |
| GET | `/api/stations/:id` | Get a single station (for polling) |

---

### 5. Run the Flutter App

#### Connect backend to your device

**Android Emulator:**
```bash
# Change _baseUrl in frontend/lib/features/home/services/station_service.dart to:
static const String _baseUrl = 'http://10.0.2.2:3000/api';
```

**Physical Device (recommended — via ADB):**
```bash
# Keep _baseUrl as localhost, then run:
adb reverse tcp:3000 tcp:3000
```

**Physical Device (same WiFi):**
```bash
# Set _baseUrl to your PC's local IP, e.g.:
static const String _baseUrl = 'http://192.168.x.x:3000/api';
```

#### Install dependencies and run

```bash
cd frontend
flutter pub get
flutter run
```

---

## 📲 User Flows

| Flow | Description |
|------|-------------|
| **Onboarding** | 3-page animated intro shown on first app launch |
| **Authentication** | Enter phone number → receive OTP → verify → access app |
| **Charger Discovery** | Full-screen map with custom markers, draggable station card list |
| **Charger Details** | Station info, image carousel, connector list with live polling every 30s |

---

## 🔧 State Management

**Riverpod** is used throughout:

| Provider | Type | Purpose |
|----------|------|---------|
| `authProvider` | `NotifierProvider` | Manages auth state (idle, loading, codeSent, authenticated, error) |
| `stationsProvider` | `AsyncNotifierProvider` | Fetches station list, with dummy data fallback |
| `stationDetailProvider` | `FutureProvider.family` | Fetches individual station for polling |
| `stationServiceProvider` | `Provider` | HTTP client singleton with auto-dispose |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| State Management | Riverpod |
| Authentication | Firebase Phone Auth |
| Maps | Google Maps Flutter |
| Backend | Node.js + Express |
| HTTP | `package:http` |
| Fonts | Plus Jakarta Sans (Google Fonts) |
| Persistence | SharedPreferences |

---

## ⚙️ Configuration Notes

- Phone Auth requires a **real device or properly configured emulator** with Google Play Services
- Backend uses randomised availability data to simulate real-world charger state changes
- The app gracefully falls back to offline dummy data if the backend is unreachable
- First launch shows onboarding; subsequent launches go directly to Login or Home based on session

---

## 📦 Building the APK

```bash
cd frontend
flutter build apk --release
```

Output: `frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## 🔐 Security Notes

- `.env` and `google-services.json` are listed in `.gitignore` and must **never** be committed
- Configure your own Firebase project and Google Maps API key before running
