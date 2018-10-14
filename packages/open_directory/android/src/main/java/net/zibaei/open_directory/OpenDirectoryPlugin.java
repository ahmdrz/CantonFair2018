package net.zibaei.open_directory;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

import java.io.File;
import java.util.HashMap;

public class OpenDirectoryPlugin implements MethodChannel.MethodCallHandler {
    private final Activity activity;

    public static void registerWith(PluginRegistry.Registrar registrar) {
        MethodChannel channel =
                new MethodChannel(registrar.messenger(), "net.zibaei.flutter/open_directory");
        OpenDirectoryPlugin instance = new OpenDirectoryPlugin(registrar.activity());
        channel.setMethodCallHandler(instance);
    }

    private OpenDirectoryPlugin(Activity activity) {
        this.activity = activity;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        String uri = ((HashMap) call.arguments()).get("uri").toString();        
        if (call.method.equals("canOpen")) {
            canOpen(uri, result);
        } else if (call.method.equals("openDirectory")) {
            openDirectory(uri, result);
        } else {
            result.notImplemented();
        }
    }

    private void openDirectory(String uri, MethodChannel.Result result) {
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(uri));
        intent.setDataAndType(Uri.parse(uri), "resource/folder");
        activity.startActivity(intent);
        result.success(null);
    }

    private void canOpen(String uri, MethodChannel.Result result) {
        boolean canLaunch;        
        Intent launchIntent = new Intent(Intent.ACTION_VIEW);        
        launchIntent.setDataAndType(Uri.parse(uri), "resource/folder");
        ComponentName componentName = launchIntent.resolveActivity(activity.getPackageManager());
        canLaunch = componentName != null
                && !"{com.android.fallback/com.android.fallback.Fallback}"
                .equals(componentName.toShortString());        
        result.success(canLaunch);
    }
}
