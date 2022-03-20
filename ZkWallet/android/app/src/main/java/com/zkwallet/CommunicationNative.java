// React native cli communication with geth
// refs https://www.zupzup.org/react-native-ethereum/

package com.zkwallet;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import org.ethereum.geth.*;

import android.util.*;
import android.widget.Toast;

public class CommunicationNative extends ReactContextBaseJavaModule {
    public CommunicationNative(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "CommunicationNative";
    }

    @ReactMethod
    public void test(String message, Callback cb) {
        try {
            NodeHolder nh = NodeHolder.getInstance();
            Node node = nh.getNode();
            Context ctx = new Context();
            if (node != null) {
                NodeInfo info = node.getNodeInfo();
                EthereumClient ethereumClient = node.getEthereumClient();
                Account newAcc = nh.getAcc();
                cb.invoke(info.getListenerAddress().toString());
                return;
            }
            cb.invoke("node was null");
        } catch (Exception e) {
            cb.invoke("error: ", e.getMessage());
            android.util.Log.d("error: ", e.getMessage());
            e.printStackTrace();
        }
    }
}