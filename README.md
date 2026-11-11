# Malmö Helps

Malmö Helps is an iOS app I built for volunteers supporting Ukrainian refugees in Sweden. It helps volunteers coordinate activities, record attendance, and prepare monthly reports.

[View on the App Store](https://apps.apple.com/se/app/malm%C3%B6-helps/id1644551335)

## Features

- Register participants and organize household records.
- Create and browse activities, then record attendance for a selected session.
- Generate monthly participant and activity reports and share them as CSV files.
- Adapt the available workflows to the signed-in volunteer’s role.

## Code overview

The app uses SwiftUI and Combine with Firebase Authentication, Cloud Firestore, and Cloud Functions. The Xcode project manages dependencies through Swift Package Manager.

- [Views](MalmoHelps/View) and [view models](MalmoHelps/ViewModel) handle the volunteer workflows and screen state.
- [Services](MalmoHelps/Service) handle Firestore access and calls to the reporting backend.

## Open in Xcode

1. Open `MalmoHelps.xcodeproj` and select the `MalmoHelps` scheme. The app target is configured for iOS 16.0 or later.
2. Let Xcode resolve Swift package dependencies.
3. For local development, set your development team and bundle identifier, then use the `GoogleService-Info.plist` and sign-in settings for your own Firebase development project.

Attendance and reporting require a compatible Firestore schema, access rules, and deployed Cloud Functions. The server-side setup lives outside this repository. Use synthetic participant records for local development.
