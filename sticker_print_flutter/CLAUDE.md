# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sticker Print Flutter is a Windows/mobile app for printing certificate/calibration sticker labels fetched from an Odoo ERP backend. It connects to Odoo via XML-RPC, browses certificates linked to sale orders, and generates PDF labels for printing.

## Build & Run Commands

```bash
flutter pub get          # Install dependencies
flutter run -d windows   # Run on Windows (primary target)
flutter run              # Run on default device
flutter analyze          # Run linter (analysis_options.yaml)
flutter test             # Run tests
```

## Architecture

**State Management:** BLoC pattern using `flutter_bloc` for most screens. `PreviewScreen` still uses `provider`/`ConfigService` directly. Global blocs (SettingsBloc, ConnectivityBloc) are provided at app root in `main.dart`. Screen-specific blocs (StickerBloc) are created locally.

**Layers:**
- `lib/services/` - Low-level clients. `OdooClient` handles XML-RPC serialization/deserialization and all Odoo API calls. `ConfigService` handles SharedPreferences persistence.
- `lib/repositories/` - `OdooRepository` wraps OdooClient; `SettingsRepository` wraps `ConfigService`.
- `lib/blocs/` - BLoC classes organized by feature: `connectivity/`, `home/`, `settings/`, `sticker/`.
- `lib/models/` - Data classes: `AppConfig` (connection + field mappings), `Certificate` (label data), `JobOrder`.
- `lib/screens/` - UI screens: Home, Browser (split-panel cert list + live preview), Preview (manual label entry), Settings, CertificateList.
- `lib/widgets/` - PDF label layout widgets built with `pdf` package widgets (not Flutter widgets): `LabelStyleStandard`, `LabelStyle1` ("Tested"), `LabelStyle2` ("Calibrated"). A third `dime_marine` style is built inline in `BrowserScreen`.

**Odoo Integration:**
- Communication is XML-RPC via `http` + `xml` packages (no JSON-RPC).
- `AppConfig` holds configurable Odoo model names and field mappings (e.g., `modelCertificate: 'dm.certificate'`, `fieldSerial: 'serial_number'`). These are user-configurable in Settings so the app adapts to different Odoo installations.
- Authentication uses API key (stored as password field).

**PDF Label Generation:**
- Labels are built as `pdf` package widgets (not Flutter widgets) in `lib/widgets/`.
- Three label styles: `style_1` (LabelStyle1 - "Tested"), `style_2` (LabelStyle2 - "Calibrated"), `dime_marine` (inline FittedBox table layout).
- Default dimensions: 38×24mm (AppConfig default). Available sizes in UI: 28×12mm (Small), 30×18mm (Medium), 38×24mm (Large).
- `StickerState` carries full label config: `labelStyle`, `labelWidth`, `labelHeight`, `fontSize`, `showBorder`, `borderInset`, `contentPadding`, `lineGap`.
- Fonts for PDF are loaded from `C:/Windows/Fonts/arial.ttf` and `arialbd.ttf` — Windows-only dependency.
- Logo loaded from `assets/logo.png` via `rootBundle`.
- The `printing` package handles native print dialog; direct print to a named printer is supported if `defaultPrinter` is set in `AppConfig`.

**BrowserScreen layout:** Split panel — 35% left (certificate list with search, powered by `StickerBloc`) and 65% right (live `PdfPreview` widget + label configuration controls: style, size, sliders for borderInset/contentPadding/fontSize/lineGap, border toggle).

**PreviewScreen:** Manual label entry screen (not Odoo data). Has its own inline simple PDF label builder (not using the widget classes). Fields: serial, cert number, issue date, expiry date. Supports font size slider and border toggle.

## Key Patterns

- `AppConfig` is immutable with `copyWith`. Settings are persisted via SharedPreferences as JSON.
- `Certificate.fromOdoo()` uses dynamic field name mapping from config, not hardcoded Odoo field names.
- `Certificate` has computed getters: `shortCertNo` (last `/`-split segment), `formattedTestedDate`, `formattedIssueDate`, `formattedExpiryDate` (DD/MM/YYYY).
- `OdooRepository` must be initialized with `AppConfig` before use via `initialize()`.
- `StickerBloc` is scoped to `BrowserScreen` — created in `BlocProvider` at that screen's root.
