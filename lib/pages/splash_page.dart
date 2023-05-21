import 'package:flutter_svg/flutter_svg.dart';
import 'package:urban_logisitics/constants.dart';
import 'package:flutter/material.dart';

/// Initial loading route of the app.
///
/// Used to load required information before starting the app (auth).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _redirectCalled = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 4000));
    if (_redirectCalled || !mounted) {
      return;
    }

    _redirectCalled = true;
    final session = supabase.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    const String iconPath = 'assets/truck.svg';
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(Colors.purple, BlendMode.srcIn),
                semanticsLabel: 'Truck Icon',
              ),
              const SizedBox(height: 20),
              const Text(
                'Urban Logistics',
                style: TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 20),
              CircularProgressIndicator()
            ],
          )),
    ));
  }
}
