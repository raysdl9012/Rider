# 🚀 iOS Project — Professional Architecture, Testing & Technologies

RideFuture is a native iOS application developed as a functional and advanced clone of the Uber ecosystem.
This project demonstrates professional expertise in building high‑complexity apps using **SwiftUI**, **Combine**, **Firebase**, **MapKit**, **Clean Architecture**, modern patterns, and software engineering best practices focused on scalability, maintainability, and testability.

## 🏷️ Technologies Used
[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2016+-blue.svg)](https://developer.apple.com/xcode/swiftui/)
[![Combine](https://img.shields.io/badge/Combine-Framework-blue.svg)](https://developer.apple.com/documentation/combine)
[![MapKit](https://img.shields.io/badge/MapKit-GPS-green.svg)](https://developer.apple.com/maps/)
[![CoreLocation](https://img.shields.io/badge/CoreLocation-Live%20Location-yellow.svg)](https://developer.apple.com/documentation/corelocation)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud-orange.svg)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

---

# ✨ Project Overview

RideFuture replicates much of Uber’s real user flow:

- User registration and authentication  
- Real-time maps with live location tracking  
- Intelligent search and destination selection  
- Ride request, confirmation, and full trip flow  
- Dynamic ride progress views  
- Persistent state (trips, history, ratings)  
- Simulated payment system integration  
- Robust architecture + reactive programming using Combine

This project demonstrates mastery of essential concepts in modern iOS development:

- **Clean Architecture (MVVM + Repository + DI)**  
- **Reactive state management with Combine and SwiftUI**  
- **Decoupled and testable service layers**  
- **Advanced MapKit usage (routes, overlays, dynamic zoom)**  
- **Firebase as a realtime backend**

---

## 📁 Project Structure

```
.
├── App
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── MainApp.swift
│
├── Presentation
│   ├── Modules
│   │   ├── Home
│   │   │   ├── HomeView.swift
│   │   │   ├── HomeViewModel.swift
│   │   │   └── HomeRouter.swift
│   │   └── ...
│   ├── Components
│   └── UI
│
├── Domain
│   ├── Entities
│   ├── UseCases
│   └── Repositories
│
├── Data
│   ├── RepositoryImplementation
│   ├── Network
│   │   ├── APIClient.swift
│   │   └── Endpoints.swift
│   ├── Database
│   └── Mappers
│
└── Resources
    ├── Assets.xcassets
    ├── Strings
    └── Fonts
```

---

## 🏗️ Professional Architecture

This project is built using a scalable, modular, and maintainable architecture designed for professional-level and complex applications.

### **🔹 MVVM + Repository Pattern**
- Clear separation of responsibilities  
- Presentation layer independent from business logic  
- Improved testability  

### **🔹 Dependency Injection**
- Enhances scalability  
- Enables easier testing  
- Reduces coupling  

### **🔹 Clean Architecture (Optional / Per Project Needs)**
- Well‑defined layers  
- Fully isolated domain  
- Ability to add independent frameworks

---

## 🛠️ Implemented Technologies

| Category | Technologies |
|----------|-------------|
| Language | Swift |
| UI | SwiftUI |
| Reactivity | Combine |
| Architecture | MVVM + Repository, Clean Architecture |
| Backend | Firebase / Firestore |
| Networking | URLSession / async‑await |
| Local Storage | UserDefaults / Keychain / FileManager |
| Design | Atomic Design / Component‑Driven UI |

---

## ⚙️ Technical Features

- Router‑based navigation  
- Advanced state management with Combine  
- Protocol‑oriented decoupled networking  
- Centralized dependency injection  
- Feature‑based modularization  
- Secure persistent storage access  
- Use of Task, async/await, and structured concurrency  

---

## 🧩 Code Standards

- Swift API Guidelines conventions  
- Layer‑based folder organization  
- Reusable UI components  
- Documentation comments `///`  
- Strong typing and removal of magic values  

---

## 🚀 Applied Best Practices

- SOLID Principles  
- DRY, KISS, YAGNI  
- Strict separation between business logic and UI  
- Safe error handling using `Result` and `throws`  
- Single‑responsibility for every file/class  

---

## 📚 Included Documentation

- Architecture guide  
- Project structure guide  
- UI design conventions  
- ViewModel conventions  
- Unit testing examples  

---

## 👨‍💻 Author

**Reinner Steven Daza Leiva — iOS Developer**

Specialized in:

- Swift / SwiftUI  
- Combine  
- Clean Architecture  
- Firebase  
- High‑performance mobile applications  
- Professional UI animations & design  
- Modern networking with async‑await  
- Automated testing  

**GitHub:** https://github.com/tu-usuario  
**LinkedIn:** https://linkedin.com/in/tu-perfil  

---

## 📝 License

This project is under the MIT License.  
You may use, modify, or improve it without restrictions.
