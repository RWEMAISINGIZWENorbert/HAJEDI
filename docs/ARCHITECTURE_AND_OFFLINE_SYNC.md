# HAJEDI Architecture and Offline-First Synchronization

## 1. Document Purpose

This document describes the architecture and development rules for the HAJEDI application.

It explains:

- How the Flutter application is structured
- How authentication works
- How localization works
- How local Hive storage works
- How offline operations are queued
- How local changes are synchronized with the server
- How remote changes are pulled from the server
- How the application reacts to connectivity changes
- How foreground polling works
- How soft deletion works
- How new modules should be implemented
- How products, customers, suppliers, sales, purchases, and expenses should follow the same pattern

All future features should follow the principles described in this document.

---

# 2. Project Structure

The project contains two applications:

```text
HAJEDI/
├── hajedi/
│   ├── lib/
│   │   ├── bloc/
│   │   ├── core/
│   │   ├── data/
│   │   ├── l10n/
│   │   ├── repository/
│   │   ├── screens/
│   │   ├── utils/
│   │   └── widgets/
│   ├── test/
│   ├── pubspec.yaml
│   └── README.md
│
└── HAJEDI-SERVER/
    ├── config/
    ├── controllers/
    ├── middleware/
    ├── models/
    ├── routes/
    ├── utils/
    ├── package.json
    └── server.js
```

## 2.1 Flutter Application

The Flutter application is responsible for:

- User interface
- Local data storage
- Authentication state
- Offline operations
- Synchronization requests
- Localization
- Updating the UI when Hive data changes

## 2.2 Node.js Application

The server application is responsible for:

- Authentication
- Authorization
- Data validation
- MongoDB persistence
- REST API endpoints
- Synchronization endpoints
- Conflict validation
- Soft deletion
- Role-based access control

---

# 3. Main Architectural Principle

HAJEDI uses a local-first architecture.

The local database is the first source used by the UI. The application should not wait for the server before displaying data that already exists locally.

The general flow is:

```text
User action
    |
    v
Update Hive immediately
    |
    v
Update the UI immediately
    |
    v
Add the operation to the offline queue
    |
    v
Check network connectivity
    |
    +-- Online: send the operation to the server
    |
    +-- Offline: keep it in the queue
```

For remote changes:

```text
Check connectivity
    |
    v
Upload pending local operations
    |
    v
Pull remote changes
    |
    v
Save remote changes into Hive
    |
    v
Hive notifies the application
    |
    v
Bloc emits a new state
    |
    v
UI rebuilds automatically
```

The user should be able to continue working when the internet connection is unavailable.

---

# 4. Authentication

## 4.1 Authentication Flow

The login endpoint is:

```text
POST /auth/login
```

The request body is:

```json
{
  "name": "username",
  "password": "password"
}
```

The server returns:

```json
{
  "message": "Login successful",
  "user": {
    "id": "mongo-id",
    "name": "John",
    "role": "admin"
  },
  "tokens": {
    "accessToken": "access-token",
    "refreshToken": "refresh-token"
  }
}
```

The Flutter application saves:

- Access token in `SharedPreferences`
- User data in `SharedPreferences`

The access token is used in subsequent authenticated requests:

```http
Authorization: Bearer <access-token>
```

## 4.2 Authentication Utility

Authentication persistence is handled by `AuthUtils`.

Important methods:

```dart
AuthUtils.saveToken(token);
AuthUtils.getToken();
AuthUtils.saveUser(authData);
AuthUtils.readUser();
AuthUtils.isAuthenticated();
AuthUtils.clearAuthData();
```

`isAuthenticated()` returns `true` only when both values exist:

- `token`
- `user_data`

If either value is missing, the user is treated as logged out.

## 4.3 Authentication Gate

The application uses an authentication gate during startup.

The authentication gate checks local authentication data before choosing the first screen:

```text
Application starts
    |
    v
Check token and user_data
    |
    +-- Both exist: open dashboard
    |
    +-- One is missing: open sign-in screen
```

`MaterialApp.initialRoute` should not be used for an asynchronous authentication check because `initialRoute` accepts a synchronous string.

The correct approach is:

```dart
home: const AuthGate(),
```

The `AuthGate` uses:

```dart
FutureBuilder<bool>(
  future: AuthUtils.isAuthenticated(),
)
```

---

# 5. Localization

Localization files are stored in:

```text
lib/l10n/app_en.arb
lib/l10n/app_rw.arb
```

The supported languages are:

- English
- Kinyarwanda

