# Fintech Credit System

A fullstack fintech application with Credit/Loan features, Web Admin, and Mobile App.

## Project Structure

- **Backend**: NestJS (API Server)
- **Web Admin**: React + Vite (Dashboard)
- **Mobile**: Flutter (Android/iOS App)
- **Database**: PostgreSQL (Dockerized)

## Prerequisites

- [Node.js](https://nodejs.org/) (v16+)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Flutter SDK](https://flutter.dev/) (for mobile)

## Quick Start

## Quick Start

### 1. Start Database
**Database sekarang menggunakan SQLite**. Tidak perlu Docker. Database akan otomatis dibuat saat backend dijalankan.

### 2. Start Backend

```bash
cd backend
npm install
npm run start:dev
```
Server: http://localhost:3000

### 3. Start Web Admin

```bash
cd web-admin
npm install
npm run dev
```
Dashboard: http://localhost:5173

### 4. Start Mobile App

```bash
cd mobile
flutter pub get
flutter run
```

## Troubleshooting

- **Error: `Module not found: sqlite3`**
  - Jalankan `npm install sqlite3` di folder backend.
