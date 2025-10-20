package com.fish;
import com.fish.FishRiskManager;

import android.content.Context;

import androidx.annotation.NonNull;

import java.util.Map;

import cn.shuzilm.core.Listener;
import cn.shuzilm.core.Main;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;



public class ZxcvPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "zxcv");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    final String method = call.method;
    //TODO:修改下面所有的方法名
    switch (method) {
      case "root":
        result.success(FishRiskManager.isAbnormalEnv() || FishRiskManager.isXposed());
        break;
      case "vpn":
        result.success(FishRiskManager.isVpn());
        break;
      case "sim":
        result.success(FishRiskManager.isSim(context));
        break;
      case "simulator":
        result.success(FishRiskManager.isEmulator() || FishRiskManager.isEmulator2());
        break;
      case "store":
        result.success("com.android.vending".contentEquals(FishRiskManager.getInstaller(context)));
        break;
      case "developer":
        result.success(FishRiskManager.isDevModel(context) || FishRiskManager.isDebug(context));
        break;
      case "installer":
        result.success(FishRiskManager.getInstaller(context));
        break;
      case "initNumberUnit":
        Main.init(context, (String)call.arguments, false);
        result.success(true);
        break;
      case "getNumberUnitID":
        final Map<String, String> arguments = (Map<String, String>)call.arguments;
        Main.getQueryID(context, arguments.get("channel"), arguments.get("message"), false, new Listener() {
          @Override
          public void handler(String s) {
            result.success(s);
          }
        });
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
