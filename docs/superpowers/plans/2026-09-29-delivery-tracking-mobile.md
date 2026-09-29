# Mobile Delivery Tracking App — Implementation Plan

> **For Agentic Implementers:**
> This is the authoritative, step-by-step implementation plan for the **Flutter Delivery Tracking Mobile Application** (`delivery_tracker`), located in `mobile/`.
> This plan incorporates all findings, architectural corrections, and dependency guidelines from the **Codex Astra** senior architectural review.
>
> **Mandatory Pre-Flight:**
> Before writing any code, you **MUST read and follow**:
> 1. `rules/mobile_rules.md` — Git branching, PR standards, and commit rules.
> 2. `references/mobile_reference.md` — Clean code limits, testing policies, and architectural standards.
> 3. `task_requirements.pdf` — Core business requirements.
>
> **Non-Negotiable Engineering Guardrails:**
> - **File Size Limit**: No Dart file may exceed **150 to 200 lines**. Decompose large widgets into small, modular sub-widgets.
> - **Comprehensive Tests**: Write both **Unit Tests** (`bloc_test`, `mocktail`) and **Widget Tests** (`WidgetTester`) for every feature.
> - **PR Language**: All Pull Request titles, descriptions, and comments must be strictly in **English** with a Senior Mobile Engineer tone (zero AI clichés).
> - **Crucial Screenshot Rule 📸**: Before opening or finalizing any PR for a feature with UI, you **must notify the user** to take real app screenshots to embed into the PR description.

---

## Architecture & Directory Layout

The application strictly implements Feature-First Clean Architecture:
```
mobile/lib/
├── config/
│   ├── routing/
│   │   ├── app_routes.dart               # Route names
│   │   ├── route_generator.dart          # onGenerateRoute
│   │   └── routing_extensions.dart       # context.pushNamed / pop
│   └── theme/
│       ├── colors.dart                   # Delivery color palette
│       └── app_theme.dart                # Material 3 theme data
├── core/
│   ├── components/
│   │   ├── app_text_field.dart           # Custom form input with error state
│   │   ├── custom_elevated_button.dart   # Primary button with loading spinner
│   │   └── custom_text_button.dart       # Ghost button
│   ├── database/
│   │   ├── hive_boxes.dart               # Typed box accessors (deliveries_box, pending_actions_box)
│   │   ├── adapters/
│   │   │   ├── delivery_adapter.dart     # Hand-written Hive TypeAdapter for DeliveryEntity
│   │   │   └── delivery_action_adapter.dart # Hand-written Hive TypeAdapter for DeliveryAction
│   │   └── local_storage_service.dart    # Hive lifecycle & box initialization
│   ├── di/
│   │   ├── di.dart                       # GetIt configureDependencies entrypoint
│   │   └── di.config.dart                # Generated injectable output
│   ├── extensions/
│   │   └── context_extensions.dart       # context.theme, context.colors, context.tr
│   ├── general_cubits/
│   │   ├── locale_cubit.dart             # Reactive language toggle (en/ar)
│   │   └── locale_state.dart
│   ├── helpers/
│   │   ├── dialog_utils.dart             # Native alert & confirmation dialogs
│   │   ├── toast_utils.dart              # SnackBar / Toast alerts
│   │   └── spacing.dart                  # verticalSpace / horizontalSpace
│   ├── l10n/
│   │   ├── app_ar.arb                    # Arabic localization strings
│   │   ├── app_en.arb                    # English localization strings
│   │   └── generated/                    # Generated AppLocalizations (synthetic-package: false)
│   ├── network/
│   │   ├── api_results.dart              # ApiResult<T> (Success, Error, NetworkFailure)
│   │   ├── api_services.dart             # Retrofit client for delivery endpoints
│   │   ├── external_modules.dart         # DI providers for Dio, Connectivity, SharedPreferences
│   │   ├── failures.dart                 # TransientFailure vs PermanentFailure (with code & message)
│   │   └── network_constants.dart        # Endpoints, timeouts, dynamic BASE_URL via --dart-define
│   ├── services/
│   │   ├── connectivity_service.dart     # Reactive stream (List<ConnectivityResult> v3+ and active ping)
│   │   └── sync_manager.dart             # Sequential queue worker with Mutex & backoff
│   └── utils/
│       ├── constants.dart                # Storage keys, limits
│       └── enums.dart                    # DeliveryStatus, SyncStatus, DeliveryActionType, FailureReason
└── features/
    └── delivery/
        ├── data_sources/
        │   ├── mapper/
        │   │   ├── to_dto_mapper.dart        # Entity -> DTO mappers
        │   │   └── to_entity_mapper.dart     # DTO -> Entity mappers
        │   ├── models/
        │   │   ├── request/
        │   │   │   ├── complete_delivery_request_dto.dart
        │   │   │   └── fail_delivery_request_dto.dart
        │   │   └── response/
        │   │       └── delivery_response_dto.dart
        │   ├── repositories/
        │   │   └── delivery_repo_impl.dart   # Offline-first repository implementing DeliveryRepository
        │   └── sources/
        │       ├── local/
        │       │   ├── delivery_local_ds.dart
        │       │   └── delivery_local_ds_impl.dart
        │       └── remote/
        │           ├── delivery_remote_ds.dart
        │           └── delivery_remote_ds_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   ├── request/
        │   │   │   ├── complete_delivery_request_entity.dart
        │   │   │   └── fail_delivery_request_entity.dart
        │   │   └── response/
        │   │       ├── delivery_entity.dart
        │   │       └── delivery_action.dart
        │   ├── repositories/
        │   │   └── delivery_repo.dart
        │   └── use_case/
        │       ├── get_deliveries_use_case.dart     # invoke() returning ApiResult
        │       ├── get_delivery_by_id_use_case.dart # invoke() returning ApiResult
        │       ├── complete_delivery_use_case.dart  # invoke() returning ApiResult
        │       ├── fail_delivery_use_case.dart      # invoke() returning ApiResult
        │       └── retry_action_use_case.dart       # invoke() returning ApiResult
        └── presentation/
            ├── manager/
            │   └── cubit/
            │       ├── delivery_cubit.dart
            │       └── delivery_state.dart
            ├── pages/
            │   ├── deliveries_list_screen.dart
            │   └── delivery_details_screen.dart
            └── widgets/
                ├── delivery_card.dart
                ├── sync_status_badge.dart
                ├── complete_delivery_sheet.dart
                └── fail_delivery_sheet.dart
```

