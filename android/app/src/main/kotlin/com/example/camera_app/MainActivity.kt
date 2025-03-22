package com.example.camera_app

import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import android.content.Context
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.camera_app/mediastore" // Канал для связи с Flutter

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Настройка платформенного канала
        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveImage") {
                val imagePath = call.argument<String>("imagePath")
                if (imagePath != null) {
                    saveImageToGallery(imagePath, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Image path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    // Метод для сохранения изображения в галерею
    private fun saveImageToGallery(imagePath: String, result: MethodChannel.Result) {
        val imageFile = File(imagePath)
        val contentValues = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, imageFile.name) // Имя файла
            put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg") // MIME тип
            put(MediaStore.Images.Media.DATE_ADDED, System.currentTimeMillis() / 1000) // Дата добавления
            put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/CameraApp") // Путь относительно внешнего хранилища
        }

        val resolver = contentResolver
        var uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)

        // Для Android 10 и выше использует ContentResolver для записи изображения
        if (uri != null) {
            try {
                val inputStream = FileInputStream(imageFile)
                resolver.openOutputStream(uri)?.use { outputStream ->
                    val buffer = ByteArray(1024)
                    var length: Int
                    while (inputStream.read(buffer).also { length = it } != -1) {
                        outputStream.write(buffer, 0, length)
                    }
                }
                result.success("Image saved to gallery")
            } catch (e: IOException) {
                Log.e("MainActivity", "Error saving image", e)
                result.error("SAVE_ERROR", "Failed to save image", e.message)
            }
        } else {
            result.error("SAVE_ERROR", "Failed to get content URI", null)
        }
    }
}
