# hajedi

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Android GitHub Actions builds

The `Mobile Android build` workflow builds a release APK when code is pushed to
`dev` or `main`. You can also run it manually from the Actions tab, selecting
either branch.

Configure these repository variables in **Settings > Secrets and variables >
Actions > Variables**:

| Variable | Value to use |
| --- | --- |
| `API_URL_DEV` | The dev API URL currently listed in the local `.env` file |
| `API_URL` | The production API URL currently listed in the local `.env` file |

The workflow writes the matching value into `mobile/.env` before building. The
local `.env` file is ignored by Git, so it does not need to be committed. The
completed APK is available as a workflow artifact.
