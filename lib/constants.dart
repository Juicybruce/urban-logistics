import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

/// Environment variables and shared app constants.
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
class AppConstants {
  static const String mapBoxAccessToken = 'pk.eyJ1IjoibGVpZ2gzMjExIiwiYSI6ImNsbDM4Zzl6MDBkb3czZHBydmVvazMwbHYifQ.gsyuyH317PYisMD96fxAig';
  static const String mapBoxStyleId = 'cll38liz100ey01pm46mx7slt';
  static late final myLocation = LatLng(51.5090214, -0.1982948);



}

class ColorConstants{
 static final Color completeColor = Colors.greenAccent.shade200;
 static final Color cancelledColor = Colors.redAccent.shade100;
 static final Color merchantListColor = Colors.lightBlue.shade200;
 static final Color driverListColor = Colors.amber.shade600;
}