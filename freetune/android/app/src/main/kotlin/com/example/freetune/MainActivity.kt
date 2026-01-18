package com.example.freetune

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.exoplayer2.MediaItem
import android.net.Uri

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.freetune/download"
    private lateinit var downloadTracker: DownloadTracker

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize DownloadTracker
        downloadTracker = DownloadTracker(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "download" -> {
                    val url = call.argument<String>("url")
                    val id = call.argument<String>("id")
                    if (url != null && id != null) {
                        val mediaItem = MediaItem.Builder()
                            .setUri(Uri.parse(url))
                            .setMediaId(id)
                            .build()
                        downloadTracker.startDownload(mediaItem)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "URL or ID is null", null)
                    }
                }
                "remove" -> {
                    val id = call.argument<String>("id")
                    if (id != null) {
                        downloadTracker.removeDownloadById(id)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "ID is null", null)
                    }
                }
                "check_download" -> {
                     // Check if downloaded
                     // Not implemented yet in Detail, but could check DownloadManager
                     result.notImplemented()
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
