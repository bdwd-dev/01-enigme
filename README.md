# L'Énigme

E-commerce bien-être adulte

## Structure

```
01-enigme/
├── backend/          # Express.js API (Port 3001)
│   ├── server.js
│   ├── package.json
│   └── db.json
├── web/              # React frontend (HTML + Babel standalone)
│   └── index.html
└── mobile/           # Flutter app
    └── lib/main.dart
```

## Démarrage

```bash
# Backend
cd 01-enigme/backend
npm install
npm start

# Web — Ouvrir 01-enigme/web/index.html dans un navigateur
# ou servir avec: npx serve 01-enigme/web

# Mobile
cd 01-enigme/mobile
flutter pub get
flutter run
```

## API

| Endpoint | Description |
|----------|-------------|
| GET /api/health | Health check |
| GET /api/stats | Statistiques |
