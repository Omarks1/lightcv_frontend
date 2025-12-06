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

## Deployment Guide (GitHub Pages)

### First-Time Setup

1. **Build the web app**
```bash
   flutter build web --release --base-href "/lightcv_frontend/"
```

2. **Initialize git in the build folder**
```bash
   cd build/web
   git init
   git checkout -b master
```

3. **Connect to your GitHub repo**
```bash
   git remote add origin https://github.com/your-username/lightcv_frontend.git
```

4. **Commit and push**
```bash
   git add .
   git commit -m "Initial deploy"
   git push -f origin master:gh-pages
```

5. **Enable GitHub Pages**
   - Go to your repo on GitHub
   - Settings → Pages
   - Source: Deploy from a branch
   - Branch: gh-pages / root
   - Click Save

Live URL: `https://your-username.github.io/lightcv_frontend/`

---

### Future Deployments
```bash
flutter build web --release --base-href "/lightcv_frontend/"
cd build/web
git add .
git commit -m "Deploy"
git push -f origin master:gh-pages
```