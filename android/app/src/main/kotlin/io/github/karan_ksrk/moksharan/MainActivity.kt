package io.github.karan_ksrk.moksharan

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var assetPacks: AssetPackChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        assetPacks = AssetPackChannel(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        assetPacks?.dispose()
        assetPacks = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