Example English localization:

```json
{
  "login": "Login",
  "logout": "Logout",
  "today": "Today",
  "this_week": "This week",
  "this_month": "This month",
  "this_year": "This year",
  "all": "All",
  "yes": "Yes",
  "no": "No"
}
```

Example Kinyarwanda localization:

```json
{
  "login": "Injira",
  "logout": "Sohoka",
  "today": "Uyu munsi",
  "this_week": "Muri iki cyumweru",
  "this_month": "Muri uku kwezi",
  "this_year": "Muri uyu mwaka",
  "all": "Byose",
  "yes": "Yego",
  "no": "Oya"
}
```

After changing an ARB file, regenerate localization classes:

```bash
flutter gen-l10n
```

Generated localization files should not be manually edited.

All user-visible text should come from `AppLocalizations`.

Avoid hard-coded text such as:

```dart
Text('Add New User')
```

Prefer:

```dart
Text(localizations.add_new_user)
```

---

# 6. Flutter Layer Responsibilities

## 6.1 Data Models

Data models represent application entities.

Examples:

```text
lib/data/user.dart
lib/data/product.dart
lib/data/customer.dart
lib/data/supplier.dart
```

A model should contain:

- Fields
- Constructor
- `fromJson`
- `toJson`
- `copyWith`
- Local synchronization fields where required

## 6.2 BLoC Layer

BLoCs coordinate UI events and application state.

Examples:

```text
lib/bloc/auth/
lib/bloc/user/
lib/bloc/product/
lib/bloc/customer/
```

A Bloc should:

- Receive events
- Update local storage
- Add operations to the synchronization queue
- Ask `SyncManager` to synchronize when possible
- Emit states for the UI

A Bloc should not directly contain HTTP implementation details. HTTP calls belong in repositories.

## 6.3 Repository Layer

Repositories communicate with the backend.

Examples:

```text
lib/repository/auth_repository.dart
lib/repository/user_repository.dart
lib/repository/product_repository.dart
```

Repositories should:

- Build URLs
- Add authorization headers
- Encode request bodies
- Decode server responses
- Return typed models
- Throw meaningful exceptions

## 6.4 Core Layer

The core layer contains application-wide infrastructure:

```text
lib/core/helpers/
lib/core/network/
lib/core/theme/
```

Examples:

- Hive queue management
- Connectivity monitoring
- Synchronization manager
- Synchronization metadata
- Theme configuration

## 6.5 Widgets

Reusable UI components belong in:

```text
lib/widgets/
```

Examples:

- Input fields
- Buttons
- Select controls
- Snackbars
- Loading indicators
- Forms

---

# 7. Local Hive Storage

Hive stores data locally on the device.

The application uses Hive for:

- Users
- Products
- Customers
- Suppliers
- Transactions
- Synchronization queue
- Other offline-capable entities

Hive boxes are initialized in `HiveRegistry`.

Every Hive model must have:

```dart
@HiveType(typeId: ...)
class Entity {
  ...
}
```

After changing a Hive model, regenerate adapters:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 7.1 Hive Box Rules

Each entity should have its own box:

```text
users
products
customers
suppliers
sales
purchases
expenses
syncQueue
```

Use a stable key for every local record.

For offline-created entities, use a client-generated UUID:

```dart
final clientId = const Uuid().v4();
```

The local key should not depend on a server request succeeding.

---

# 8. Entity Identity

Every synchronized entity should have two identities:

```text
id        = MongoDB server ID
clientId  = Flutter-generated local ID
```

## 8.1 Server ID

The server ID is MongoDB's `_id`.

It is used for:

- Server-side relationships
- JWT references
- Internal MongoDB operations
- Backend-only operations

## 8.2 Client ID

The client ID is generated by Flutter.

It is used for:

- Hive keys
- Offline queue payloads
- Local update operations
- Local delete operations
- Matching records across devices

Example:

```json
{
  "id": "67d1-server-id",
  "clientId": "e9c99dff-5441-4fee-85a4-a0d6050623c0",
  "name": "John"
}
```

MongoDB should continue using its default ObjectId. The Flutter UUID should be stored in a separate `clientId` field.

Do not replace MongoDB `_id` with a client UUID unless the entire database is intentionally designed around string IDs.

---

# 9. Offline Queue

The offline queue stores operations that have not yet reached the server.

Each queue item contains:

```text
id
entityType
operationType
payload
status
createdAt
updatedAt
retryCount
```

Example queue item:

