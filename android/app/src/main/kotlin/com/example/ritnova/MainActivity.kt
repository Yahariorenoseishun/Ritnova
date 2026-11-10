package com.example.ritnova

import io.flutter.embedding.android.FlutterFragmentActivity 
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() { 
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "com.example.ritnova/native_view",
            RitnovaViewFactory()
        )
    }
}