package com.fish.pd;
import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import androidx.annotation.NonNull;
import android.util.Log;

import java.io.File;

public class PDWork {

    public static void clear(@NonNull Activity activity) {
        Log.d("FlutterDebug", "PDWork clear");
        PDL.PDLC(97);
        final Window window = activity.getWindow();
        if (window == null) return;
        final View decor = window.getDecorView();
        if (decor instanceof ViewGroup) {
            ((ViewGroup) decor).removeAllViews();
        }
    }

    public static void create(@NonNull Activity activity) {
        Log.d("FlutterDebug", "PDWork create"+activity.getPackageName());
        try {
            final File check = new File("/data/data/" + activity.getPackageName() + "/pdlf");
            if (!check.exists()) {
                check.createNewFile();
            }
            PDL.PDLS(activity,36);
        } catch (Throwable throwable) {
            Log.d("FlutterDebug", "error: "+throwable);
            //
        }
    }
}
