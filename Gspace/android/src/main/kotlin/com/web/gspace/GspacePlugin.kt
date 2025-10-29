package com.web.gspace

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** GspacePlugin */
class GspacePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "gspace")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${Build.VERSION.RELEASE}")
            }
            "openBrowser" -> {
                val url = call.argument<String>("url")
                if (url != null) {
                    openBrowser(url)
                    result.success(true)
                } else {
                    result.error("INVALID_URL", "URL is null", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun openBrowser(url: String) {
        Log.d("WebViewPage", "GspacePlugin openBrowser $url")
        try {
            var intent: Intent? = if (url.startsWith("intent")) {
                Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
            } else {
                Intent(Intent.ACTION_VIEW, Uri.parse(url))
            }

            intent?.apply {
//                if (isHuawei()) {
//                    setPackage(getDefaultBrowser())
//                }
                addCategory(Intent.CATEGORY_BROWSABLE)
                component = null
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }

            context.startActivity(intent)
        } catch (e: Exception) {
            Log.e("GspacePlugin", "openBrowser error: $e")
        }
    }

    private fun isHuawei(): Boolean {
        return Build.MANUFACTURER.equals("huawei", ignoreCase = true)
    }

    private fun getDefaultBrowser(): String? {
        // TODO: 可在这里实现获取系统默认浏览器的逻辑
        return null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
