# PayNote 📱💰

A modern mobile payment app for Rwanda with support for MTN and Airtel networks, featuring merchant payments and comprehensive transaction management.

## Features ✨

### 🏦 Multi-Network Support
- **MTN Mobile Money** integration
- **Airtel Money** support
- Automatic network detection
- Dynamic USSD code generation

### 💳 Payment Types
- **Regular Payments**: Person-to-person transfers with standard fees
- **Merchant Payments**: Business payments with 5-6 digit codes (fee-free)
- **Quick Pay**: Fast payments with category selection

### 📊 Analytics & Reports
- Transaction history with search and filters
- Category-based spending analytics
- Monthly spending trends
- Fee tracking and summaries
- Visual charts and insights

### 💾 Data Management
- Local SQLite database (mobile)
- Web storage support (browser)
- CSV and PDF export functionality
- Cross-platform data sync

## Screenshots 📸

*Coming soon - app screenshots will be added here*

## Technology Stack 🛠️

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Database**: SQLite (mobile) / SharedPreferences (web)
- **Charts**: FL Chart
- **Platform**: iOS, Android, Web, macOS

## Fee Structure 💸

### MTN Mobile Money Fees
| Amount Range | Fee (RWF) |
|--------------|-----------|
| 1 - 1,000 | 20 |
| 1,001 - 10,000 | 100 |
| 10,001 - 150,000 | 250 |
| 150,001 - 2,000,000 | 1,500 |
| 2,000,001 - 5,000,000 | 3,000 |
| 5,000,001 - 10,000,000 | 5,000 |

### Merchant Payments
- **Fee**: FREE (0 RWF)
- **Code Format**: 5-6 digit merchant codes
- **USSD**: `*182*8*1*[CODE]*[AMOUNT]#`

## Installation 🚀

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- iOS 12+ / Android 6.0+

### Setup
```bash
# Clone repository
git clone https://github.com/ollyfuse/paynote.git
cd paynote

# Install dependencies
flutter pub get

# Run on device/simulator
flutter run
