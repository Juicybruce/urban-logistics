## REPO

Only merge working code into main, keep all feature development on a 'feat-<feature-name>' branch and all partial work on your own 'dev-<name>'

## FLUTTER

Installation instructions for Flutter: https://docs.flutter.dev/get-started/install

If on MacOS, you can use Homebrew to install fvm to allow easier mamangement of different versions (not necessary):
-Install Homebrew
-Install fvm using Homebrew (brew tap leoafarias/fvm && brew install fvm)
-Install your wanted flutter version through fvm (fvm install stable)
-append the installation to your PATH (export PATH=$PATH:"/Users/[USER_HERE]/fvm/versions/stable/bin")

Run (flutter doctor) and follow all instructions to finalise dev environment

## Project

Files are under the root folder urban_logisitics, run `flutter pub get` from within that working directory to fetch all dependencies to your local machine

F5 will run the code, you can select what simulator (if any) to use in the bottom right (in VSCode)

Flutter enables Stateful Hot Reload by default, save any changes while the app is running and the changes will be reflected without needed to rebuild (for more into see https://docs.flutter.dev/get-started/test-drive)

You will want to use `--dart-define=SUPABASE_URL=<add url> --dart-define=SUPABASE_ANON_KEY=<add key>` flags when running the project in order to have the correct credentials for the app to make requests to our databases, eg:
flutter run lib/main.dart --dart-define=SUPABASE_URL=www.supabase.url --dart-define=SUPABASE_ANON_KEY=key-value

## enabling auto-formatting

- install the flutter extension.
- append or modify these lines in the settings.json file:

"[dart]": {
"editor.defaultFormatter": "Dart-Code.dart-code",
"editor.formatOnSave": true,
}

# Supabase

The Supabase flutter client is a dependency and has been imported in ./lib/main.dart

- The URL and ANON KEY are held as constants that are accessed from the environment (see ./lib/constants.dart) **DO NOT COMMIT THEM**, use the build and run command above to correctly source the url and key

See https://supabase.com/docs/reference/dart/start for documentation on how to use this client

# mapbox with flutter_map

to use mapbox with flutter_map, you will need to change the mapbox token and style id to the class AppConstants in ./lib/constants.dart
mapBoxStyleId is the style id of the mapbox map you want to use (see https://docs.mapbox.com/api/maps/#styles)
mapBoxToken is the token for the mapbox account you want to use (see https://docs.mapbox.com/help/getting-started/access-tokens/)

see https://pub.dev/packages/flutter_map for documentation on how to use flutter_map
and https://docs.fleaflet.dev/tile-servers/using-mapbox for documentation on how to use mapbox with flutter_map

class AppConstants {
static const String mapBoxAccessToken = '**your mapbox token here**'
static const String mapBoxStyleId = '**your mapbox style id here**';
static late final myLocation = LatLng(51.5090214, -0.1982948);
}

## Getting Started - Flutter official

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
