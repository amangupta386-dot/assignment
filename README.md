# DSA Prep Coach Monorepo

This repository contains:
- `apps/api`: Node.js + Express + PostgreSQL backend
- `apps/mobile`: Flutter app using BLoC

## 1) Backend Setup (`apps/api`)

### Prerequisites
- Node.js 18+
- PostgreSQL 14+

### Steps
1. Copy `.env.example` to `.env` in `apps/api`.
2. Update `DATABASE_URL`.
3. Install deps:
   - `cd apps/api`
   - `npm install`
4. Sync DB:
   - `npm run db:sync`
5. Optional seed:
   - `npm run seed`
6. Run API:
   - `npm run dev`

API base URL: `http://localhost:4000/api`

## 2) Mobile Setup (`apps/mobile`)

### Prerequisites
- Flutter stable (3.22+)

### Steps
1. `cd apps/mobile`
2. `flutter pub get`
3. Confirm backend URL in `lib/core/utils/app_config.dart`
4. Run app:
   - `flutter run`

## Implemented Features
- Problem logging
- Stage-based spaced revision
- Today due revisions (including overdue)
- Revision complete/fail flow
- Weekly goal setup
- Weekday/weekend plan generation
- Daily plan task completion
- Weekly analytics and pattern insights
- Local notification service scaffold

## API Endpoints
- `POST /api/problems`
- `GET /api/problems`
- `GET /api/revisions/today`
- `POST /api/revisions/:problemId/complete`
- `POST /api/revisions/:problemId/fail`
- `POST /api/plans/generate-week`
- `GET /api/plans/today`
- `POST /api/plans/today/mark-done`
- `POST /api/goals/weekly`
- `GET /api/goals/weekly/current`
- `GET /api/analytics/weekly`
- `GET /api/analytics/patterns`

## Notes
- Current backend uses a demo auth middleware (`userId=1`) for MVP speed.
- Migrations are replaced by `sequelize.sync()` for fast bootstrap.
- Add JWT auth and formal Sequelize migrations next for production hardening.
