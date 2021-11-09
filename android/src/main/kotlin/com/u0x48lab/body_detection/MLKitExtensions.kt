package com.u0x48lab.body_detection

import com.google.mlkit.vision.common.PointF3D
import com.google.mlkit.vision.pose.Pose
import com.google.mlkit.vision.pose.PoseLandmark
import com.google.mlkit.vision.segmentation.SegmentationMask

fun Pose.toMap() = mapOf(
    "landmarks" to allPoseLandmarks.map { it.toMap() }
)

fun PoseLandmark.toMap() = mapOf(
    "inFrameLikelihood" to inFrameLikelihood.toDouble(),
    "position" to position3D.toMap(),
    "type" to landmarkType
)

fun PointF3D.toMap() = mapOf(
    "x" to x.toDouble(),
    "y" to y.toDouble(),
    "z" to z.toDouble()
)

fun SegmentationMask.toMap(): Map<String, Any> {
    val data = mutableListOf<Double>()
    for (y in 0 until height) {
        for (x in 0 until width) {
            val foregroundConfidence = buffer.float
            data.add(foregroundConfidence.toDouble())
        }
    }

    return mapOf(
        "buffer" to data.toDoubleArray(),
        "width" to width,
        "height" to height
    )
}