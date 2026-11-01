Fitness AI Flutter Phase 1 Plan

What we are building (and what we are not)

This is not a Compose-to-Flutter conversion of already-implemented-android-kotlin-ui.md. That file is the product memory of the old Android app: gym-first logging, per-set reps/weight, session builder, history, progress charts, profile.

The implementation spec is flutter_conversion_UI_blueprint.md. The new app lives only in D:\Personal\MYPC\PROJECTS\PRODUCTS\flutter-apps\fitness_ai_ui. The Kotlin project and FastAPI contract stay untouched.

flowchart LR
FlutterApp[fitness_ai_ui]
SupabaseAuth[Supabase Auth]
FastAPI[FastAPI :8000]
FlutterApp -->|"sign in / session / refresh"| SupabaseAuth
FlutterApp -->|"Bearer access token"| FastAPI
FastAPI -->|"workouts / exercises / history / progress /auth/me"| FlutterApp

What changed vs the Android app (must follow in Flutter)





Data path: Android talked to Supabase PostgREST / Room tables (workout_logs, workout_sets, history_records, user_id in bodies). Flutter must never query those tables. All business data goes through FastAPI.



Auth: No guest accounts. Sign-in/sign-up are dedicated screens, not embedded in Profile. Email/password now; Google button present but disabled/unconfigured.



Workout model: No parent-level weight_kg. Sets own reps + weight_kg. One POST /api/v1/workout/log for quick-log or multi-exercise session. Never send user_id.



History: Session cards (date, exercise count, volume, vitals), entries expand to sets. Parent shows sets_count x total_reps, never parent weight. Delete session or single entry via FastAPI.



Dashboard: No Calendar strip. Stats come from fetched history pages and must be labeled as such, not "all-time" unless fully paginated. No unbounded PR N+1.



Phase 2 out: No Schedule, no AI Labs, no fake placeholders, no Google Calendar in Profile.

Current Flutter project is the default counter app (lib/main.dart, no extra packages). We replace it; we do not keep the demo.

Architecture in fitness_ai_ui

Feature-first layout from the blueprint:





lib/app/ — app.dart, router.dart, theme



lib/core/auth/ — Supabase session wrapper



lib/core/network/ — Dio client: read current access token per request, map 401/404/409/422/503



lib/core/errors/, widgets/, formatting/



lib/features/{auth,dashboard,exercises,workout,history,progress,profile}/

Packages: supabase_flutter, dio, flutter_riverpod, go_router, fl_chart. No duplicate token storage.

Config via --dart-define (never commit secrets):





SUPABASE_URL



SUPABASE_PUBLISHABLE_KEY



API_BASE_URL — local FastAPI is :8000. Android emulator must use http://10.0.2.2:8000; iOS simulator / desktop can use http://127.0.0.1:8000. Document both in README; do not hardcode one URL for all platforms.

401 handling: one Supabase refresh + retry; if refresh fails, clear session and route to Sign In.

Navigation and screens (Phase 1)

Unauthenticated: splash/session check → Sign In → Sign Up.

Authenticated shell (5 tabs): Dashboard, Log Workout, History, Progress, Profile. Bottom nav on phones; NavigationRail on wide layouts. Preserve tab when opening the exercise picker.

Shared UI states every slice: loading, empty, error+retry, offline (keep staged workout in memory; never claim save until 201), success.

Auth

Email/password only wired. Validation, show/hide password, loading, errors. Email-confirmation message if Supabase requires it. After session: GET /api/v1/auth/me. Username optional metadata; email is the reliable label.

Dashboard

Greeting from /auth/me. Primary Start Workout. Recent session + volume/session counts from history pages, scoped in copy. No calendar. PR showcase only if we reuse a small, deliberate progress fetch (or omit until later rather than N+1).

Log Workout

Exercise search → GET /api/v1/exercises (search, muscle, type, clear filters). Custom create → POST /api/v1/exercises (409 on duplicate). Per-set steppers (reps, weight ±2.5, direct kg input), add/remove sets, live volume + Epley 1RM on device. Session check-in: mood/energy/sleep 1–10, optional bodyweight, notes. Log this exercise (1 entry) and Save session (all staged entries) both hit POST /api/v1/workout/log once. Keep staged data on failure; clear + show API insights on success.

History

GET /api/v1/workout/history with days, exercise, muscle_group, limit/offset. Expand session → entries → sets. Delete with confirm: DELETE .../sessions/{id} and DELETE .../entries/{id}. Load more. CSV from fetched pages only, labeled as such.

Progress

Catalog picker + 30/90/365. GET /api/v1/workout/progress/{exercise}?days=. Chart points (weight; optional volume/1RM). Trend + 3 PR types. 404 = empty, not error.

Profile

Email, optional username, sign out (SDK + clear cache). kg canonical; optional local lbs display conversion only, convert back to kg before POST. No Google linking.

Implementation order (one slice at a time)





Shell + auth — theme, router, Riverpod, Dio, dart-define, Sign In/Up, session restore, /auth/me, tests.



Exercise catalog — picker used by Log Workout and Progress.



Workout logging — staged builder, one POST, insights.



History — list, expand, filters, pagination, deletes.



Progress + dashboard polish + profile units — charts, derived dashboard stats, sign-out.

After each slice: flutter analyze + widget/unit tests + loading/empty/error/success. Do not invent routes or JSON fields. Do not modify FastAPI.

Manual config you must supply before a live run





SUPABASE_URL and publishable/anon key



Confirm email confirmation on/off in that Supabase project



Which device you will run first (Android emulator vs iOS/desktop) so API_BASE_URL is 10.0.2.2 vs 127.0.0.1

Google OAuth client IDs are not needed for this pass.

Out of scope

Kotlin/Android repo changes, FastAPI contract changes, Calendar/AI Labs, guest mode, PostgREST table access, Google sign-in wiring, committing .env or service-role keys.