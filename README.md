# 📚 Boichokro – Free Book Exchange & Donation Platform

> **"Turn the books you've already read into new reads for someone else – for free, nearby, and safe."**

![Boichokro](https://github.com/zamansheikh/boichokro/raw/main/docs/assets/icon.png)

## 🚀 About Boichokro

Boichokro is a **community-driven Flutter application** that transforms the way people share books locally. Instead of letting finished books collect dust on shelves, Boichokro connects book lovers in your area to **exchange, donate, and discover** new reads—all for **free, safe, and verified**.

**Boichokro = "বই ছড়ানো" (Bengali: "Spread Books")**

### Core Features
- 📍 **Location-based discovery** – Find books within your radius
- 📱 **Phone-verified safety** – OTP authentication, ratings, and verified badges
- 🤝 **Exchange & Donate** – Two-way sharing: swap books or give them away
- 💬 **In-app chat** – Direct messaging with built-in safety features
- 🗺️ **Smart meetups** – Location sharing, public place suggestions, safety checklist
- ⭐ **Trust system** – Ratings, reviews, and community verification

---

## 🎯 User Personas

| Persona | Goal | Pain Point |
|--------|------|------------|
| **Donor** | Get rid of finished books, help others | No safe way to give away locally |
| **Seeker** | Find specific titles cheaply | Buying new is expensive |
| **Casual Browser** | Discover hidden gems nearby | No visibility of local libraries |
| **Community Builder** | Connect with fellow readers | Isolated from local book communities |

---

## 3. High-Level Feature Matrix

| Priority | Feature | MVP? |
|----------|--------|------|
| 1 | Register / Login (Phone + OTP) | Yes |
| 2 | Add a book (photo + title/author/condition) | Yes |
| 3 | Search by title, author, genre | Yes |
| 4 | Map + distance filter (radius slider) | Yes |
| 5 | Book detail + owner profile (rating, distance) | Yes |
| 6 | Request / Chat (in-app) | Yes |
| 7 | Exchange OR Donate flow | Yes |
| 8 | User rating & verification badge | Yes |
| 9 | Report / Block | Yes |
|10| Push notifications (request, chat) | Yes |
|11| Wishlist & “Notify when available” | No (v2) |
|12| Book clubs / meetups | No (v3) |

---

## 4. Screen Map (Bottom Navigation)

```
Home (Map + List toggle)
   └─ Search bar (global)
   └─ Filter chip row (Genre | Condition | Distance)
   
Library (My Books)
   └─ Tabs: Available | Requested | Past

Chat
   └─ Thread list → Chat room

Profile
   └─ Ratings | Verified badge | Settings
```

**Onboarding (3 slides):**  
1. “Give away books you loved”  
2. “Find hidden gems nearby”  
3. “Safe, verified hand-offs”

---

## 5. Detailed UX Flow

### A. Add a Book (3-step wizard)
1. **Snap cover** → Google ML Kit auto-fills Title/Author/ISBN  
2. **Condition picker** (Like New → Worn) + optional notes  
3. **Set action**:  
   - **Donate** (anyone can request)  
   - **Exchange** (only users with a book to swap)

### B. Search & Discovery
- **Map view** (Google Maps Flutter) pins with book cover thumbnails  
- **List view** with distance badge (`2.1 km`)  
- **Pull-to-refresh** + infinite scroll  
- Tap → **Book Card** → **Request**

### C. Request Flow
```
Seeker taps “Request”
└─ If Exchange → Seeker must select ONE book to offer
└─ Auto-message: “Hi! I’d love Paradoxical Sajid. Offering [Book X]”
Owner gets push → Accept / Decline / Counter-offer
```

### D. Meet-up Safety
- **In-app location share** (temporary 1-hour link)  
- **Public place suggestions** (cafés, libraries via Google Places)  
- **“I’m safe” check-in button** (both users mark after meet) → auto-rates

---

## 6. Data Model (Firebase Firestore)

```dart
collection: users
  uid
  phone
  name
  photoUrl
  ratingAvg
  totalSwaps
  verifiedBadge   // phone + 1 successful swap
  blockedBy[] 

collection: books
  bookId
  ownerId
  title
  author
  isbn (optional)
  coverUrl
  condition (0-4)
  genre[] 
  mode: "donate" | "exchange"
  exchangeWithBookId (null if donate)
  location: { lat, lng, geohash }
  status: "available" | "requested" | "completed"
  createdAt

collection: requests
  requestId
  bookId
  seekerId
  offeredBookId (null if donate)
  status: "pending" | "accepted" | "declined" | "completed"
  chatRoomId

collection: chatRooms
  participants[] 
  lastMessage
  updatedAt
```

**Geo queries** → use `geoflutterfire` or **Firestore GeoHash** + **Cloud Function** to return books within radius.

---

## 7. Safety & Trust Layer

| Mechanism | Implementation |
|---------|----------------|
| **Phone OTP login** | Firebase Auth → no fake accounts |
| **Verified badge** | After 1 successful swap + phone verified |
| **Rating after meet** | 1-5 stars + optional comment |
| **Report / Block** | Cloud Function removes book & bans after 3 reports |
| **Photo verification** | Optional selfie-with-book for high-value editions |
| **Meet-up timer** | Location link expires after 2 h |
| **Emergency SOS** | One-tap “Call local police” (uses device dialer) |

---

## 8. Tech Stack (Flutter + Firebase – zero backend code)

| Layer | Package |
|------|---------|
| UI | Flutter 3.24, Riverpod (state), GoRouter |
| Maps | google_maps_flutter + geolocator |
| Camera / ML | image_picker + google_ml_kit_text_recognition |
| Chat | firebase_messaging + cloud_functions (typing indicators) |
| Storage | firebase_storage (book covers) |
| Analytics | firebase_analytics + Mixpanel (viral coefficient) |
| CI/CD | Codemagic → TestFlight & Play Store |

---

## 9. Growth & Virality Hooks

1. **Referral bonus**: “Invite 3 friends → get ‘Early Bird’ badge + priority search”
2. **Weekly leader-board**: “Top 10 donors this week” → social share card
3. **Genre badges**: Collect 5 Sci-Fi swaps → “Sci-Fi Sage” sticker
4. **Local push**: “3 new donations within 1 km!” (geofence trigger)
5. **Instagram/TikTok share**: Auto-generate “I just swapped X for Y!” image

---

## 10. MVP Timeline (4 weeks)

| Week | Milestone |
|------|-----------|
| 1 | Auth + Profile + Add Book wizard |
| 2 | Map search + List + Geo queries |
| 3 | Request → Chat + Push notifications |
| 4 | Safety flow + Ratings + Polish + Beta launch (100 users) |

---

## 11. Monetization (post-MVP, non-intrusive)

| Model | How |
|------|-----|
| **Featured spot** | Pay ₹49 to pin book on map for 48 h |
| **Premium badge** | ₹99/mo → verified + unlimited requests |
| **Local bookstore ads** | “Buy new copy if not found” (affiliate) |

---

## 12. Bonus UI Ideas (copy-paste into Figma)

```text
Home Search Bar → autocomplete with recent swaps
Filter chips: Sci-Fi · Worn · <5km
Book card 2.0
Book card (horizontal):
 ┌──────────────────────┐
 │  [Cover]  Paradoxical│
 │           Sajid      │
 │  ★★★★☆  2.1 km      │
 │  Donate ∙ Available  │
 └──────────────────────┘
```

---

### TL;DR Checklist to Ship

- [ ] Firebase project + Phone Auth  
- [ ] `geoflutterfire` for radius search  
- [ ] ML Kit ISBN → auto-fill  
- [ ] In-app chat with typing + push  
- [ ] “Safe meet” checklist screen  
- [ ] Referral + share card  
- [ ] Beta → iterate on swap completion rate  

Build the **“Add → Search → Swap” loop first**; everything else is polish. Book lovers will spread it like wildfire once the first 50 successful swaps happen.  

Happy coding—Boichokro is going to be the **Goodreads meets OLX** for physical books! 📚🚀

---

## 📥 Installation & Setup

### Prerequisites
- Flutter 3.24+
- Dart 3.5+
- Firebase account
- Google Cloud Platform account
- Android Studio / Xcode for mobile development

### Clone & Setup
```bash
git clone https://github.com/zamansheikh/boichokro.git
cd boichokro
flutter pub get
flutter run
```

### Firebase Configuration
1. Create a Firebase project at [firebase.google.com](https://firebase.google.com)
2. Enable Authentication (Phone), Firestore, Storage, Messaging
3. Download `google-services.json` → place in `android/app/`
4. Download `GoogleService-Info.plist` → place in `ios/Runner/`

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) and [FIREBASE_MIGRATION.md](FIREBASE_MIGRATION.md) for detailed setup.

---

## 🏗️ Project Structure

```
boichokro/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── app_router.dart          # GoRouter navigation config
│   ├── firebase_options.dart    # Firebase initialization
│   ├── config/                  # App configuration
│   │   └── theme/
│   ├── core/                    # Core utilities
│   │   ├── services/            # Firebase, Geolocation, etc.
│   │   ├── providers/           # Riverpod state management
│   │   └── utils/
│   ├── features/                # Feature-based modules
│   │   ├── auth/               # Authentication (Phone OTP)
│   │   ├── home/               # Home screen (Map/List)
│   │   ├── library/            # My Books
│   │   ├── search/             # Search & Discovery
│   │   ├── book_detail/        # Book detail & requests
│   │   ├── chat/               # In-app messaging
│   │   ├── profile/            # User profile & ratings
│   │   ├── safety/             # Meetup safety features
│   │   └── settings/           # App settings
│   └── widgets/                 # Reusable widgets
├── assets/                      # Images, icons, animations
├── android/                     # Android-specific config
├── ios/                         # iOS-specific config
├── test/                        # Unit & widget tests
└── pubspec.yaml                 # Dependencies
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|------|------------|
| **Frontend** | Flutter 3.24, Riverpod (State), GoRouter |
| **Authentication** | Firebase Auth (Phone + OTP) |
| **Database** | Firestore (Real-time) |
| **Maps** | Google Maps Flutter, Geolocator |
| **Image Processing** | Google ML Kit (Text Recognition, Face Detection) |
| **Storage** | Firebase Storage |
| **Messaging** | Firebase Cloud Messaging (FCM) |
| **Analytics** | Firebase Analytics |
| **CI/CD** | Codemagic |

---

## 📱 Core Features Deep Dive

### 1. **Authentication (Phone + OTP)**
- Secure phone verification
- No social login required
- Firebase Authentication backend
- Rate limiting to prevent abuse

### 2. **Add a Book (3-Step Wizard)**
- Snap book cover → Google ML Kit auto-fills Title/Author/ISBN
- Select condition (Like New → Worn)
- Choose action: **Donate** (free for anyone) or **Exchange** (book swap)

### 3. **Map-Based Discovery**
- Real-time map showing available books nearby
- List view with distance badges (e.g., "2.1 km")
- Filter by genre, condition, distance radius
- Pull-to-refresh + infinite scroll

### 4. **Request & Chat System**
- Send request with optional message
- If **Exchange**, attach a book you're offering
- In-app chat with typing indicators
- Push notifications for new messages/requests

### 5. **Safety & Meetup Features**
- **Location sharing** (temporary, 1-hour expiry)
- **Public place suggestions** (cafés, libraries)
- **Safety checklist** before/after meetup
- **"I'm safe" check-in** → triggers auto-rating
- **Emergency SOS** button (links to local police)

### 6. **Trust & Verification**
- Phone-verified badge ✓
- "Verified Member" after 1 successful swap + positive rating
- 5-star rating system with comments
- Report/Block functionality
- 3-strike ban system for bad actors

---

## 🎨 Screenshots & UI

### Home Screen
- **Top**: Search bar + filter chips (Genre, Condition, Distance)
- **Middle**: Map toggle (Google Maps) or List view
- **Bottom**: Floating action button (+ Add Book)

### Book Detail
```
[Book Cover Image]
Title & Author
⭐ Rating (e.g., 4.5/5)
Condition Badge
2.1 km away
Owner info: [Avatar] Name | ★ Rating | "Verified"
[Request Button] [Save to Wishlist]
```

### Chat Screen
- Message list with timestamps
- Auto-detect exchange details ("I'm offering *Book X*")
- Safety checklist countdown timer
- "Meetup completed" → auto-rate flow

---

## 🔐 Security & Privacy

✅ **Phone verification** – No anonymous accounts  
✅ **HTTPS only** – All data encrypted in transit  
✅ **Firestore rules** – Strict access control per user  
✅ **Image optimization** – Compress before upload  
✅ **Rate limiting** – Prevent spam/brute force  
✅ **GDPR compliance** – Data export & deletion on demand  
✅ **No payment processing** – Eliminates financial fraud risk  

See [PRIVACY_POLICY.md](docs/privacy.html) and [TERMS_CONDITIONS.md](docs/terms.html).

---

## 📊 Growth Metrics

| Metric | Target |
|--------|--------|
| **DAU** | 1,000+ (6 months) |
| **Books exchanged/month** | 500+ |
| **Community members** | 5,000+ (first year) |
| **Verified members** | 80%+ |
| **Avg. rating** | 4.5+ stars |
| **Referral rate** | 20%+ |

---

## 🚀 Roadmap

### Phase 1: MVP (Current)
- ✅ Phone Auth + Profile
- ✅ Add Book wizard
- ✅ Map-based search
- ✅ Request + Chat
- ✅ Ratings & verification
- ✅ Safety features

### Phase 2: Engagement (Q2 2025)
- 📅 Wishlist & notifications
- 📅 Book clubs & group meetups
- 📅 Series/trilogy tracking
- 📅 Reading challenges

### Phase 3: Monetization (Q3 2025)
- 💰 Featured listings (₹49/48h)
- 💰 Premium membership (₹99/month)
- 💰 Local bookstore partnerships

### Phase 4: Scale (2026+)
- 🌍 Multi-language support
- 🌍 International expansion
- 🌍 AI recommendations
- 🌍 Offline mode

---

## 🤝 Contributing

We welcome contributions! Please check out our contribution guidelines:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** – see [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author & Credits

**Developer:** [Md. Shamsuzzaman](https://github.com/zamansheikh)  
**Company:** [ProgrammerNexus](https://github.com/programmernexus)  
**Email:** zaman6545@gmail.com

### Special Thanks
- 🙏 Flutter & Dart communities
- 🙏 Firebase team
- 🙏 Google ML Kit contributors
- 🙏 Early beta testers & community feedback

---

## 📞 Support & Contact

**Have questions? Found a bug?**

- 📧 **Email**: zaman6545@gmail.com
- 🐙 **GitHub Issues**: [boichokro/issues](https://github.com/zamansheikh/boichokro/issues)
- 💬 **Discussions**: [boichokro/discussions](https://github.com/zamansheikh/boichokro/discussions)

---

## 🌟 Show Your Support

If you find Boichokro useful, please:

⭐ Star this repository  
📢 Share with friends & book lovers  
💬 Provide feedback & suggestions  
🐛 Report bugs on GitHub Issues  
📝 Contribute code or documentation  

---

**Happy book sharing! 📚🚀**

*Boichokro: Because great books deserve great readers.*