---

### Task 0: Foundations, Dependencies & Platform Configuration

**Goal:** Establish clean compilation, correct Android/iOS network permissions, and base dependency tree.

### Files to Create / Modify:
- Modify: `mobile/pubspec.yaml`
- Create: `mobile/l10n.yaml`
- Modify: `mobile/analysis_options.yaml`
- Modify: `mobile/android/app/src/main/AndroidManifest.xml`
- Create: `mobile/android/app/src/main/res/xml/network_security_config.xml`
- Modify: `mobile/ios/Runner/Info.plist`

- [ ] **Step 1: Update `mobile/pubspec.yaml` with production and dev dependencies**
  - Add: `flutter_bloc: ^9.1.1`, `equatable: ^2.0.7`, `dio: ^5.9.0`, `retrofit: ^4.4.0`, `pretty_dio_logger: ^1.4.0`, `hive: ^2.2.3`, `hive_flutter: ^1.1.0`, `path_provider: ^2.1.5`, `internet_connection_checker_plus: ^6.1.5`, `get_it: ^8.0.3`, `injectable: ^2.5.0`, `uuid: ^4.5.1`, `intl: ^0.20.2`, `shared_preferences: ^2.3.5`, `image_picker: ^1.1.2`.
  - Add dev_dependencies: `build_runner: ^2.4.13`, `injectable_generator: ^2.6.1`, `retrofit_generator: ^9.1.0`, `json_serializable: ^6.9.0`, `bloc_test: ^10.0.0`, `mocktail: ^1.0.4`.
  - Note: Explicitly **omit** `hive_generator` to prevent `build_runner`/`analyzer` version deadlock.
  - Enable `generate: true` under `flutter:`.
- [ ] **Step 2: Create `mobile/l10n.yaml` for deterministic localization generation**
  ```yaml
  arb-dir: lib/core/l10n
  template-arb-file: app_en.arb
  output-localization-file: app_localizations.dart
  output-class: AppLocalizations
  synthetic-package: false
  output-dir: lib/core/l10n/generated
  nullable-getter: false
  ```
- [ ] **Step 3: Android Platform Configuration**
  - Add `<uses-permission android:name="android.permission.INTERNET"/>` to `android/app/src/main/AndroidManifest.xml`.
  - Create `android/app/src/main/res/xml/network_security_config.xml` permitting cleartext HTTP to `10.0.2.2`, `localhost`, and LAN addresses.
  - Link it inside `<application android:networkSecurityConfig="@xml/network_security_config" ...>`.
