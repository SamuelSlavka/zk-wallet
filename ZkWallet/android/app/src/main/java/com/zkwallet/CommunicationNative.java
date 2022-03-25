// React native cli communication with geth
// refs https://www.zupzup.org/react-native-ethereum/

package com.zkwallet;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.ReactActivity;

import java.math.*;

import android.util.*;
import android.util.Log;
import android.os.Bundle;
import android.widget.Toast;

import org.ethereum.geth.*;
import org.ethereum.geth.Account;
import org.ethereum.geth.Geth;
import org.ethereum.geth.KeyStore;
import org.ethereum.geth.Node;
import org.ethereum.geth.NodeConfig;

public class CommunicationNative extends ReactContextBaseJavaModule {
    public CommunicationNative(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "CommunicationNative";
    }

    @ReactMethod
    public void test(Callback cb) {
        try {
            NodeConfig nodeConfig = Geth.newNodeConfig();
            nodeConfig.setEthereumNetworkID(4);
            String genesis = Geth.rinkebyGenesis();
            nodeConfig.setEthereumGenesis(genesis);
            cb.invoke(nodeConfig.string());

            android.util.Log.d("out: ", nodeConfig.string());
        } catch (Exception e) {
            cb.invoke("error: ", e.getMessage());
            android.util.Log.d("error: ", e.getMessage());
            e.printStackTrace();
        }
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
    public void getBalance(Callback cb) {
        // callsContract with message
        try {
            NodeHolder nh = NodeHolder.getInstance(); 
            Node node = nh.getNode();
            Account acc = nh.getAcc();
            EthereumClient ec = node.getEthereumClient();
            Context ctx = new Context();
            BigInt balanceAt = ec.getBalanceAt(ctx, acc.getAddress(), -1);
            cb.invoke(balanceAt.string());
        } catch (Exception e) {
            cb.invoke("error: ", e.getMessage());
            android.util.Log.d("error: ", e.getMessage());
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void callContract(Callback cb) {
        // callsContract with message
        try {
            NodeHolder nh = NodeHolder.getInstance(); 
            Node node = nh.getNode();
            EthereumClient ec = node.getEthereumClient();
            Context ctx = new Context();

            CallMsg msg = Geth.newCallMsg();
            byte[] result = ec.callContract(ctx, msg, -1);
            cb.invoke(new String(result));
        } catch (Exception e) {
            cb.invoke("error: ", e.getMessage());
            android.util.Log.d("error: ", e.getMessage());
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void sendTransaction(String password, String receiver, int amount, String jsonTransaction, String data_string, Callback cb) {
        // sends transaction to receiver with value
        Context ctx = new Context();
        try {
            NodeHolder nh = NodeHolder.getInstance(); 
            Node node = nh.getNode();
            EthereumClient ec = node.getEthereumClient();
            KeyStore ks = new KeyStore(nh.getFilesDir() + "/keystore", Geth.LightScryptN, Geth.LightScryptP);

            Account acc = nh.getAcc();
            long nonce = ec.getPendingNonceAt(ctx, acc.getAddress());

            CallMsg msg = Geth.newCallMsg();
            BigInt gasPrice = ec.suggestGasPrice(ctx);

            msg.setFrom(acc.getAddress());
            msg.setGas(21000);

            
            msg.setGasPrice(gasPrice);

            msg.setValue(Geth.newBigInt(amount));
            msg.setData(data_string.getBytes());
            msg.setTo(Geth.newAddressFromHex(receiver));

            long gasLimit = ec.estimateGas(ctx, msg);
            msg.setGas(gasLimit);

            Transaction transaction = Geth.newTransaction(nonce, Geth.newAddressFromHex(receiver), Geth.newBigInt(amount), gasLimit, gasPrice, data_string.getBytes());
            ks.timedUnlock(acc, password, 10000000);
            transaction = ks.signTx(acc, transaction, new BigInt(4));
            ec.sendTransaction(ctx, transaction);
    
            //cb.invoke(balanceAt.string());
        } catch (Exception e) {
            cb.invoke("error: ", e.getMessage());
            android.util.Log.d("error: ", e.getMessage());
            e.printStackTrace();
        }
    }
}