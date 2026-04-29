# 🚀 Resumefy

A modern, beautifully designed **Flutter resume builder app** that helps users create, manage, and showcase their professional profiles with ease.

---

## ✨ Features

* 🔐 **Authentication**

  * Firebase Email/Password login & signup
  * Secure session handling

* 👤 **Profile Management**

  * Personal details (name, email, headline, photo)
  * Edit and update anytime

* 🛠️ **Skills Section**

  * Add, view, and manage skills
  * Clean chip-based UI

* 💼 **Experience Timeline**

  * Add job roles, company, duration, and description
  * Elegant timeline design

* 🎓 **Education**

  * Add degrees, institutions, and years
  * Structured layout

* 🌟 **Goals & Interests**

  * Career goals and personal interests

* 🎨 **Modern UI**

  * Glassmorphism design
  * Smooth animations
  * Gradient-based theme

---

## 🧱 Tech Stack

* **Flutter** – UI framework
* **Riverpod** – State management
* **Firebase Auth** – Authentication
* **Cloud Firestore** – Database
* **GoRouter** – Navigation

---

## 📂 Project Structure

```
lib/
│
├── core/
│   ├── constants/        # Colors, typography
│   ├── routes/           # App routes
│
├── data/
│   ├── models/           # User, Experience, Education models
│
├── providers/            # Riverpod providers
│
├── presentation/
│   ├── auth/             # Login / Signup screens
│   ├── profile/          # Profile UI
│
├── widgets/              # Reusable UI components
│
└── main.dart
```

---

## ⚙️ Setup & Installation

### 1. Clone the repository

```bash
git clone https://github.com/your-username/resumefy.git
cd resumefy
```

---

### 2. Install dependencies

```bash
flutter pub get
```

---

### 3. Setup Firebase

* Go to Firebase Console
* Create a project
* Add Android app
* Download `google-services.json`

Place it inside:

```
android/app/
```

---

### 4. Run the app

```bash
flutter run
```

---

## 🔥 Key Highlights

* ⚡ Reactive UI with Riverpod
* 🧠 Clean architecture
* 🎯 Scalable and maintainable codebase
* 💎 Beautiful and modern UI design

---

## 🐞 Known Issues

* Logout race condition (fixed using proper provider lifecycle handling)
* Emulator performance warnings (safe to ignore)

---

## 📌 Future Improvements

* 📄 Resume PDF export
* 🌐 Shareable public profile link
* 🖼️ Image upload optimization
* 🌙 Dark/Light theme toggle

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the repo
2. Create a feature branch
3. Commit your changes
4. Push and open a PR

---

## 📄 License

This project is licensed under the MIT License.

---

## 👩‍💻 Author

**Sithara**
Flutter Developer

---

## ⭐ Support

If you like this project, please ⭐ the repo!

---
