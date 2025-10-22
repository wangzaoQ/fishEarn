package com.example.fish.fish_earn

import io.flutter.embedding.android.FlutterActivity
import com.fish.FheaPlugin;
import io.flutter.embedding.engine.FlutterEngine
import android.os.Bundle
import android.util.Log
import android.annotation.SuppressLint
class MainActivity : FlutterActivity(){
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(FheaPlugin()) // 手动注册
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("FlutterDebug", "MainActivity onCreate, intent = $intent")
    }

}
