import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

/// Environment variables and shared app constants.
//Supabase
abstract class Constants {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pjmmfyhifblvbqgnllfc.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqbW1meWhpZmJsdmJxZ25sbGZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODIzODQzODMsImV4cCI6MTk5Nzk2MDM4M30.uqz2wJg5Tf6g3_b3uIad1IE9CDJx8sjhudreHCjgJWA',
  );
}

final supabase = Supabase.instance.client;

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }


}
//Mapbox
class AppConstants {
  static const String mapBoxAccessToken = ''; //add mapbox access token here before mapbox will work
  static const String mapBoxStyleId = ''; //add mapbox style id here before mapbox will work
  static late final myLocation = LatLng(51.5090214, -0.1982948);



}
// Some colour constants used throughout the app
class ColorConstants{
  static final Color completeColor = Colors.greenAccent.shade200;
  static final Color cancelledColor = Colors.redAccent.shade100;
  static final Color merchantListColor = Colors.lightBlue.shade200;
  static final Color driverListColor = Colors.blue.shade600;
  static final Color inProgressColor = Colors.amber.shade300;
  static final Color postedColor = Colors.blue.shade600;
  static final Color responseRequired = Colors.red.shade700;
  static final Color postedPin = Colors.blue.shade800;
  static final Color AcceptedPin = Colors.deepOrange;
  static final Color inProgressPin = Colors.purple;
}