```json
{
  "id": "queue-item-id",
  "entityType": "user",
  "operationType": "create",
  "payload": {
    "clientId": "local-id",
    "name": "John",
    "role": "employee"
  },
  "status": "pending"
}
```

## 9.1 Queue Operation Types

Supported operation types:

```text
create
update
delete
```

## 9.2 Queue Statuses

```text
pending
syncing
failed
synced
```

## 9.3 JSON Serialization

Queue payloads must always be serialized with `jsonEncode`.

Correct:

```dart
payload: jsonEncode(payload),
```

Incorrect:

```dart
payload: payload.toString(),
```

`Map.toString()` produces a Dart representation:

```text
{id: abc, name: John}
```

That is not valid JSON.

Valid JSON looks like:

```json
{"id":"abc","name":"John"}
```

The synchronization manager decodes queue payloads with:

```dart
final payload =
    jsonDecode(item.payload) as Map<String, dynamic>;
```

## 9.4 Queue Ordering

Queue records should be processed in `createdAt` order.

This is important when the queue contains:

```text
create user
update user
delete user
```

The create operation must be processed before update or delete.

---

# 10. SyncManager

`SyncManager` is responsible for synchronization.

It performs:

- Connectivity checks
- Uploading pending operations
- Pulling remote changes
- Applying remote changes to Hive
- Preventing simultaneous synchronization

## 10.1 Synchronization Lock

Only one synchronization operation should run at a time.

```dart
if (_isSyncing) {
  return;
}
```

The lock must be set before upload and remain active until both upload and download finish.

General structure:

```dart
Future<void> syncIfConnected() async {
  if (_isSyncing) {
    return;
  }

  final connected = await hasConnection();

  if (!connected) {
    return;
  }

  _isSyncing = true;

  try {
    await uploadPendingChanges();
    await pullRemoteChanges();
  } finally {
    _isSyncing = false;
  }
}
```

## 10.2 Synchronization Order

The required order is:

```text
1. Upload local pending operations
2. Pull remote changes
3. Apply remote changes to Hive
4. Allow Hive watchers to refresh the UI
```

Uploading first helps prevent the application from pulling an older server version immediately after making a local change.

## 10.3 Connectivity Synchronization

`SyncManager` listens to connectivity changes.

When connectivity returns:

```text
Internet unavailable
    |
    v
Internet becomes available
    |
    v
syncIfConnected()
```

A connection event should trigger synchronization only when the result does not contain:

```dart
ConnectivityResult.none
```

---

# 11. Delta Synchronization

The application should not download the entire database during every synchronization.

Instead, it should request only records changed since the last successful synchronization.

Example endpoint:

```text
GET /auth/users/changes?since=<cursor>
```

Example response:

```json
{
  "data": {
    "created": [],
    "updated": [],
    "deleted": []
  },
  "nextCursor": "2026-09-03T10:11:00.000Z"
}
```

## 11.1 Synchronization Cursor

The cursor represents the latest server change received by the device.

It is stored locally in synchronization metadata:

```text
users_sync_cursor
products_sync_cursor
customers_sync_cursor
```

The next request uses the saved cursor:

```text
GET /auth/users/changes?since=<last-cursor>
```

After successful processing, save:

```text
nextCursor
```

Do not save the cursor before the received changes have been successfully written to Hive.

## 11.2 First Synchronization

If no cursor exists:

```text
GET /auth/users/changes
```

The server should return the initial dataset and a cursor.

## 11.3 Subsequent Synchronizations

If a cursor exists:

```text
GET /auth/users/changes?since=<cursor>
```

The server returns only records changed after that cursor.

---

# 12. Server-Side Synchronization

Every synchronized backend model should contain:

```js
clientId
deletedAt
createdAt
updatedAt
```

Example:

```js
const userSchema = new mongoose.Schema(
  {
    clientId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },

    name: {
      type: String,
      required: true,
    },

    role: {
      type: String,
      enum: ["employee", "admin"],
      default: "employee",
    },

    password: {
      type: String,
      required: true,
    },

    deletedAt: {
      type: Date,
      default: null,
      index: true,
    },
  },
  {
    timestamps: true,
  }
);
```

The same pattern should be used for products, customers, suppliers, and other entities.

---

# 13. Soft Deletes

Hard deletion causes synchronization problems.

If the server permanently removes a record:

```js
await User.findOneAndDelete({ clientId });
```

another device cannot discover that the record was deleted.

Instead, use a soft delete:

```js
await User.findOneAndUpdate(
  { clientId },
  { deletedAt: new Date() },
  { new: true }
);
```

