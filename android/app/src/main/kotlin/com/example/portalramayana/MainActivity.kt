package com.example.portalramayana

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "vpn_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "connectVpn" -> {
                    val server = call.argument<String>("server") ?: ""
                    val username = call.argument<String>("username") ?: ""
                    val password = call.argument<String>("password") ?: ""
                    val psk = call.argument<String>("psk") ?: ""

                    Log.d("VPN", "Connecting to: $server with user $username")

                    val intent = Intent(this, MyVpnService::class.java).apply {
                        putExtra("server", server)
                        putExtra("username", username)
                        putExtra("password", password)
                        putExtra("psk", psk)
                    }
                    startService(intent)

                    result.success("VPN service started")
                }

                "disconnectVpn" -> {
                    val intent = Intent(this, MyVpnService::class.java)
                    stopService(intent)
                    result.success("VPN service stopped")
                }

                else -> result.notImplemented()
            }
        }
    }
}
