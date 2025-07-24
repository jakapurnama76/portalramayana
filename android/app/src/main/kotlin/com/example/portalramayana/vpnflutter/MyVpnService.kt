package com.example.portalramayana

import android.app.Service
import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log

class MyVpnService : VpnService() {
    private var vpnInterface: ParcelFileDescriptor? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val builder = Builder()
        val server = intent?.getStringExtra("server") ?: ""
        val username = intent?.getStringExtra("username") ?: ""
        val password = intent?.getStringExtra("password") ?: ""
        val psk = intent?.getStringExtra("psk") ?: ""

        // Ini hanya dummy VPN config (belum benar-benar connect)
        vpnInterface = builder
            .addAddress("10.0.0.2", 32)
            .addRoute("0.0.0.0", 0)
            .setSession("MyVPN")
            .establish()

        Log.d("VPN", "VPN interface established to $server")
        return START_STICKY
    }

    override fun onDestroy() {
        vpnInterface?.close()
        super.onDestroy()
    }
}
