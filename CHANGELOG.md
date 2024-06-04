## 0.5.1 (Jun 04, 2024)

### Bug Fixes

- Bug Fixes
    - Identify user custom data encoder
- Additional Notes
    - No additional notes in this version.

## 0.5.1 (May 03, 2024)

### Bug Fixes

- Bug Fixes
  - Backward compatibility for dependent packages;
  - `openNotification()` in the request submission contract.
- Additional Notes
  - No additional notes in this version.

## 0.5.0 (April 30, 2024)

### New Features

- Added the following methods:
  - `setUser()`: Method to save user data before an identify.
  - `removeMobileToken()`: Method to remove a user's token.
  - `initializePushNotificationService()`: Method to initialize the mobile push notification service.
  - `setAndroidDetails()`: Method to customize the mobile push notification service on Android.
  - `setIosDetails()`: Method to customize the mobile push notification service on iOS.
- Changes
  - Removed setUserAgent method, which is now generated automatically.
  - Deprecated setUserId method.
- Bug Fixes
  - No bug fixes in this version.
- Additional Notes
  - No additional notes in this version.

## 0.4.0 (November 23, 2023)

### New Features

- Added the following methods:
  - `registryMobileToken()`: Method to register the mobile token for the user.
  - `openNotification()`: Method to notify of the opening of a mobile notification.
- Changes
- Removed encoding attribute from all requests.
- Removed json.encode from the data attribute in the identifyUser() method.
- `identifyUser()` method returning the request result. (changed to Future<http.Response>).
- Bug Fixes
  - No bug fixes in this version.
- Additional Notes
  - No additional notes in this version.

## 0.3.0 (October 26, 2023)

### New Features

- Event storage while not having a registered userID.
- Sending stored events as soon as a userID is registered.
- Changes
  - No changes in this version.
- Bug Fixes
  - No bug fixes in this version.
- Additional Notes
  - No additional notes in this version.

## 0.2.0 (October 10, 2023)

### Refactor

- Changes
  - Renamed registerUser() method to identifyUser().
  - Documentation improvements.
- Bug Fixes
  - No bug fixes in this version.
- Additional Notes
  - No additional notes in this version.

## 0.1.1 (October 2, 2023)

### Refectory

- Changes
  - Removed print from methods.
  - Exception handling in methods that contain requests.
- Bug Fixes
  - No bug fixes in this version.
- Additional Notes
  - No additional notes in this version.

## 0.1.0 (October 2, 2023)

### New Features

- Added the following methods:
- initialize: Method to initialize the library.
- identify: Allows you to save user data.
- registerUser: Allows user registration.
- trackEvent: Allows event registration.
- setUserId: Allows you to set the user ID.
- setUserAgent: Allows you to set the User-Agent.
