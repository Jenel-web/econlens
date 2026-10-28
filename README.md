# EconLens PH

> Turning economic news into plain-language, household-level advice for everyday Filipinos.

![Status](https://img.shields.io/badge/status-work%20in%20progress-orange)
![Backend](https://img.shields.io/badge/backend-FastAPI-009688)
![Mobile](https://img.shields.io/badge/mobile-Flutter-02569B)
![AI](https://img.shields.io/badge/AI-Gemini-8E75B2)

---

## ⚠️ Project status: ongoing, not production-ready

**EconLens is an active work in progress.** The core idea works as a prototype, but the project is still being shaped, and not only technically. There are open, unresolved questions about **what the app should actually be** and **how it can genuinely benefit its users**:

- Is a feed of AI-analyzed news the most useful form, or would users get more from a personal "how much more will I spend this month?" view?
- How should the app handle uncertainty, so it never invents peso figures that sound precise but aren't?
- Who is the primary user: a commuter, a household budget-keeper, a small business owner? Each needs different information.
- What should trigger a notification, and what would make the app something people open daily rather than once?
- How can the output be trusted and verified, given it is AI-generated?

Because of these open questions, expect the scope, the schema, the stack and even the name (it currently appears as *EconLens*, *EconImpact PH* and *EcoNews PH* in different places) to change. The project is being reconsidered and may be rebuilt. See [Known issues](#known-issues) and [Roadmap](#roadmap).

---

## What is EconLens?

Economic news is written for economists. A headline like *"BSP holds policy rate as inflation eases"* doesn't tell a jeepney commuter or a market vendor what it means for their week.

EconLens takes English-language economic news about the Philippines and uses an AI model (Google Gemini) to rewrite it **in Tagalog, from the "common person's" perspective**, answering one question:

> *"How much more will the average Filipino spend on basic needs because of this news?"*

Each article is turned into a short structured explainer: what happened, how it affects us, an estimated budget impact, which sectors are affected, practical advice, and a severity level (low / medium / high).

### The Five Pillars (plus food)

Every analysis checks the impact on household essentials:

| Pillar | Examples |
|---|---|
| Fuel and gas | Jeepney fares, LPG tanks |
| Electricity | Monthly bills, appliance usage |
| Water | Basic utility cost |
| Transport | Commuting costs, surcharges |
| Connectivity | Prepaid load, fiber |
| Food and groceries | Rice, basic commodities, wet-market prices |

### Severity logic

| Level | Meaning |
|---|---|
| 🟢 Low | Under ₱500/month on a household budget |
| 🟡 Medium | ₱500 to ₱2,000/month |
| 🔴 High | Over ₱2,000/month, or affects several pillars at once |

### Design principles (from [`agents/skills.md`](agents/skills.md))

- **Empathetic, neighborly tone**, no banking jargon.
- **No hallucination**: if an article lacks the detail to estimate a price change, the impact should be stated as "uncertain", not made up.
- **Never blame the user's finances.** Give practical advice instead ("consider carpooling", "limit appliance use at peak hours").
- **Accessible**: readable fonts and contrast for older users and low-end devices; bullet points over long paragraphs.

---

## How it works

```
 NewsAPI ──► keyword filter ──► dedupe by URL ──► Supabase `articles`
                                                        │
                                                        ▼
                                      Gemini (Tagalog, strict JSON)
                                                        │
                                                        ▼
                                           Supabase `ai_analysis`
                                                        │
                                                        ▼
                                          Flutter mobile app (UI)
```

1. **Fetch**: pulls up to 100 recent articles from NewsAPI using a Philippines-focused economic query (BSP, inflation, fuel price, peso, agriculture, interest rate, and so on).
2. **Filter**: keeps articles whose title or description contains an economic keyword.
3. **Deduplicate**: skips articles whose `source_url` already exists (exact URL match only).
4. **Store**: saves new articles to the `articles` table.
5. **Analyze**: sends each new article to Gemini (`gemini-2.5-flash`) with a Tagalog system prompt and requests strict JSON.
6. **Persist**: validates the response and saves it to `ai_analysis`, linked to the article by foreign key, with a Philippine-time (UTC+8) `generated_at`.

### AI output contract

Gemini must return exactly this JSON, entirely in Tagalog:

```json
{
  "ano_ang_nangyari": "One-line summary of the news",
  "paano_ito_makakaapekto_satin": "Direct economic impact on regular citizens",
  "advice": "Practical advice (praktikal na payo)",
  "tinatantyang_epekto_sa_budget": "Estimated effect on a household budget",
  "apektadong_larangan": "Industries or fields affected",
  "severity_level": "low | medium | high"
}
```

---

## Tech stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter (Dart SDK ^3.11), `go_router`, `flutter_riverpod`, `http`, `google_fonts`, `intl` |
| Backend | Python 3.13, FastAPI, Uvicorn, `httpx`, Pydantic |
| Database | Supabase (PostgreSQL) via the `supabase` Python client |
| AI | Google Gemini via the `google-genai` SDK |
| News source | [NewsAPI](https://newsapi.org/) |

> **Note:** some older docs and comments in the repo mention Spring Boot / MySQL. That was an earlier plan. The current backend is **FastAPI + Supabase**. See [Known issues](#known-issues).

---

## Project structure

```
newApp/
├── agents/
│   ├── agents.md              # Project goals and rules for AI assistants
│   └── skills.md              # AI behavior spec: pillars, severity, tone, JSON format
├── backend/
│   ├── app/
│   │   ├── main.py            # FastAPI app, CORS, /health
│   │   ├── api/news.py        # POST /api/v1/fetch, POST /api/v1/analyze
│   │   ├── core/              # config.py (env vars), database.py (Supabase client)
│   │   ├── models/            # Pydantic schemas: Article, AIAnalysis
│   │   └── services/
│   │       ├── news_service.py   # NewsAPI fetch, filter, dedupe, store
│   │       └── ai_service.py     # Gemini analysis and persistence
│   ├── rebuild_ai_analysis.sql   # Drops and recreates the ai_analysis table
│   ├── check_connect.py, test_supabase.py, test_gemini.py, list_models.py
│   └── debug_ai.py, process_remaining.py   # ad-hoc helper scripts
├── mobile/                    # Flutter app
│   └── lib/
│       ├── main.dart
│       ├── core/              # router, theme, constants
│       ├── data/              # API client, models
│       ├── domain/            # entities
│       └── presentation/      # splash, login, home, article, settings, notifications, about
├── supabase/migrations/       # (currently empty)
└── prompts/                   # (currently empty)
```

---

## Current state: what works and what doesn't

### ✅ Working (as a prototype)

- FastAPI server starts; `GET /` and `GET /health` respond.
- News ingestion pipeline: fetch, filter, dedupe and store (`POST /api/v1/fetch`).
- Gemini analysis pipeline with JSON parsing and validation (`POST /api/v1/analyze`, and automatically after `/fetch`).
- Flutter app builds and runs (verified on Chrome). It has splash, login, home, article detail, settings, notifications and about screens, plus a Material theme and routing.

### 🚧 Not working or not built yet

- **The mobile app is not connected to the backend.** The home screen displays hardcoded dummy articles. Nothing calls the API.
- **There are no read endpoints.** The backend has no `GET /api/v1/news` or `GET /api/v1/news/{id}`, but the Flutter API client expects them.
- **The Flutter models don't match the real data.** They use integer ids and fields like `affectedCountries`, while the database uses UUIDs and the Tagalog `ai_analysis` fields.
- **Login, settings and notifications are UI-only.** There is no real auth, `user_preferences`, or push notifications.
- **No `articles` table SQL.** Only `ai_analysis` has a SQL file; the `supabase/migrations/` folder is empty.
- **No `requirements.txt`.** Python dependencies are not pinned or listed.
- **The "uncertain" rule isn't enforced.** The spec says the AI should say "uncertain" when it lacks detail, but the prompt in `ai_service.py` doesn't enforce it.
- **No tests** beyond a placeholder Flutter widget test and ad-hoc connection scripts.

---

## Known issues

1. **Conceptual:** the product direction is not settled (see the status section above).
2. **Inconsistent naming:** *EconLens*, *EconImpact PH*, *EcoNews PH*.
3. **Contradictory docs:** [`agents/agents.md`](agents/agents.md) says both "Flutter + Spring Boot" and "Python + FastAPI"; comments in the Dart code and the env template still reference Spring Boot, MySQL and an admin login.
4. **Port mismatch:** the Flutter constants point to `:8080`, the dev check screen to `:8000`, and the FastAPI app runs on whichever port you give Uvicorn (examples use `8000`).
5. **Database availability:** the Supabase project referenced by the author's `.env` could not be resolved when last checked, so it may have been deleted or paused. You will need your own Supabase project.
6. **Secrets hygiene:** `.env` is git-ignored, but its history shows it was touched in several commits. If real keys were ever committed, **rotate them**.
7. **Repo hygiene:** `__pycache__/*.pyc` files are tracked; helper scripts are loose in `backend/`; one script hardcodes an absolute Windows path.
8. **Backend efficiency:** deduplication makes one query per article; Gemini calls are synchronous inside async code with a fixed 4-second sleep (a free-tier rate-limit workaround).
9. **Loose CORS:** `allow_origins=["*"]` is for development only.
10. **AI reliability:** estimated peso impacts are AI-generated and unverified. They are **not financial advice**.

---

## Getting started

> These steps get the prototype running locally. Since the project is in flux, details may change.

### Prerequisites

- Python 3.13
- Flutter SDK (Dart ^3.11)
- A [Supabase](https://supabase.com/) project
- A [NewsAPI](https://newsapi.org/) key
- A [Gemini API](https://aistudio.google.com/app/apikey) key

### 1. Environment variables

Create a `.env` file in the project root (it is git-ignored; **never commit it**):

```env
SUPABASE_URL=https://<your-project>.supabase.co
SUPABASE_KEY=<your Supabase key>
NEWSAPI_KEY=<your NewsAPI key>
GEMINI_API_KEY=<your Gemini key>
```

### 2. Database

In the Supabase SQL editor, create an `articles` table with at least `id` (UUID, primary key), `title`, `source`, `source_url` (unique), `published_at`, `raw_content` and `created_at`. Then run [`backend/rebuild_ai_analysis.sql`](backend/rebuild_ai_analysis.sql) to create `ai_analysis`.

> `rebuild_ai_analysis.sql` begins with `DROP TABLE IF EXISTS`. It deletes any existing analyses.

### 3. Backend

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate            # Windows (use source .venv/bin/activate elsewhere)
pip install fastapi "uvicorn[standard]" httpx python-dotenv supabase google-genai pydantic
python -m uvicorn app.main:app --reload --port 8000
```

- Health check: <http://127.0.0.1:8000/health>
- Interactive API docs: <http://127.0.0.1:8000/docs>

Run the pipeline:

```bash
curl -X POST http://127.0.0.1:8000/api/v1/fetch      # fetch, store and analyze new articles
curl -X POST http://127.0.0.1:8000/api/v1/analyze    # backfill analysis for unanalyzed articles
```

### 4. Mobile app

```bash
cd mobile
flutter pub get
flutter run -d chrome        # or: flutter run -d windows / an Android emulator
```

The app currently shows dummy data regardless of whether the backend is running.

---

## API reference (current)

| Method | Path | Description |
|---|---|---|
| GET | `/` | Service status |
| GET | `/health` | Health check (status, version, environment) |
| POST | `/api/v1/fetch` | Fetch from NewsAPI, filter, dedupe, store, then analyze new articles |
| POST | `/api/v1/analyze` | Run AI analysis on articles that don't have one yet |

**Not yet implemented:** `GET /api/v1/news`, `GET /api/v1/news/{id}`, preferences and notification endpoints.

---

## Roadmap

**Decide first (concept)**
- [ ] Define the primary user and their top three needs
- [ ] Decide the core experience (news feed vs. personal budget impact vs. alerts)
- [ ] Decide the stack and the final name; update all docs to match
- [ ] Define how uncertainty and sources are shown to build trust

**Then build**
- [ ] Rotate keys; clean `.gitignore` (`.env`, `*.pyc`); add `requirements.txt`
- [ ] Write SQL migrations for `articles`, `ai_analysis` and `user_preferences`
- [ ] Add read endpoints (`GET /api/v1/news`, `/news/{id}`) returning article plus analysis
- [ ] Align Flutter models with the real schema; replace dummy data with live API data
- [ ] Severity color coding (red / yellow / green), bullet-point analysis, accessibility pass
- [ ] Enforce the "uncertain, don't invent numbers" rule in the prompt and validate it
- [ ] Real authentication and user preferences
- [ ] Push notifications filtered by `severity_level`
- [ ] Scheduled fetching (instead of manual `POST /fetch`), batching, and proper async Gemini calls
- [ ] Automated tests (backend and Flutter)

---

## Disclaimer

EconLens produces **AI-generated analysis for general information only**. Figures and advice are estimates, may be wrong or out of date, and are **not financial advice**. Verify important decisions against primary sources such as the Bangko Sentral ng Pilipinas, the Philippine Statistics Authority and the Department of Energy.

---

## Author

Mark Jenel Cortas, an IT student at the Polytechnic University of the Philippines.

*Built as a learning project. Feedback and ideas on how to make this genuinely useful to Filipino households are very welcome.*
