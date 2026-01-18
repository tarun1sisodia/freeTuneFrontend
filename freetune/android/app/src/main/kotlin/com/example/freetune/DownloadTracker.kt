package com.example.freetune

import android.content.Context
import android.net.Uri
import android.widget.Toast
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.offline.DownloadHelper
import com.google.android.exoplayer2.offline.DownloadRequest
import com.google.android.exoplayer2.offline.DownloadService
import com.google.android.exoplayer2.util.Log
import com.google.android.exoplayer2.util.Util
import java.io.IOException

class DownloadTracker(context: Context) {

    private val context: Context = context.applicationContext
    private val downloadManager = DemoUtil.getDownloadManager(context)

    fun startDownload(mediaItem: MediaItem) {
        val downloadHelper = DownloadHelper.forMediaItem(
            context,
            mediaItem,
            null,
            DemoUtil.getDownloadManager(context).dataSourceFactory
        )

        downloadHelper.prepare(object : DownloadHelper.Callback {
            override fun onPrepared(helper: DownloadHelper) {
                // Select highest quality or default
                // For HLS, this usually defaults to adaptive or specific tracks.
                // We'll trust the default selection but ensure we select period 0 at least.
                for (i in 0 until helper.periodCount) {
                    // This sets the track selection to the default parameters (usually highest quality or adaptive)
                    val trackSelectionParameters = helper.getTrackSelectionParameters(i)
                    downloadHelper.clearTrackSelections(i)
                    downloadHelper.addTrackSelection(i, trackSelectionParameters)
                }
                
                val downloadRequest: DownloadRequest = helper.getDownloadRequest(Util.getUtf8Bytes(mediaItem.mediaId))
                startDownload(downloadRequest)
            }

            override fun onPrepareError(helper: DownloadHelper, e: IOException) {
                Log.e("DownloadTracker", "Failed to start download", e)
                Toast.makeText(context, "Download failed to start", Toast.LENGTH_SHORT).show()
            }
        })
    }
    
    fun removeDownload(uri: Uri) {
       val download = downloadManager.currentDownloads.find { it.request.uri == uri }
       if (download != null) {
           DownloadService.sendRemoveDownload(
               context,
               ExoDownloadService::class.java,
               download.request.id,
               /* foreground= */ false
           )
       } else {
           // Fallback: search by checking logic or just assume ID is known?
           // Actually, if we use the ID as the key, we should pass ID.
           // For now, let's assume MethodChannel passes the URL and we find getting it hard without ID.
           // We will rely on the caller passing the ID or hash it if needed.
       }
    }
    
    fun removeDownloadById(id: String) {
        DownloadService.sendRemoveDownload(
            context,
            ExoDownloadService::class.java,
            id,
            /* foreground= */ false
        )
    }

    private fun startDownload(downloadRequest: DownloadRequest) {
        DownloadService.sendAddDownload(
            context,
            ExoDownloadService::class.java,
            downloadRequest,
            /* foreground= */ false
        )
    }
}
