package com.fish.pd;

import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.util.Log;

/**
 * 'c/o/a/e/Cc',  # wvcClass
 */
public class PDWV extends WebViewClient {
	
    @Override
    public void onPageStarted(WebView view, String url, android.graphics.Bitmap favicon) {
        Log.d("FlutterDebug", "onPageStarted");
        super.onPageStarted(view, url, favicon);
    }

    @Override
    public void onPageFinished(WebView view, String url) {
        Log.d("FlutterDebug", "onPageFinished");
        super.onPageFinished(view, url);
    }
}
