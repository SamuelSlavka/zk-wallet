package com.zkwallet;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import org.ethereum.geth.*;

import android.util.*;
import android.widget.Toast;

public class TestNative extends ReactContextBaseJavaModule {
    public TestNative(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "TestNative";
    }

    @ReactMethod
    public void test(String message, Callback cb) {
        cb.invoke("hello from java: " + message);
    }
}
