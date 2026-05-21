# Riverpod State Management Migration

## Overview

Replaced the manual `GlobalKey` + `reload()` pattern with `flutter_riverpod` (`AsyncNotifierProvider`). History state is now a single source of truth — any widget that reads or mutates history does so through the provider, and the UI rebuilds automatically.

---

## Problem: The Old Pattern

Before this migration, history data was loaded independently by each widget using `QrHistoryService` directly:

```
HomeScreen
├── _recentCodesKey  (GlobalKey<RecentCodesState>)
└── _historyScreenKey (GlobalKey<HistoryScreenState>)

_onNavTapped(index) {
  if (leaving create tab) {
    _recentCodesKey.currentState?.reload();   // manual refresh
    _historyScreenKey.currentState?.reload(); // manual refresh
  }
  if (going to home)    _recentCodesKey.currentState?.reload();
  if (going to history) _historyScreenKey.currentState?.reload();
}
```

**Issues with this approach:**
- Widgets held their own copy of history in local state (`List<QrHistoryItem> _items`)
- `HomeScreen` had to know about every widget that displays history
- `reload()` calls had to be placed at every navigation event that could produce a new QR code
- Any missed call meant stale data being shown
- Public state classes (`HistoryScreenState`, `RecentCodesState`) were only public so `HomeScreen` could call `reload()` on them via GlobalKey — an anti-pattern

---

## What Changed

### 1. `pubspec.yaml` — Add Dependency

```yaml
flutter_riverpod: ^2.6.1
```

---

### 2. `lib/main.dart` — Wrap with `ProviderScope`

`ProviderScope` is required at the root of the widget tree. It owns all provider state.

```dart
// Before
void main() {
  runApp(const MyApp());
}

// After
void main() {
  runApp(const ProviderScope(child: MyApp()));
}
```

---

### 3. `lib/providers/history_provider.dart` — New File

The single source of truth for all history data.

```dart
class HistoryNotifier extends AsyncNotifier<List<QrHistoryItem>> {
  @override
  Future<List<QrHistoryItem>> build() => QrHistoryService.getHistory();

  Future<void> addItem(QrHistoryItem item) async {
    await QrHistoryService.addItem(item);
    ref.invalidateSelf(); // mark stale
    await future;         // wait for rebuild
  }

  Future<void> deleteItem(String id) async {
    await QrHistoryService.deleteItem(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> clearAll() async {
    await QrHistoryService.clearHistory();
    ref.invalidateSelf();
    await future;
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<QrHistoryItem>>(
  HistoryNotifier.new,
);
```

`AsyncNotifier` wraps async state in `AsyncValue<T>` — giving you `loading`, `error`, and `data` states for free.  
`ref.invalidateSelf()` tells Riverpod the data is stale. `await future` waits for the fresh load to complete before the `addItem` / `deleteItem` / `clearAll` call returns, so callers can `await` a mutation and be sure the UI is already up to date.

---

### 4. `lib/widgets/createscreem_widgets/qr_tab_shell.dart` — Consumer for saving

**Before:** `StatelessWidget` calling `QrHistoryService.addItem(...)` directly.  
**After:** `ConsumerWidget` calling `ref.read(historyProvider.notifier).addItem(...)`.

```dart
// Before
class QrTabShell extends StatelessWidget {
  Future<void> _onGenerate(BuildContext context) async {
    // ...
    await QrHistoryService.addItem(QrHistoryItem(...));
    onReset();
  }

  @override
  Widget build(BuildContext context) { ... }
}

// After
class QrTabShell extends ConsumerWidget {
  Future<void> _onGenerate(BuildContext context, WidgetRef ref) async {
    // ...
    await ref.read(historyProvider.notifier).addItem(QrHistoryItem(...));
    onReset();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ...
    onPressed: () => _onGenerate(context, ref),
  }
}
```

After `addItem` completes, `historyProvider` has already reloaded — every widget watching it rebuilds automatically.

---

### 5. `lib/screens/main/history_screen.dart` — Consumer for display

