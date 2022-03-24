// React native cli communication with geth
// refs https://www.zupzup.org/react-native-ethereum/

package com.zkwallet;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import android.util.Log;

import com.facebook.react.ReactActivity;

import org.ethereum.geth.*;

import org.ethereum.geth.Account;
import org.ethereum.geth.Geth;
import org.ethereum.geth.KeyStore;
import org.ethereum.geth.Node;
import org.ethereum.geth.NodeConfig;

import android.util.*;
import android.os.Bundle;
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
    public void getAddress(Callback cb) {
        try {
            NodeHolder nh = NodeHolder.getInstance();
            Node node = nh.getNode();
            Context ctx = new Context();
            if (node != null) {
                NodeInfo info = node.getNodeInfo();
                EthereumClient ethereumClient = node.getEthereumClient();
                Account newAcc = nh.getAcc();
                cb.invoke(info.getDiscoveryPort() + " " +  info.getListenerPort() + " " + info.getIP());
                return;
            }
            cb.invoke("node was null");
        } catch (Exception e) {
            cb.invoke("error: ", e.getMessage());
            android.util.Log.d("error: ", e.getMessage());
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void setupAccount(String creationPassword, String exportPassword, Callback cb) {
        // creates a new account and exports it
        try {
            NodeHolder nh = NodeHolder.getInstance();
            KeyStore ks = new KeyStore(nh.getFilesDir() + "/keystore", Geth.LightScryptN, Geth.LightScryptP);

            Account newAcc = ks.newAccount(creationPassword);
            nh.setAcc(newAcc);

            byte[] jsonAcc = ks.exportKey(newAcc, creationPassword, exportPassword);
            cb.invoke(new String(jsonAcc));
        } catch (Exception e) {
            cb.invoke("error: ", e.getMessage());
            android.util.Log.d("error: ", e.getMessage());
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void loadAccount(String keyfile, String exportPassword, String importPassword, Callback cb) {
        // imports account from json and two passwods
        try {
            NodeHolder nh = NodeHolder.getInstance();   
            KeyStore ks = new KeyStore(nh.getFilesDir() + "/keystore", Geth.LightScryptN, Geth.LightScryptP);

			Account impAcc = ks.importKey(keyfile.getBytes(), exportPassword, importPassword);
            nh.setAcc(impAcc);

            byte[] jsonAcc = ks.exportKey(impAcc, importPassword, exportPassword);
            cb.invoke(new String(jsonAcc));
        } catch (Exception e) {
            cb.invoke("error: ", e.getMessage());
            android.util.Log.d("error: ", e.getMessage());
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void callContract(String importPassword, Callback cb) {
        // callsContract with message
        try {
            NodeHolder nh = NodeHolder.getInstance(); 
            Node node = nh.getNode();
            Account acc = nh.getAcc();
            EthereumClient ec = node.getEthereumClient();
            Context ctx = new Context();
            //ec.getBalanceAt(ctx, , -1);
            BigInt balanceAt = ec.getBalanceAt(ctx, acc.getAddress(), -1);
            //ec.getBlockByNumber(ctx, -1).getNumber();
            cb.invoke(balanceAt.getNumber());
            // byte[] res = ec.CallContract(ctx, msg, 0);
        } catch (Exception e) {
            cb.invoke("error: ", e.getMessage());
            android.util.Log.d("error: ", e.getMessage());
            e.printStackTrace();
        }
    }


    @ReactMethod
    public void test(String message, Callback cb) {
        Context ctx = new Context();
        try {
            android.util.Log.d("before", "yay");
            NodeHolder nh = NodeHolder.getInstance();
            Node node = nh.getNode();
            if (node != null) {
                NodeInfo info = node.getNodeInfo();
                Account newAcc = nh.getAcc();

                EthereumClient ec = node.getEthereumClient();
                ec.getBlockByNumber(ctx, -1).getNumber();
                cb.invoke("ok");
                return;
            }
            cb.invoke("node was null");
        } catch (Exception e) {
            android.util.Log.d("", e.getMessage());
            e.printStackTrace();
        }
    }
}