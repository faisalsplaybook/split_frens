# Split Frens 💸

A Flutter expense-splitting app for friend groups, hangouts, and trips. Track shared expenses, calculate who owes whom, manage settlements, and share summaries — all from one place.

## Main Features

- **Create Hangouts** — Group expenses by event (dinner, trip, outing)
- **Add People** — Add friends as participants with duplicate-name protection
- **Add Expenses** — Log who paid, select participants, equal split calculation
- **Split Results** — See individual balances (who gets back / who owes)
- **Settlements** — View and mark settlements as paid/unpaid
- **Currency Converter** — Convert foreign expenses via ExchangeRate-API (travel mode)
- **Share Summary** — Share a formatted text summary via any app (WhatsApp, etc.)
- **History** — View completed/archived hangouts
- **Settings** — Configure default currency and app preferences
- **Persistent Storage** — All data saved locally with Hive

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Dart |
| UI Framework | Flutter + Material 3 |
| State Management | Riverpod |
| Navigation | go_router |
| Local Storage | Hive + SharedPreferences |
| API Client | Dio (REST) |
| Currency API | [ExchangeRate-API](https://www.exchangerate-api.com/) (free tier) |
| Sharing | share_plus |
| ID Generation | uuid |
| Date Formatting | intl |

## Setup Instructions

### Prerequisites
- Flutter SDK (3.11+)
- Dart SDK (3.11+)
- Android Studio or VS Code with Flutter extensions

### Clone & Run

```bash
git clone https://github.com/faisalsplaybook/split_frens.git
cd split_frens
flutter pub get
flutter run
```

### API Setup (Currency Conversion)

The currency converter uses [ExchangeRate-API](https://www.exchangerate-api.com/) free tier.

1. Visit [exchangerate-api.com](https://www.exchangerate-api.com/) and sign up for a free API key
2. The free tier provides 1,500 requests/month
3. The app uses the open endpoint (`https://open.er-api.com/v6/latest/{currency}`) which does **not** require an API key
4. No configuration needed — it works out of the box

## How to Run the App

```bash
# Development
flutter run

# Run tests
flutter test

# Analyze code
dart analyze
```

## Folder Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants/                     # App-wide constants
│   │   ├── app_constants.dart
│   │   ├── currency_constants.dart
│   │   └── expense_categories.dart
│   ├── errors/
│   │   └── app_exception.dart
│   ├── router/
│   │   └── app_router.dart            # go_router configuration
│   ├── theme/
│   │   └── app_theme.dart             # Material 3 theme
│   └── utils/
│       ├── date_formatter.dart
│       ├── money_formatter.dart
│       ├── summary_generator.dart     # Shared text summary builder
│       └── validators.dart            # Form validation logic
├── data/
│   └── dummy_data.dart
├── features/
│   ├── currency/                      # Currency conversion feature
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/              # Dio-based API service
│   │   └── presentation/
│   │       ├── providers/             # Riverpod state
│   │       └── screens/
│   ├── hangouts/                      # Core hangout/expense feature
│   │   ├── data/
│   │   │   ├── models/               # Hangout, Expense, Person, Settlement, SplitType
│   │   │   ├── repositories/
│   │   │   └── services/             # LocalStorage (Hive), SplitCalculator
│   │   └── presentation/
│   │       ├── providers/            # Riverpod notifiers
│   │       ├── screens/              # All screens (8 total)
│   │       └── widgets/              # Extracted reusable widgets
│   ├── settings/                     # Settings feature
│   │   ├── data/
│   │   └── presentation/
│   └── splash/                       # Splash/loading screen
├── screens/
│   └── home_screen.dart              # Main home screen
└── shared/
    └── widgets/                      # App-wide reusable widgets
        ├── app_button.dart
        ├── app_dropdown.dart
        ├── app_scaffold.dart
        ├── app_text_field.dart
        ├── confirmation_dialog.dart
        ├── empty_state.dart
        ├── error_state.dart
        └── loading_view.dart
```

## Known Limitations

- **Equal split only** — Phase 1 only supports equal splitting among participants
- **No authentication** — All data is local, no cloud sync or user accounts
- **Free API tier** — Currency conversion limited to 1,500 requests/month
- **No dark mode** — Light theme only (dark mode planned for V2)
- **Offline-only** — No real-time sync between devices

## Future Improvements

- Unequal / percentage-based splits
- Dark mode theme
- Firebase Auth + Firestore cloud sync
- Push notifications for settlement reminders
- Expense categories with icons
- Receipt photo attachments
- Export to CSV/PDF
- Multi-language support