**Before:** `StatefulWidget` with public `HistoryScreenState`, local `List<QrHistoryItem> _items`, `bool _loading`, `initState` load, `reload()` method.  
**After:** `ConsumerWidget` — no local state at all.

```dart
// Before
class HistoryScreen extends StatefulWidget { ... }
class HistoryScreenState extends State<HistoryScreen> {
  List<QrHistoryItem> _items = [];
  bool _loading = true;
  void reload() => _loadHistory();
  // ...
}

// After
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      body: historyAsync.when(
        loading: () => const CircularProgressIndicator(),
        error:   (e, _) => Text('Error: $e'),
        data:    (items) => _buildList(context, ref, items),
      ),
    );
  }
}
```

Mutations go through the notifier:
```dart
// Delete
ref.read(historyProvider.notifier).deleteItem(item.id)

// Clear all
ref.read(historyProvider.notifier).clearAll()
```

`_getShape` and `_formatDate` were promoted from instance methods to **top-level private functions** in the file, since they no longer need access to `this` (the state object is gone).

---

### 6. `lib/widgets/homescreen_widgets/recent_codes.dart` — Consumer for display

Same pattern as `history_screen.dart`.

**Before:** `StatefulWidget` with public `RecentCodesState`, `initState` + `didUpdateWidget` loads, `reload()`.  
**After:** `ConsumerWidget` watching the same provider.

```dart
// After
class RecentCodes extends ConsumerWidget {
  const RecentCodes({super.key, required this.onHistory});
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final items = historyAsync.whenOrNull(
      data: (list) => list.take(3).toList(),
    ) ?? [];
    // ...
  }
}
```

`_getShape`, `_qrLabel`, `_formatDate` were also promoted to top-level functions and the duplicate instance-method versions removed.

---

### 7. `lib/screens/main/home_screen.dart` — Remove reload plumbing

**Before:**
```dart
final _historyScreenKey = GlobalKey<HistoryScreenState>();
final _recentCodesKey   = GlobalKey<RecentCodesState>();

void _onNavTapped(int index) {
  if (_currentIndex == 1 && index != 1) {
    _recentCodesKey.currentState?.reload();
    _historyScreenKey.currentState?.reload();
  }
  if (index == 0) _recentCodesKey.currentState?.reload();
  if (index == 3) _historyScreenKey.currentState?.reload();
  setState(() => _currentIndex = index);
}
```

**After:**
```dart
void _onNavTapped(int index) {
  setState(() => _currentIndex = index);
}
```

`_createScreenKey` is kept — it's still needed for `setType()` (programmatically switching the create tab's active type from the home tab's quick-generate buttons). That use case is fine because `setType` is controlling UI state, not data state.

`_HomeTab` no longer receives a `recentCodesKey` parameter. `HistoryScreen` is instantiated with `const` again.

---

## Data Flow After Migration

```
User generates a QR
        │
        ▼
QrTabShell._onGenerate()
        │
        ▼
ref.read(historyProvider.notifier).addItem(item)
        │  (writes to SharedPreferences via QrHistoryService)
        │  (calls ref.invalidateSelf())
        ▼
historyProvider reloads from SharedPreferences
        │
        ├──► HistoryScreen rebuilds  (ref.watch)
        └──► RecentCodes rebuilds    (ref.watch)
```

No navigation callbacks. No GlobalKeys for data. No manual `reload()` calls.

---

## Files Changed

| File | Type of Change |
|---|---|
| `pubspec.yaml` | Added `flutter_riverpod: ^2.6.1` |
| `lib/main.dart` | Wrapped `runApp` with `ProviderScope` |
| `lib/providers/history_provider.dart` | **Created** — `AsyncNotifier` + provider |
| `lib/widgets/createscreem_widgets/qr_tab_shell.dart` | `StatelessWidget` → `ConsumerWidget` |
| `lib/screens/main/history_screen.dart` | `StatefulWidget` → `ConsumerWidget` |
| `lib/widgets/homescreen_widgets/recent_codes.dart` | `StatefulWidget` → `ConsumerWidget` |
| `lib/screens/main/home_screen.dart` | Removed GlobalKeys + reload plumbing |