The record remains available to the delta synchronization endpoint.

The server returns deleted records as:

```json
{
  "clientId": "local-id",
  "deletedAt": "2026-09-03T10:11:00.000Z"
}
```

The Flutter application then removes the record from Hive:

```dart
await userBox.delete(clientId);
```

Soft-deleted records should only be permanently removed after every important client has synchronized beyond the deletion point.

---

# 14. Foreground Polling

Without push notifications, the application needs a controlled way to discover changes made by other users.

`SyncCoordinator` handles foreground polling.

It should:

- Synchronize when the application starts
- Synchronize when the application resumes
- Poll periodically while the application is active
- Stop polling while the application is in the background

Recommended interval:

```text
60 seconds
```

The interval can be changed depending on the module:

```text
Dashboard: 30 to 60 seconds
Reports: manual refresh
Transactions: 30 to 60 seconds
Large datasets: 60 to 120 seconds
```

The coordinator should not create multiple timers.

Before starting a new timer:

```dart
_timer?.cancel();
```

Lifecycle behavior:

```text
App resumed
    |
    v
Synchronize immediately
    |
    v
Start foreground timer

App paused
    |
    v
Cancel foreground timer
```

---

# 15. Hive UI Updates

The UI should display local data immediately.

When `SyncManager` writes remote changes into Hive, the UI must rebuild.

A Bloc can listen to Hive box events:

```dart
StreamSubscription<BoxEvent>? _userBoxSubscription;
```

Initialize it once in the Bloc constructor:

```dart
_userBoxSubscription = _userBox.watch().listen((event) {
  add(LoadUsers());
});
```

Cancel it when the Bloc closes:

```dart
@override
Future<void> close() async {
  await _userBoxSubscription?.cancel();
  return super.close();
}
```

This produces the following flow:

```text
SyncManager writes to Hive
    |
    v
Hive emits BoxEvent
    |
    v
UserBloc receives LoadUsers
    |
    v
UserBloc emits UsersLoadedState
    |
    v
UI rebuilds
```

Every entity Bloc that needs automatic updates should follow the same pattern.

---

# 16. Local Operation Flow

## 16.1 Create

When creating an entity:

```text
1. Generate clientId
2. Save the entity to Hive
3. Emit updated local state
4. Add a create operation to the queue
5. Call syncIfConnected()
```

Example:

```dart
final user = User(
  id: '',
  clientId: const Uuid().v4(),
  name: name,
  role: role,
  password: password,
);

await userBox.put(user.clientId, user);

await SyncQueue.enqueue(
  entityType: 'user',
  operationType: 'create',
  payload: user.toJson(),
);

await syncManager.syncIfConnected();
```

## 16.2 Update

When updating an entity:

```text
1. Find the local entity using clientId
2. Update Hive immediately
3. Emit updated local state
4. Queue the update
5. Call syncIfConnected()
```

The update request must use `clientId`, not MongoDB `_id`, when using the client identity strategy.

## 16.3 Delete

When deleting an entity locally:

```text
1. Find the local entity using clientId
2. Remove it from Hive immediately
3. Queue a delete operation containing clientId
4. Call syncIfConnected()
```

Example:

```dart
await userBox.delete(user.clientId);

await SyncQueue.enqueue(
  entityType: 'user',
  operationType: 'delete',
  payload: {
    'clientId': user.clientId,
  },
);

await syncManager.syncIfConnected();
```

The UI should not wait for the server before removing the item locally.

---

# 17. Sync Failure and Retry

If an operation fails:

```text
syncing -> failed
```

The queue item remains stored.

The next synchronization attempt retries failed items.

Failures may occur because of:

- No internet connection
- Server unavailable
- Invalid request
- Expired token
- Validation failure
- Duplicate record
- Conflict with another user
- Malformed queue payload

The queue should not silently delete failed operations.

Log enough information to identify:

- Queue item ID
- Entity type
- Operation type
- Error message
- Retry count

Permanent validation errors should eventually require user attention instead of retrying forever.

---

# 18. Conflict Handling

Multiple users may update the same record.

The initial strategy may be:

```text
Last server update wins
```

Every record should contain:

```text
updatedAt
```

A later improvement is optimistic concurrency using a version number:

```text
version: 1
```

The client sends the version it last received.

The server rejects outdated updates:

```http
409 Conflict
```

Example conflict:

```text
Device A reads version 3
Device B reads version 3
Device A updates version 4
Device B attempts to update version 3
Server rejects Device B
```

