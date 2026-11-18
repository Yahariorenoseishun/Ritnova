import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RitnovaScreen extends StatelessWidget {
  const RitnovaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const Scaffold(body: Center(child: Text("Esta pantalla solo se ve en Android.")));
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              const AndroidView(
                viewType: 'com.example.ritnova/native_view',
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  onPressed: () => Navigator.pop(context), 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}