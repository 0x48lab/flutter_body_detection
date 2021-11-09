package com.u0x48lab.body_detection

import com.google.android.gms.tasks.OnFailureListener
import com.google.android.gms.tasks.OnSuccessListener
import com.google.android.gms.tasks.Task
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.pose.Pose
import com.google.mlkit.vision.pose.PoseDetection
import com.google.mlkit.vision.pose.PoseDetector
import com.google.mlkit.vision.pose.accurate.AccuratePoseDetectorOptions

class MLKitPoseDetector(stream: Boolean) {
    private val detector: PoseDetector
    private var task: Task<Pose>? = null

    init {
        // Accurate pose detector on static images, when depending on the pose-detection-accurate sdk
        val mode = if (stream) AccuratePoseDetectorOptions.STREAM_MODE else AccuratePoseDetectorOptions.SINGLE_IMAGE_MODE
        val options = AccuratePoseDetectorOptions.Builder()
            .setDetectorMode(mode)
            .build()

        detector = PoseDetection.getClient(options)
    }

    fun process(image: InputImage, success: OnSuccessListener<Pose>, error: OnFailureListener): Boolean {
        if (task != null) return false

        task = detector.process(image)
            .addOnSuccessListener {
                success.onSuccess(it)
                task = null
            }
            .addOnFailureListener {
                error.onFailure(it)
                task = null
            }

        return true
    }
}