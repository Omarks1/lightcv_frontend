# CV Chatbot Flutter Frontend

## Setup

### Prerequisites
- Flutter SDK (3.10+)
- Node.js (for development tools)

### Configuration
1. Edit `lib/services/api_service.dart` 
2. Change `baseUrl` to your backend URL:
   ```dart
   static const String baseUrl = 'http://your-backend-url:5000';
   ```

## Development

### Local Development
```bash
# Install Flutter dependencies
flutter pub get

# Install Node.js tools (optional)
npm install

# Run development server
flutter run -d web-server --web-port=3000

# OR with public tunnel
npm run dev
```

### Access
- Local: http://localhost:3000
- Tunnel: Automatically generated public URL

## Docker Deployment

### Build & Run
```bash
# Build image
docker build -t cv-chatbot-frontend .

# Run container
docker run -d -p 80:80 cv-chatbot-frontend
```

### Access
- Frontend: http://localhost

## Production Build

### Static Files
```bash
# Build for production
flutter build web --release

# Files will be in: build/web/
# Deploy these to any web server
```

## Environment

### API Configuration
Update backend URL in:
- `lib/services/api_service.dart`

### CORS
Make sure your backend allows requests from your frontend domain.

## Structure
```
lib/
├── main.dart           # App entry point
├── models/
│   └── cv_data.dart   # Data models
└── services/
    └── api_service.dart # Backend communication
```

## Commands
- `flutter run -d web-server --web-port=3000` - Development
- `flutter build web --release` - Production build  
- `docker build -t cv-chatbot-frontend .` - Docker build
- `npm run dev` - Development with tunnel