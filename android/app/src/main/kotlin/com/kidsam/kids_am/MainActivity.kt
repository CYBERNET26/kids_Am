package com.kidsam.kids_am

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.kidsam.kids_am/app_installer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "installApk") {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    val file = File(filePath)
                    if (file.exists()) {
                        try {
                            // Permitir lectura a nivel de archivo para instaladores del sistema
                            file.setReadable(true, false)

                            // Verificar permiso de orígenes desconocidos en Android 8.0+
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                if (!context.packageManager.canRequestPackageInstalls()) {
                                    val manageIntent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                                        data = Uri.parse("package:${context.packageName}")
                                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                    }
                                    context.startActivity(manageIntent)
                                    result.error(
                                        "PERMISSION_REQUIRED",
                                        "Por favor autoriza a Kids Am a instalar actualizaciones en la pantalla que se acaba de abrir.",
                                        null
                                    )
                                    return@setMethodCallHandler
                                }
                            }

                            val uri: Uri = FileProvider.getUriForFile(
                                context,
                                "${context.packageName}.fileprovider",
                                file
                            )

                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                setDataAndType(uri, "application/vnd.android.package-archive")
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                putExtra(Intent.EXTRA_NOT_UNKNOWN_SOURCE, true)
                            }

                            // Conceder explícitamente permisos a todas las apps que puedan abrir el instalador
                            val resolveInfoList = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                context.packageManager.queryIntentActivities(
                                    intent,
                                    PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_DEFAULT_ONLY.toLong())
                                )
                            } else {
                                @Suppress("DEPRECATION")
                                context.packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
                            }

                            for (resolveInfo in resolveInfoList) {
                                val packageName = resolveInfo.activityInfo.packageName
                                context.grantUriPermission(
                                    packageName,
                                    uri,
                                    Intent.FLAG_GRANT_READ_URI_PERMISSION
                                )
                            }

                            context.startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("INSTALL_ERROR", e.localizedMessage, null)
                        }
                    } else {
                        result.error("FILE_NOT_FOUND", "El archivo APK no existe en: $filePath", null)
                    }
                } else {
                    result.error("INVALID_PATH", "Ruta de archivo APK nula", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
