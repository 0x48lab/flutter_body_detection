package com.u0x48lab.body_detection

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageProxy
import com.google.android.gms.tasks.OnFailureListener
import com.google.android.gms.tasks.OnSuccessListener
import com.google.mlkit.vision.common.InputImage
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

/** BodyDetectionPlugin */
class BodyDetectionPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
  private lateinit var context: Context
  private lateinit var channel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private var eventSink: EventChannel.EventSink? = null
  private var cameraSession: CameraSession? = null
  private var poseDetectionEnabled = false
  private var bodyMaskDetectionEnabled = false
  private val poseDetector = MLKitPoseDetector(true)
  private var lensFacing = CameraSelector.LENS_FACING_FRONT
  private val selfieSegmenter = MLKitSelfieSegmenter()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext

    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.0x48lab/body_detection")
    channel.setMethodCallHandler(this)

    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.0x48lab/body_detection/image_stream")
    eventChannel.setStreamHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    when (call.method) {
      "detectImagePose" -> {
        val imageData = call.argument("pngImageBytes") as ByteArray?
        val bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData?.size ?: 0)
        val image = InputImage.fromBitmap(bitmap, 0)
        MLKitPoseDetector(false)
          .process(image, OnSuccessListener {
            result.success(it.toMap())
          }, OnFailureListener {
            result.error("PoseDetectorError", it.localizedMessage, it.stackTrace)
          })
      }
      "detectImageSegmentationMask" -> {
        val imageData = call.argument("pngImageBytes") as ByteArray?
        val bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData?.size ?: 0)
        val image = InputImage.fromBitmap(bitmap, 0)
        MLKitSelfieSegmenter()
          .process(image, OnSuccessListener {
            result.success(it.toMap())
          }, OnFailureListener {
            result.error("SelfieSegmenterError", it.localizedMessage, it.stackTrace)
          })
      }
      "enablePoseDetection" -> {
        poseDetectionEnabled = true
        result.success(null)
      }
      "disablePoseDetection" -> {
        poseDetectionEnabled = false
        result.success(null)
      }
      "enableBodyMaskDetection" -> {
        bodyMaskDetectionEnabled = true
        result.success(null)
      }
      "disableBodyMaskDetection" -> {
        bodyMaskDetectionEnabled = false
        result.success(null)
      }
      "startCameraStream" -> {
        val session = CameraSession(context, lensFacing)
        session.start { imageProxy, rotationDegrees ->
          handleCameraFrame(imageProxy, rotationDegrees)
        }
        cameraSession = session
        result.success(true)
      }
      "stopCameraStream" -> {
        cameraSession?.stop()
        cameraSession = null
        result.success(true)
      }
      "switchCamera" -> {
        val isFront = call.argument("lensFacing") as String?
        lensFacing =
          if (isFront?.equals("FRONT") == true) CameraSelector.LENS_FACING_BACK else CameraSelector.LENS_FACING_BACK
        result.success(true)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  @SuppressLint("UnsafeExperimentalUsageError", "UnsafeOptInUsageError")
  private fun handleCameraFrame(imageProxy: ImageProxy, rotationDegrees: Int) {
    val bitmap = BitmapUtils.getBitmap(imageProxy, true)
    val width = bitmap?.width ?: 0
    val height = bitmap?.height ?: 0
    val output = ByteArrayOutputStream()
    bitmap?.compress(Bitmap.CompressFormat.JPEG, 60, output)

    imageProxy.close()

    eventSink?.success(mapOf(
      "type" to "image",
      "image" to output.toByteArray(),
      "width" to width,
      "height" to height
    ))

    if ((poseDetectionEnabled || bodyMaskDetectionEnabled) && bitmap != null) {
      val image = InputImage.fromBitmap(bitmap, 0)
      var count = 2

      fun imageRefDown() {
        count -= 1
        if (count == 0) {
          bitmap.recycle()
        }
      }

      if (poseDetectionEnabled) {
        val processed = poseDetector.process(image, OnSuccessListener { pose ->
          eventSink?.success(mapOf(
            "type" to "pose",
            "pose" to pose.toMap()
          ))

          imageRefDown()
        }, OnFailureListener { _ ->
          eventSink?.success(mapOf(
            "type" to "pose",
            "pose" to null
          ))

          imageRefDown()
        })
        if (!processed) imageRefDown()
      } else {
        imageRefDown()
      }

      if (bodyMaskDetectionEnabled) {
        val processed = selfieSegmenter.process(image, OnSuccessListener { mask ->
          eventSink?.success(mapOf(
            "type" to "mask",
            "mask" to mask.toMap()
          ))

          imageRefDown()
        }, OnFailureListener { _ ->
          eventSink?.success(mapOf(
            "type" to "mask",
            "mask" to null
          ))

          imageRefDown()
        })
        if (!processed) imageRefDown()
      } else {
        imageRefDown()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }
}