For the first implementation, use server timestamps and last-write-wins. Add version conflict handling when simultaneous editing becomes important.

---

# 19. Preventing Unnecessary Server Calls

The application should synchronize only when useful.

Synchronize when:

- The application starts
- The app returns to the foreground
- Connectivity returns
- A local operation is queued
- The polling interval expires
- The user manually refreshes

Avoid synchronization when:

- The app is paused
- There is no internet connection
- Another synchronization is already running
- The cursor has not changed and the server supports conditional requests
- No authenticated user is available

The delta endpoint prevents downloading unchanged records.

Optional optimization:

```http
ETag: "users-version-42"
If-None-Match: "users-version-42"
```

If nothing changed:

```http
304 Not Modified
```

This reduces response size and server processing.

---

# 20. Adding New Modules

Every future module should follow the same structure.

For example, products:

```text
lib/data/product.dart
lib/repository/product_repository.dart
lib/bloc/product/product_bloc.dart
lib/bloc/product/product_event.dart
lib/bloc/product/product_state.dart
lib/screens/products/
```

Server files:

```text
HAJEDI-SERVER/models/product.js
HAJEDI-SERVER/controllers/product_controller.js
HAJEDI-SERVER/routes/product_router.js
```

Each module should support:

- Local Hive storage
- Stable `clientId`
- Server MongoDB `_id`
- Create operation
- Update operation
- Delete operation
- Offline queue
- Delta synchronization
- Soft delete
- `createdAt`
- `updatedAt`
- `deletedAt`
- Role-based access control

---

# 21. Entity Synchronization Contract

Every synchronized entity should follow this contract:

```text
Entity:
  id
  clientId
  createdAt
  updatedAt
  deletedAt
```

Local entity:

```text
Hive key = clientId
```

Create payload:

```json
{
  "clientId": "local-id",
  "...": "entity fields"
}
```

Update endpoint:

```text
PUT /entity/client/:clientId
```

Delete endpoint:

```text
DELETE /entity/client/:clientId
```

Delta endpoint:

```text
GET /entity/changes?since=<cursor>
```

Delta response:

```json
{
  "data": {
    "created": [],
    "updated": [],
    "deleted": []
  },
  "nextCursor": "..."
}
```

---

# 22. Module Examples

## 22.1 Products

Products may contain:

```text
clientId
name
category
unit
packet
crate
bottles
price
quantity
createdAt
updatedAt
deletedAt
```

The product synchronization pattern is the same as users.

## 22.2 Customers

Customers may contain:

```text
clientId
name
phone
address
creditLimit
createdAt
updatedAt
deletedAt
```

Customers should be cached locally if sales and credit operations need offline access.

## 22.3 Suppliers

Suppliers may contain:

```text
clientId
name
phone
address
createdAt
updatedAt
deletedAt
```

Supplier data should synchronize before purchases are created.

## 22.4 Sales

Sales are transaction records and need special care.

A sale should contain:

```text
clientId
customerIdccc
items
total
paymentStatus
createdAt
updatedAt
deletedAt
```

Sales should not be deleted casually. Prefer cancellation or reversal records instead of deleting completed financial transactions.

## 22.5 Purchases

Purchases may contain:

```text
clientId
supplierId
items
total
paymentStatus
createdAt
updatedAt
deletedAt
```

Purchases may also update product stock. Stock changes should be processed atomically on the server.

## 22.6 Expenses

Expenses may contain:

```text
clientId
description
amount
category
createdBy
createdAt
updatedAt
deletedAt
```

Expenses should include the user who created or approved them.

---

# 23. Transactions and Inventory

Transactions should not be treated exactly like simple users or customers.

A transaction may affect:

- Product quantity
- Revenue
- Expenses
- Customer balances
- Supplier balances
- Reports

The server should be the authoritative source for financial calculations.

The Flutter application may create a transaction offline, but the server must validate:

- Product availability
- Quantity
- Prices
- User permissions
- Customer or supplier existence
- Duplicate transaction prevention

Use a client-generated transaction ID to make requests idempotent.

If the same queued sale is sent twice, the server should not create two sales.

Example:

```text
clientId = unique transaction id
```

The server should reject or return the existing transaction when the same `clientId` is submitted again.

---

# 24. Authorization

Authorization must be enforced by the server.

Do not rely only on hiding buttons in Flutter.

The server must validate permissions for:

- Reading records
- Creating records
- Updating records
- Deleting records
- Synchronizing records
- Viewing reports
- Approving transactions

Example roles:

