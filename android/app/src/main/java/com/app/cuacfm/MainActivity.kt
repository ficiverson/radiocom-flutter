package com.app.cuacfm;

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.StrictMode
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import xyz.luan.audioplayers.AudioService

class MainActivity : FlutterActivity() {

    companion object {
        private val CHANGE_LOCALE = "cuacfm.flutter.io/changeScreen"
    }

    private var changeScreen: MethodChannel.Result? = null
    private var screens = mutableListOf<String>()
    private var currentScreen: String = ""
    private var tempCurrentScreen: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT > 16) {
            val policy = StrictMode.ThreadPolicy.Builder().permitAll().build()
            StrictMode.setThreadPolicy(policy)
        }

    }

    override fun configureFlutterEngine(flutterEngine : FlutterEngine) {
        AudioService.registerActivity(flutterEngine)

        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val runningAppProcesses = activityManager.runningAppProcesses
        if (runningAppProcesses != null) {
            val importance = runningAppProcesses[0].importance
            if (importance <= ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
                val intent = Intent(this, AudioService::class.java)
                Handler().postDelayed({
                    startService(intent)
                }, 200)
            }
        }

        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANGE_LOCALE).setMethodCallHandler { call, result ->
            if (call.method == "changeScreen") {
                changeScreen = result
                currentScreen = call.argument<String>("currentScreen") as String
                val isCloseEvent = call.argument<Boolean>("close") as Boolean
                if (!isCloseEvent) {
                    screens.add(currentScreen)
                } else {
                    if(currentScreen == "all_podcast"){
                        screens.removeAll { it == "all_podcast_search" }
                    }
                    screens.removeAll { it == currentScreen }
                    screens.removeAll { it == tempCurrentScreen && it != "main" }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onBackPressed() {
        if (screens.size == 1) {
            AudioService.stopComponent(this, this)
        } else {
            screens.removeAll { it == currentScreen }
            if (screens.isNotEmpty()) {
                currentScreen = screens.last()
                tempCurrentScreen = screens.last()
            } else {
                currentScreen = ""
                tempCurrentScreen = ""
            }

        }
        super.onBackPressed();
    }
}
