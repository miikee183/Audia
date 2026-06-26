package com.audia.audia

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // installSplashScreen() es necesario en Android 12+ para que el sistema
        // aplique nuestro tema (fondo negro + ícono transparente) en lugar del
        // splash por defecto con el ícono de la app. Lo descartamos de inmediato.
        installSplashScreen()
        super.onCreate(savedInstanceState)
    }
}
