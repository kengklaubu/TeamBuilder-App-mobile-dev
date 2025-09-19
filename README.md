# DSSi Shop 🛒

DSSi Shop is a demo e-commerce application built with **Flutter** as frontend and **PocketBase** as backend.  
It showcases product listing, fetching from PocketBase, and seeding sample data using Dart scripts with Faker.  

---

## 🚀 Features
- Flutter frontend (cross-platform, Web + Mobile)
- PocketBase backend (lightweight database + API)
- Faker for generating fake product data
- `.env` for secure environment variable management
- Seed script for adding products automatically
- Kanit font for UI styling

---

## 📂 Project Structure
```
dssishop/
│
├── lib/                # Flutter source code
│   ├── models/         # Dart models (e.g., Product)
│   ├── pages/          # Screens (HomePage, etc.)
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # App entry point
│
├── script/             # Dart scripts for seeding PocketBase
│   └── generate.dart
│
├── assets/             # Images and fonts
├── .env                # Environment variables (ignored in Git)
├── .gitignore          # Ignore unnecessary files
├── pubspec.yaml        # Dependencies
└── README.md           # Documentation
```

---

## ⚙️ Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/dssishop.git
cd dssishop
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Install Dart Dependencies for Script
```bash
dart pub get
```

### 4. Create `.env` File
Create a `.env` file in the **root** of the project:

```env
POCKETBASE_URL=http://127.0.0.1:8090
POCKETBASE_ADMIN_EMAIL=your_admin_email
POCKETBASE_ADMIN_PASSWORD=your_admin_password
```

⚠️ `.env` is ignored by Git (`.gitignore`), so you must create your own file.

---

## 🗄️ PocketBase Setup

1. Download PocketBase from [https://pocketbase.io/docs/](https://pocketbase.io/docs/)  
2. Run PocketBase:
   ```bash
   ./pocketbase serve
   ```
3. Open the dashboard at [http://127.0.0.1:8090/_/](http://127.0.0.1:8090/_/)  
4. Create a collection named **`dssishop`** with fields:
   - `name` → Text
   - `price` → Number (double)
   - `imageUrl` → Text (or URL)

5. Set **API Rules** for `List` and `View` to be public (leave blank).

---

## 🌱 Seed Data

To generate sample products (with Faker + Foodish API):

```bash
dart run script/generate.dart
```

This will insert fake products into your `dssishop` collection.

---

## ▶️ Run Flutter App

For Web:
```bash
flutter run -d chrome
```

For Mobile (emulator or device):
```bash
flutter run
```

---

## 🛠️ Technologies
- **Flutter** (Frontend)
- **PocketBase** (Backend)
- **Dart dotenv** (Environment variables)
- **Faker** (Fake data generator)
- **HTTP** (API calls)

---

## 📌 Notes
- If running on a real mobile device, replace `127.0.0.1` with your **local IP address** in `.env`.
- Do **not** commit `.env` or PocketBase credentials.
- Use `git pull` to sync with remote repo frequently.

---

## 📜 License
This project is for **educational purposes** only.
