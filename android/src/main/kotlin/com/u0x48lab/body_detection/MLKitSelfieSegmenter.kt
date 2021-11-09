package com.u0x48lab.body_detection

import com.google.android.gms.tasks.OnFailureListener
import com.google.android.gms.tasks.OnSuccessListener
import com.google.android.gms.tasks.Task
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.pose.Pose
import com.google.mlkit.vision.pose.PoseDetection
import com.google.mlkit.vision.pose.PoseDetector
import com.google.mlkit.vision.pose.accurate.AccuratePoseDetectorOptions
import com.google.mlkit.vision.segmentation.Segmentation
import com.google.mlkit.vision.segmentation.SegmentationMask
import com.google.mlkit.vision.segmentation.Segmenter
import com.google.mlkit.vision.segmentation.selfie.SelfieSegmenterOptions

class MLKitSelfieSegmenter {
    private val segmenter: Segmenter
    private var task: Task<SegmentationMask>? = null

    init {
        val options = SelfieSegmenterOptions.Builder()
            .setDetectorMode(SelfieSegmenterOptions.STREAM_MODE)
            .enableRawSizeMask()
            .build()

        segmenter = Segmentation.getClient(options)
    }

    fun process(image: InputImage, success: OnSuccessListener<SegmentationMask>, error: OnFailureListener): Boolean {
        if (task != null) return false

        task = segmenter.process(image)
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