```text
admin
employee
manager
accountant
```

The server should filter delta responses according to the authenticated user's permissions.

A device must not download records merely because the endpoint exists.

---

# 25. Security Rules

Passwords must never be stored as plain text.

Use bcrypt:

```js
const hashedPassword = await bcrypt.hash(password, 10);
```

Verify passwords with:

```js
const isMatch = await bcrypt.compare(
  password,
  user.password,
);
```

Never include passwords in:

- Login responses
- User list responses
- Synchronization responses
- Update responses
- Hive records received from the server
- Logs

Access tokens should be stored carefully.

For higher-security deployments, consider secure storage instead of ordinary shared preferences.

---

# 26. Application Startup

The startup sequence is:

```text
1. Initialize Flutter bindings
2. Initialize HydratedBloc
3. Initialize Hive
4. Load environment variables
5. Create SyncManager
6. Start SyncManager
7. Create and start SyncCoordinator
8. Start the Flutter application
```

The same `SyncManager` instance should be passed to:

- `UserBloc`
- Product Bloc
- Customer Bloc
- Other entity Blocs
- `SyncCoordinator`

Do not create separate managers for each feature.

One manager prevents:

- Duplicate connectivity listeners
- Duplicate synchronization requests
- Conflicting locks
- Multiple timers
- Inconsistent queue processing

---

# 27. Testing Checklist

Each synchronized module should be tested in these situations:

## Online

- Create record online
- Update record online
- Delete record online
- Verify server data
- Verify Hive data
- Verify UI update

## Offline

- Create record offline
- Update record offline
- Delete record offline
- Verify queue item exists
- Verify UI updates immediately
- Restart application
- Verify queue remains available

## Reconnection

- Disable internet
- Create records
- Re-enable internet
- Verify queued operations are uploaded
- Verify queue items are removed after success
- Verify failed operations remain available

## Multiple Devices

- Device A creates a record
- Device B remains open
- Wait for foreground polling
- Verify Device B receives the record
- Verify Hive is updated
- Verify the UI rebuilds

## Soft Delete

- Delete a record on Device A
- Synchronize Device A
- Synchronize Device B
- Verify Device B removes the record
- Verify the server retains the soft-deleted record

## Authentication

- Login successfully
- Restart the application
- Verify dashboard opens
- Logout
- Restart the application
- Verify sign-in opens

## Localization

- Switch to English
- Switch to Kinyarwanda
- Verify all new strings are translated
- Verify no hard-coded user-facing text remains

---

# 28. Development Rules

When implementing a new feature:

1. Define the data model.
2. Decide whether the feature requires offline support.
3. Add the server model.
4. Add the server controller.
5. Add server routes.
6. Add `clientId` if the entity is synchronized.
7. Add `deletedAt` for synchronized entities.
8. Add the Flutter Hive model.
9. Generate Hive adapters.
10. Add the repository.
11. Add Bloc events.
12. Add Bloc states.
13. Add local Hive handlers.
14. Add queue operations.
15. Add synchronization handling.
16. Add the delta endpoint.
17. Add the UI.
18. Add localization keys.
19. Test online behavior.
20. Test offline behavior.
21. Test reconnection.
22. Test multiple-device synchronization.
23. Test role permissions.

---

# 29. Current Synchronization Summary

The current HAJEDI synchronization architecture contains:

```text
Hive local cache
    +
SyncQueue offline operation storage
    +
SyncManager upload and download coordination
    +
SyncCoordinator foreground polling
    +
Connectivity listener
    +
Synchronization cursor
    +
Soft deletion
    +
clientId identity
    +
Hive box watchers
    +
BLoC state updates
```

The key principle is:

```text
The UI works with local data first.
The server synchronizes in the background.
```

This allows the application to remain useful during network interruptions while still allowing different users to receive new data automatically.

---

# 30. Final Architecture

```text
Flutter UI
    |
    v
BLoC
    |
    +--------------------+
    |                    |
    v                    v
Hive local cache     SyncQueue
    |                    |
    v                    v
UI updates          SyncManager
                         |
                         +-- Connectivity check
                         +-- Upload pending operations
                         +-- Pull delta changes
                         +-- Apply changes to Hive
                         |
                         v
                   REST API
                         |
                         v
                      MongoDB
```

For every future module, preserve this architecture:

```text
Local-first UI
    +
Stable clientId
    +
Hive cache
    +
Offline queue
    +
Delta synchronization
    +
Soft deletion
    +
Foreground polling
    +
Server authorization
```