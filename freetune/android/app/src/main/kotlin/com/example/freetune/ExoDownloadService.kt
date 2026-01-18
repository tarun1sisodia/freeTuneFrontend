package com.example.freetune

import android.app.Notification
import com.google.android.exoplayer2.offline.Download
import com.google.android.exoplayer2.offline.DownloadManager
import com.google.android.exoplayer2.offline.DownloadService
import com.google.android.exoplayer2.scheduler.PlatformScheduler
import com.google.android.exoplayer2.ui.DownloadNotificationHelper
import com.google.android.exoplayer2.util.Util

class ExoDownloadService : DownloadService(
    FOREGROUND_NOTIFICATION_ID,
    DEFAULT_FOREGROUND_NOTIFICATION_UPDATE_INTERVAL,
    CHANNEL_ID,
    R.string.exo_download_notification_channel_name,
    /* channelDescriptionResourceId= */ 0
) {

    override fun getDownloadManager(): DownloadManager {
        // This will be a singleton that we access via a helper or App class
        // For simplicity in this integration, we assume a static accessor in MainActivity 
        // or we move the singleton creation here? 
        // Best practice: Have a minimal Application class.
        return DemoUtil.getDownloadManager(this)
    }

    override fun getScheduler(): PlatformScheduler? {
        return if (Util.SDK_INT >= 21) PlatformScheduler(this, JOB_ID) else null
    }

    override fun getForegroundNotification(
        downloads: MutableList<Download>,
        notMetRequirements: Int
    ): Notification {
        return DemoUtil.getDownloadNotificationHelper(this)
            .buildProgressNotification(
                this,
                R.drawable.exo_icon_circular_play, // Ensure this icon exists or use generic
                /* contentIntent= */ null,
                /* message= */ null,
                downloads,
                notMetRequirements
            )
    }

    companion object {
        const val CHANNEL_ID = "download_channel"
        const val FOREGROUND_NOTIFICATION_ID = 1
        const val JOB_ID = 1
    }
}
