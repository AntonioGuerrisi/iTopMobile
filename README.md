# iTop Mobile

Flutter mobile app for managing **tickets** and **assets** stored in [iTop](https://www.combodo.com/itop) by Combodo.

## About me
Hi, Antonio Guerrisi here and I’m the mind behind this project. I develop following the principles of Vibe Coding. For me, coding is as much about intuition and flow as it is about logic: it's about capturing an idea and turning it into reality while the energy is high.

Beyond this repository, I’m a creator constantly exploring new digital frontiers. You can see more of my work and philosophy over [my site](https://antonio.guerrisi.net).

If you find this project (or any of my work) interesting, please consider tapping the badge to <a href='https://ko-fi.com/J3J617WRZF' target='_blank'><img height='36' style='border:0px;height:24px;vertical-align:middle;' src='https://storage.ko-fi.com/cdn/kofi1.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>  
It’s a great way to fuel my next coding session and keep the vibes alive!

## Feedback and ideas
I built this because I needed it (or just thought it would be cool), but it’s a living thing. If you stumble upon a bug, have an idea that would make this 10x better, or just want to suggest a new feature, don’t be a stranger; open an Issue! I’m all ears (and usually looking for an excuse to open up the editor again).

## Features

### Authentication
- **Login** with the same iTop credentials (REST API v1.3)
- **Secure credential storage** with "Remember me" support (`flutter_secure_storage`)
- **Auto-login** when the app restarts if credentials are saved

### Tickets (UserRequest)
- **Ticket list** with time filters (last 3 months, 6 months, year, all) for better performance on large volumes
- **Status filters**: New, Assigned, Pending, Resolved, Closed
- **My tickets filter**: show only tickets assigned to the authenticated user
- **Search** by title, reference, or description
- **Full ticket detail** with three tabs: Details, Description, Logs
- **Ticket state management** with iTop transitions:
  - New → Assign / Resolve
  - Assigned → Pending / Resolve / Reassign
  - Pending → Reassign / Resolve
  - Resolved → Close / Reopen
- **Add public and private logs**
- **Resolve tickets** with service, subcategory, and resolution description
- **Pull-to-refresh** support in lists

### Assets (FunctionalCI)
- **Asset list** with type filtering (Server, VM, PC, Laptop, Printer, etc.)
- **Search** by name or description
- **Detailed asset screen** with sections: General, Hardware, Location
- Correct handling of class-specific fields

### Other
- **Light/dark theme** based on system settings
- **Settings screen** with user info and logout
- **3 bottom navigation tabs**: Tickets, Assets, Settings

## Architecture

The project uses the **Provider** pattern for state management.

```
lib/
├── main.dart                          # Entry point with MultiProvider
├── theme/
│   └── app_theme.dart                 # Theme, priority/status colors, icons
├── models/
│   ├── ticket.dart                    # Ticket model (UserRequest)
│   ├── ticket_log.dart                # Ticket log model (caselog)
│   └── asset.dart                     # Asset model (FunctionalCI)
├── services/
│   ├── itop_api_service.dart          # iTop REST API client
│   └── storage_service.dart           # Secure credential storage
├── providers/
│   ├── auth_provider.dart             # Authentication state + auto-login
│   ├── ticket_provider.dart           # Ticket state, filters, actions
│   └── asset_provider.dart            # Asset state and filters
├── screens/
│   ├── login_screen.dart              # Login screen
│   ├── home_screen.dart               # Shell with bottom navigation
│   ├── ticket_list_screen.dart        # Ticket list with filters
│   ├── ticket_detail_screen.dart      # Ticket detail (3 tabs)
│   ├── ticket_actions_screen.dart     # Ticket actions (log, status, resolve)
│   ├── asset_list_screen.dart         # Asset list with filters
│   ├── asset_detail_screen.dart       # Asset detail
│   └── settings_screen.dart           # Settings and logout
└── widgets/
    ├── ticket_card.dart               # Ticket card
    ├── asset_card.dart                # Asset card
    └── status_filter_chips.dart       # Status filter chips
```

## Configuration

The app is preconfigured to connect to `https://example.domain.tld`.
The server URL can be changed from the login screen.

### iTop API used

The app uses the iTop REST endpoint:
```
POST {server}/webservices/rest.php?version=1.3
```

Operations used:
- `core/get` — Retrieves objects (tickets, assets, users, services, subcategories)
- `core/update` — Updates objects (adds public/private logs)
- `core/apply_stimulus` — Applies ticket state transitions

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) >= 3.5.0
- Android Studio / Xcode for emulators
- An iTop instance with REST API enabled

## Installation and run

```bash
# Clone the repository
git clone <repository-url>
cd iTopMobile

# Install dependencies
flutter pub get

# Run on an emulator/device
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build iOS debug (macOS + Xcode only)
flutter build ios --debug --no-codesign

# Build iOS release (macOS + Xcode only)
flutter build ios --release

# Build IPA for distribution (macOS + Xcode only)
flutter build ipa --release
```

> **Note:** iOS builds (`flutter build ios` and `flutter build ipa`) require **macOS** with **Xcode** installed. You cannot build iOS from Windows or Linux.

## Main dependencies

| Package | Usage |
|---------|-------|
| `provider` | State management |
| `http` | REST API calls |
| `flutter_secure_storage` | Secure credential storage |
| `shared_preferences` | User preferences |
| `intl` | Date formatting and filters |
| `cached_network_image` | Image caching |
| `shimmer` | Loading skeletons |
| `pull_to_refresh_flutter3` | Pull-to-refresh lists |
| `flutter_slidable` | Slide actions on cards |

## iTop configuration

Make sure the iTop REST API is enabled:
1. Go to **Administration** > **Configuration**
2. Verify that `itop-rest-service` is enabled
3. Ensure the API user has the required permissions

## License

See the [LICENSE](LICENSE) file.