- [ ] **Step 4: iOS Platform Configuration**
  - Add `NSAppTransportSecurity` dictionary to `ios/Runner/Info.plist` with `NSAllowsLocalNetworking: true` and exceptions for `localhost` and `127.0.0.1`.
  - Add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription`.
- [ ] **Step 5: Configure `analysis_options.yaml`**
  - Enable `unawaited_futures`, `avoid_print`, `prefer_final_locals`, and ignore generated files (`**/*.g.dart`, `**/*.config.dart`).
- [ ] **Step 6: Run `flutter pub get` and verify 0 errors.**

---

## Task 1: Core Domain Entities, DI & Theme

**Goal:** Build foundational value objects, Enums, Entities with `Equatable`, dependency injection graph, and theme.

### Files to Create:
- `lib/core/utils/enums.dart`
- `lib/features/delivery/domain/entities/delivery_entity.dart`
- `lib/features/delivery/domain/entities/delivery_action.dart`
- `lib/features/delivery/domain/repositories/delivery_repository.dart`
- `lib/core/network/network_constants.dart`
- `lib/core/di/di.dart`
- `lib/config/theme/colors.dart`
- `lib/config/theme/app_theme.dart`
- `lib/core/general_cubits/locale_cubit.dart`

- [ ] **Step 1: Create `enums.dart`**
  - `DeliveryStatus` (`pending`, `delivered`, `failed`)
  - `SyncStatus` (`synced`, `waitingToSync`, `syncing`, `failed`)
  - `DeliveryActionType` (`complete`, `fail`)
  - `FailureReason` with helper `toApiKey()` (`customer_unavailable`, `wrong_address`, `customer_refused`, `damaged_package`, `other`).
- [ ] **Step 2: Create `DeliveryEntity` extending `Equatable`**
  - Fields: `id`, `orderNumber`, `customerName`, `phone`, `address`, `amountDue`, `paymentMethod`, `status`, `syncStatus`, `recipientName`, `failureReason`, `note`, `proofUrl`, `clientActionId`, `version`.
- [ ] **Step 3: Create `DeliveryAction` extending `Equatable`**
  - Fields: `clientActionId` (UUID v4), `deliveryId`, `type`, `payload` (Map/JSON string), `status`, `createdAt`, `retryCount`, `lastError`.
- [ ] **Step 4: Define `DeliveryRepository` abstract interface**
  - `Future<ApiResult<List<DeliveryEntity>>> getDeliveries()`
  - `Future<ApiResult<DeliveryEntity>> getDeliveryById(int id)`
  - `Future<void> submitAction(DeliveryAction action)`
  - `Stream<List<DeliveryEntity>> watchDeliveries()`
- [ ] **Step 5: Setup `network_constants.dart` with dynamic `--dart-define`**
  ```dart
  const String kBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://10.0.2.2:3000');
  ```
- [ ] **Step 6: Setup `get_it` + `injectable` and verify code generation.**

---

## Task 2: Local Persistence Engine (Hive & Handwritten Adapters)

**Goal:** Zero-friction, reliable offline caching with atomic action persistence.

### Files to Create:
- `lib/core/database/hive_boxes.dart`
- `lib/core/database/adapters/delivery_adapter.dart`
- `lib/core/database/adapters/delivery_action_adapter.dart`
- `lib/core/database/local_storage_service.dart`
- `lib/features/delivery/data_sources/sources/local/delivery_local_ds.dart`
- `lib/features/delivery/data_sources/sources/local/delivery_local_ds_impl.dart`

- [ ] **Step 1: Write `DeliveryAdapter` and `DeliveryActionAdapter` manually**
  - Handwrite `read(BinaryReader reader)` and `write(BinaryWriter writer, ...)` using primitive Hive serialization and JSON strings for nested payloads.
- [ ] **Step 2: Setup `HiveBoxes` and `LocalStorageService`**
  - Initialize Hive inside `getApplicationDocumentsDirectory()`.
  - Register adapters and open `deliveries_box` and `pending_actions_box`.
- [ ] **Step 3: Implement `DeliveryLocalDataSourceImpl`**
  - Methods: `cacheDeliveries()`, `getDeliveries()`, `updateDelivery()`, `savePendingAction()`, `getPendingActions()`, `deletePendingAction()`.
  - **Startup Reconciliation Invariant**: On app startup, scan all cached deliveries; if a delivery has `syncStatus != synced` but no corresponding action in `pending_actions_box`, reset status to `synced` to prevent permanently stranded UI states.
- [ ] **Step 4: Write unit test verifying persistence across process death simulation.**

---

## Task 3: Remote Layer, Interceptors, DI Modules & Connectivity Service

**Goal:** Implement resilient HTTP networking matching Super_Fitness_App with external DI modules, LanguageInterceptor, PrettyDioLogger, transient vs. permanent failure categorization, and active network checking.

### Files to Create:
- `lib/core/helpers/shared_pref.dart`
- `lib/core/helpers/spacing.dart`
- `lib/core/services/language_interceptor.dart`
- `lib/core/network/external_modules.dart`
- `lib/core/network/failures.dart`
- `lib/core/network/api_results.dart`
- `lib/core/network/api_services.dart`
- `lib/core/services/connectivity_service.dart`
- `lib/features/delivery/data_sources/models/response/delivery_response_dto.dart`
- `lib/features/delivery/data_sources/models/request/complete_delivery_request_dto.dart`
- `lib/features/delivery/data_sources/models/request/fail_delivery_request_dto.dart`
- `lib/features/delivery/data_sources/mapper/to_dto_mapper.dart`
- `lib/features/delivery/data_sources/mapper/to_entity_mapper.dart`
- `lib/features/delivery/data_sources/sources/remote/delivery_remote_ds.dart`
- `lib/features/delivery/data_sources/sources/remote/delivery_remote_ds_impl.dart`

- [x] **Step 1: Implement `shared_pref.dart` and `spacing.dart` in `core/helpers/`**
  - `SharedPrefHelper` (@injectable) with typed get/save/remove.
  - `verticalSpace(double height)` and `horizontalSpace(double width)`.
- [x] **Step 2: Implement `language_interceptor.dart` and `external_modules.dart`**
  - `LanguageInterceptor` (@lazySingleton) injecting `Accept-Language` header from `LocaleCubit` / `SharedPrefHelper`.
  - `ExternalModules` (@module):
    - `providePrettyDioLogger()`
    - `provideDio()`: sets `kBaseUrl`, headers, 15s timeouts, adds `PrettyDioLogger` and `LanguageInterceptor`.
    - `provideSharedPreferences` (@preResolve).
- [x] **Step 3: Implement `failures.dart` and `api_results.dart`**
  - Categorize failures:
    - `TransientFailure`: timeouts, 500, socket errors, connection dropouts (retryable).
    - `PermanentFailure`: 400 validation error, 404 not found, 409 conflict (non-retryable).
  - Map backend machine-readable `code` (e.g. `DELIVERY_CONFLICT`, `VALIDATION_ERROR`).
  - `safeApiCall<T>` catching `DioException` and mapping to `ServerFailure` / `TransientFailure` / `PermanentFailure`.
- [x] **Step 4: Create Retrofit `ApiServices` and DTOs with `json_serializable` & Mappers**
  - `GET /deliveries`
  - `GET /deliveries/{id}`
  - `POST /deliveries/{id}/complete`
  - `POST /deliveries/{id}/fail`
  - `POST /deliveries/{id}/proof`
  - DTO to Entity and Entity to DTO mappers.
- [x] **Step 5: Implement `ConnectivityService`**
  - Listen to `internet_connection_checker_plus` and `connectivity_plus`.
  - Implement active HTTP reachability probe (`GET /deliveries` with 3s timeout) before declaring real internet connection.
- [x] **Step 6: Implement `DeliveryRemoteDataSourceImpl`**
  - Inject `ApiServices` and delegate requests wrapped in `safeApiCall`.
- [x] **Step 7: Run `dart run build_runner build --delete-conflicting-outputs` and write unit tests.**

---

## Task 4: Routing, Shared Components & Delivery Screens 📸

**Goal:** Establish app routing, reusable UI components, and driver-friendly list & details screens with responsive sync badges and multilingual support.

### Files to Create:
- `lib/config/routing/app_routes.dart`
- `lib/config/routing/route_generator.dart`
- `lib/config/routing/routing_extensions.dart`
- `lib/core/components/app_textfield.dart`
- `lib/core/components/custom_elevated_button.dart`
- `lib/core/components/custom_text_button.dart`
- `lib/core/helpers/dialogue_utils.dart`
- `lib/core/helpers/flutter_toast.dart`
- `lib/core/helpers/validators.dart`
- `lib/features/delivery/presentation/widgets/sync_status_badge.dart`
- `lib/features/delivery/presentation/widgets/delivery_card.dart`
- `lib/features/delivery/presentation/pages/deliveries_list_screen.dart`
- `lib/features/delivery/presentation/pages/delivery_details_screen.dart`
- `lib/features/delivery/presentation/manager/cubit/delivery_cubit.dart`
- `lib/features/delivery/presentation/manager/cubit/delivery_state.dart`

- [ ] **Step 1: Setup Routing & App Navigation**
  - `AppRoutes.deliveriesList`, `AppRoutes.deliveryDetails`.
  - `RouteGenerator.onGenerateRoute` with unknown route fallback.
  - `context.pushNamed`, `context.pushReplacementNamed`, `context.pop`.
- [ ] **Step 2: Build Shared Core Components & Dialog Helpers**
  - `AppTextField` with label, hint, prefix/suffix icon, error text.
  - `CustomElevatedButton` with loading indicator and disabled state.
  - `CustomTextButton`.
  - `DialogueUtils` (alert, confirmation dialogs).
  - `FlutterToast` (success, error toast snackbars).
  - `Validators` (phone, name, required fields).
- [ ] **Step 3: Build `SyncStatusBadge` widget**
  - `Synced ✅` (Subtle green badge)
  - `Waiting to sync ⏳` (Subtle amber badge with tiny spinning indicator)
  - `Syncing 🔄` (Subtle blue pulse)
  - `Failed to sync ❌` (Subtle red badge with a direct `[Retry]` action button)
- [ ] **Step 4: Build `DeliveryCard` widget**
  - Displays: Order Number (`ORD-1001`), Customer Name, Phone, Address, Amount Due (`18.750 KWD`), Payment Badge (`Cash` / `InstaPay`), Delivery Status, and Sync Status Badge.
- [ ] **Step 5: Implement `DeliveriesListScreen`**
  - App bar with language toggle (EN/AR), online/offline indicator, pull-to-refresh.
  - Handle states: Loading, Error, Empty, and Populated List.
- [ ] **Step 6: Implement `DeliveryDetailsScreen`**
  - Full delivery breakdown, call customer action, and primary actions (`Mark Delivered`, `Mark Failed`).
  - **Freeze Rule:** Disable action buttons if the delivery has `SyncStatus.waitingToSync` or `SyncStatus.syncing`.
- [ ] **📸 User Checkpoint:** Request user screenshots of list and details in both EN and AR.

---

## Task 5: Action Capture Bottom Sheets (Offline-First Flow) 📸

**Goal:** Implement completion and failure dialogs with form validation, single UUID generation, and immediate local UI update.

### Files to Create:
- `lib/features/delivery/presentation/widgets/complete_delivery_sheet.dart`
- `lib/features/delivery/presentation/widgets/fail_delivery_sheet.dart`
- `lib/features/delivery/domain/use_case/complete_delivery_use_case.dart`
- `lib/features/delivery/domain/use_case/fail_delivery_use_case.dart`

- [ ] **Step 1: Build `CompleteDeliverySheet`**
  - Input: `recipient_name` (Required, trimmed, min 2 chars).
  - Input: `note` (Optional, max 500 chars).
  - Button: `[Confirm Delivery]`.
- [ ] **Step 2: Build `FailDeliverySheet`**
  - Dropdown: `reason` (Required: Customer unavailable, Wrong address, Refused, Damaged, Other).
  - Input: `note` (Optional).
  - Button: `[Confirm Failure]`.
- [ ] **Step 3: Wire Offline-First Mutation Flow in `DeliveryCubit`**
  1. Validate user inputs.
  2. Generate `client_action_id = Uuid().v4()`.
  3. Immediately save `DeliveryAction` to `pending_actions_box` with status `waitingToSync`.
  4. Immediately update local `DeliveryEntity` in `deliveries_box` to `delivered` or `failed` with `syncStatus: waitingToSync`.
  5. Emit state to UI -> Dialog closes and card instantly shows `Waiting to sync ⏳`.
  6. Trigger `SyncManager.processQueue()`.
- [ ] **📸 User Checkpoint:** Test in Airplane Mode; verify action remains `Waiting to sync ⏳` across app kill and restart.

---

## Task 6: Sequential Background Sync Engine (SyncManager) 📸

**Goal:** Guarantee reliable, idempotent queue processing on network return, with mutex locking and manual retry support.

### Files to Create / Modify:
- `lib/core/services/sync_manager.dart`
- `lib/features/delivery/domain/use_case/retry_action_use_case.dart`

- [ ] **Step 1: Implement `SyncManager` Singleton with Mutex Lock**
  - Sequential FIFO queue processing (`for (final action in actions)`).
  - Prevent concurrent queue drains with `Completer` / mutex chaining (`_isSyncing` flag).
  - Debounce connectivity events (5 seconds) and verify reachability before draining.
- [ ] **Step 2: Execute Sync Steps**
  - Read pending actions.
  - Set delivery sync status to `syncing 🔄`.
  - Call remote data source with the exact, immutable `client_action_id`.
  - **On Success (200 OK):**
    - Delete action from `pending_actions_box`.
    - Update delivery in `deliveries_box` with `syncStatus: synced`.
    - Emit state -> UI flips badge to `Synced ✅`.
  - **On Conflict (409 Conflict):**
    - Delivery was modified on the server beforehand.
    - Fetch fresh delivery state from `GET /deliveries/:id`.
    - Delete conflicting pending action and update local delivery to server truth.
    - Notify driver via alert dialog.
  - **On Transient Failure (Timeout / 500 / Network Drop):**
    - Action remains in `pending_actions_box` with incremented `retryCount` and status `failed`.
    - Delivery updated to `syncStatus: failed`.
    - UI displays `Failed to sync ❌` with active `[Retry]` button.
- [ ] **Step 3: Implement Manual Retry**
  - Driver taps `[Retry]` on a failed card -> immediately invokes `SyncManager.retryAction(actionId)`.
- [ ] **📸 User Checkpoint:** Demonstrate queue drain on reconnect and manual retry button.

---

## Task 7: Photo Proof Capture & Offline Upload 📸

**Goal:** Capture delivery proof image with camera/gallery, persist in app documents dir, and upload.

### Files to Create / Modify:
- `lib/features/delivery/presentation/widgets/photo_proof_picker.dart`
- `lib/features/delivery/data_sources/sources/remote/delivery_remote_ds_impl.dart`

- [ ] **Step 1: Implement photo capture via `image_picker`**
  - Capture photo and immediately copy file to `getApplicationDocumentsDirectory() / proofs / <action_id>.jpg` (prevents OS cache cleanup).
  - Save file path into `DeliveryAction.payload['local_photo_path']`.
- [ ] **Step 2: Upload photo proof during synchronization**
  - During sync: if `local_photo_path` exists, upload via `POST /deliveries/{id}/proof` multipart/form-data.
  - Attach returned `proof_url` to delivery record.
- [ ] **📸 User Checkpoint:** Verify photo captured offline is safely uploaded when device reconnects.

---

## Task 8: Full Arabic/English Localization & RTL

**Goal:** Flawless bilingual support with native Arabic RTL rendering.

### Files to Modify / Create:
- `lib/core/l10n/app_en.arb`
- `lib/core/l10n/app_ar.arb`

- [ ] **Step 1: Populate all strings in `app_en.arb` and `app_ar.arb` with 100% key parity**
  - Delivery statuses, failure reasons, buttons, sync badges, error messages.
- [ ] **Step 2: RTL Layout Audit**
  - Replace all `EdgeInsets.left/right` with `EdgeInsetsDirectional.start/end`.
  - Format amount and phone numbers cleanly for Arabic locale.
- [ ] **📸 User Checkpoint:** Provide screenshots of Arabic and English interfaces.

---

## Task 9: Automated Verification & Final Test Suite

**Goal:** Deliver thorough test coverage satisfying all 7 test scenarios from the spec.

### Files to Create:
- `test/unit/delivery_local_ds_test.dart`
- `test/unit/sync_manager_test.dart`
- `test/unit/idempotency_test.dart`
- `test/widget/delivery_card_test.dart`

- [ ] **Scenario 1: Offline Action Queueing** — Verify action is saved in `pending_actions_box` and delivery marked `waitingToSync`.
- [ ] **Scenario 2: App Restart Persistence** — Verify pending actions survive process restart.
- [ ] **Scenario 3: Connectivity Recovery Sync** — Verify queue drains when connectivity restored.
- [ ] **Scenario 4: Transient vs Permanent Failures** — Verify 500 allows retry; 409 conflict resolves cleanly.
- [ ] **Scenario 5: Idempotency Integrity** — Verify `client_action_id` is byte-identical across retries.
- [ ] **Scenario 6: Complete Delivery Validation** — Verify empty recipient name is blocked.
- [ ] **Scenario 7: Fail Delivery Validation** — Verify missing reason is blocked.
- [ ] Run `flutter test` and assert all tests pass.
