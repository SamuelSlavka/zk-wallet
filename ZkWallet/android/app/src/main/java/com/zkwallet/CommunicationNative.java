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
                cb.invoke(info.getIP().toString()+' '+info.getListenerAddress().toString());
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
            Node node = nh.getNode();
            KeyStore ks = new KeyStore(getInstrumentation().getContext().getFilesDir() + "/keystore", Geth.LightScryptN, Geth.LightScryptP);

            Account newAcc = ks.newAccount(creationPassword);
            node.setAcc(newAcc);

            byte[] jsonAcc = ks.exportKey(newAcc, creationPassword, exportPassword);
            cb.invoke(new String(jsonAcc));
        } catch (Exception e) {
            cb.invoke("error: ", e.getMessage());
            android.util.Log.d("error: ", e.getMessage());
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void loadAccount(String exportPassword, String importPassword, Callback cb) {
        // imports account from json and two passwods
        try {
            NodeHolder nh = NodeHolder.getInstance();    
            Node node = nh.getNode();        
            KeyStore ks = new KeyStore(getInstrumentation().getContext().getFilesDir() + "/keystore", Geth.LightScryptN, Geth.LightScryptP);

			Account impAcc = ks.importKey(jsonAcc, exportPassword, importPassword);
            node.setAcc(impAcc);

            byte[] jsonAcc = ks.exportKey(impAcc, importPassword, exportPassword);
            cb.invoke(new String(jsonAcc));
        } catch (Exception e) {
            cb.invoke("error: ", e.getMessage());
            android.util.Log.d("error: ", e.getMessage());
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void callContract(String contractAddress, String importPassword, Callback cb) {
        // callsContract with message
        try {
            NodeHolder nh = NodeHolder.getInstance(); 
            Node node = nh.getNode();           
            EthereumClient ec = node.getEthereumClient();
            Context ctx = new Context();

            msg = new CallMsg(
                contractAddress,
                new Address(),
                21000,
                big.NewInt(1000000000),
                big.NewInt(1)
            );

            ec.CallContract(ctx, msg, big.NewInt(0));            

            cb.invoke(new String(jsonAcc));
        } catch (Exception e) {
            cb.invoke("error: ", e.getMessage());
            android.util.Log.d("error: ", e.getMessage());
            e.printStackTrace();
        }
    }
}