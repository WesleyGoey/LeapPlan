# ✈️ LeapPlan - Smart Travel Itinerary Planner

[![Swift](https://img.shields.io/badge/Swift-F54A2A?style=flat&logo=swift&logoColor=white)](https://developer.apple.com/swift/)
[![Platform](https://img.shields.io/badge/Apple-iOS%20%7C%20iPadOS%20%7C%20watchOS-000000?style=flat&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Firebase](https://img.shields.io/badge/Firebase-a08021?style=flat&logo=firebase&logoColor=ffcd34)](https://firebase.google.com/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM%20%2B%20Clean-3982CE?style=flat)](https://developer.apple.com/documentation/)

LeapPlan is a native iOS, iPadOS, and watchOS application designed to simplify holiday planning. The platform integrates comprehensive itinerary management, live route mapping, and an intelligent virtual travel assistant into a single unified multi-device ecosystem.

---

## 📌 Project Context & Metadata

| Attribute | Details |
| :--- | :--- |
| 🎓 Institution | Universitas Ciputra Surabaya |
| 🚀 Academic Timeline | Semester 4 - Mobile Application Development |
| 📅 Development Period | April 2026 - June 2026 |
| 💻 Platform | Native Swift (iOS, iPadOS, watchOS) |

---

## 🚀 Technical Features & Logic

### 🔄 Multi-Device Synchronization
- Cross-Device Continuity: Built using MVVM + Clean Architecture, implementing native wireless connectivity to sync travel data seamlessly between iPhone, iPad, and Apple Watch targets.
- watchOS Companion App: Engineered a dedicated wrist interface for quick on-the-go access to monitor active trips, view micro-travel maps, and reorder destinations instantly.

### 🗺️ Routing & Location Intelligence
- MapKit Integration: Implemented MapKit routing logic to process live location searches, render visual route paths, and calculate precise travel duration estimations between checkpoints.
- Foursquare Places API: Hooked into remote location discovery endpoints to stream real-world Point of Interest (POI) data, powering an engine that generates smart, randomized itinerary recommendations.

### 🤖 AI Integration & System Logic
- Grok API Chatbot: Integrated a dedicated virtual travel assistant using the Groq API to handle interactive, context-aware Q&A regarding custom trip details and travel advice.
- Smart Trip CRUD: Developed an automated scheduler that tracks real-time dates to categorize travel plans into Ongoing, Upcoming, and Past lists.
- Binary Media Optimization: Utilized Cloud Firestore paired with custom Base64 image encoding algorithms to optimize media upload payloads and reduce database storage overhead.

---

## 💻 Tech Stack

- Language: Swift
- SDKs: iOS, iPadOS, watchOS Companion SDK
- Architecture: MVVM + Clean Architecture
- Core Frameworks: MapKit, CoreOS Connectivity
- Database & Cloud: Google Cloud Firestore
- Remote APIs: Foursquare Places API, Grok AI API
