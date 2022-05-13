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

    public String keystoreLocation = "/ropsten";

    @Override
    public String getName() {
        return "CommunicationNative";
    }

    @ReactMethod
    public void getAddress(Callback cb) {
        try {
            NodeHolder nh = NodeHolder.getInstance();
            KeyStore ks = new KeyStore(nh.getFilesDir() + keystoreLocation, Geth.LightScryptN, Geth.LightScryptP);
            Account acc = ks.getAccounts().get(0);

            cb.invoke(acc.getAddress().getHex());
        } catch (Exception e) {
            cb.invoke("error");
            android.util.Log.d("error", e.getMessage());
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void setupAccount(String creationPassword, String exportPassword, Callback cb) {
        // creates a new account and exports it
        try {
            NodeHolder nh = NodeHolder.getInstance();
            KeyStore ks = new KeyStore(nh.getFilesDir() + keystoreLocation, Geth.LightScryptN, Geth.LightScryptP);

            Account newAcc = ks.newAccount(creationPassword);
            nh.setAcc(newAcc);
            ks.getAccounts().set(0, newAcc);
            byte[] jsonAcc = ks.exportKey(newAcc, creationPassword, exportPassword);

            cb.invoke(new String(jsonAcc));
        } catch (Exception e) {
            cb.invoke("error");
            android.util.Log.d("error", e.getMessage());
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void loadAccount(String keyfile, String exportPassword, String importPassword, Callback cb) {
        // imports account from json and two passwods
        try {
            NodeHolder nh = NodeHolder.getInstance();
            KeyStore ks = new KeyStore(nh.getFilesDir() + keystoreLocation, Geth.LightScryptN, Geth.LightScryptP);

            Account impAcc = ks.importKey(keyfile.getBytes(), exportPassword, importPassword);
            nh.setAcc(impAcc);
            byte[] jsonAcc = ks.exportKey(impAcc, importPassword, exportPassword);
            cb.invoke(new String(jsonAcc));
        } catch (Exception e) {
            cb.invoke("error");
            android.util.Log.d("error", e.getMessage());
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void getBalance(Callback cb) {
        // callsContract with message
        try {
            NodeHolder nh = NodeHolder.getInstance();
            Node node = nh.getNode();
            KeyStore ks = new KeyStore(nh.getFilesDir() + keystoreLocation, Geth.LightScryptN, Geth.LightScryptP);
            Account acc = ks.getAccounts().get(0);

            EthereumClient ec = nh.getClient();
            
            Context ctx = new Context();
            BigInt balanceAt = ec.getBalanceAt(ctx, acc.getAddress(), -1);
            
            cb.invoke(balanceAt.string());
        } catch (Exception e) {
            cb.invoke("error");
            android.util.Log.d("error", e.getMessage());
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void sendTransaction(String password, String receiver, int amount, Callback cb) {
        // sends transaction to receiver with value
        Context ctx = new Context();
        try {
            NodeHolder nh = NodeHolder.getInstance();
            EthereumClient ec = nh.getClient();

            KeyStore ks = new KeyStore(nh.getFilesDir() + keystoreLocation, Geth.LightScryptN, Geth.LightScryptP);
            Account acc = ks.getAccounts().get(0);

            long nonce = ec.getPendingNonceAt(ctx, acc.getAddress());

            // create msg for determining price and limit
            CallMsg msg = Geth.newCallMsg();
            BigInt gasPrice = ec.suggestGasPrice(ctx);
            msg.setFrom(acc.getAddress());
            msg.setGas(200000);
            msg.setGasPrice(gasPrice);
            msg.setValue(Geth.newBigInt(amount));
            msg.setTo(Geth.newAddressFromHex(receiver));
            long gasLimit = ec.estimateGas(ctx, msg);
            
            // create transaction
            Transaction transaction = Geth.newTransaction(nonce, Geth.newAddressFromHex(receiver),
                    Geth.newBigInt(amount), gasLimit, gasPrice, "".getBytes());
            // unlock account for set time
            ks.timedUnlock(acc, password, 10000000);
            // send transaction
            transaction = ks.signTx(acc, transaction, new BigInt(4));
            ec.sendTransaction(ctx, transaction);
            cb.invoke("sent");
        } catch (Exception e) {
            cb.invoke("error");
            android.util.Log.d("error", e.getMessage());
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void getClosestHash(int blockchainId, String password, String contractAddress, String abi, int target, Callback cb) {
        // call contract at address wih target as param
        Context ctx = new Context();
        try {
            NodeHolder nh = NodeHolder.getInstance();
            EthereumClient ec = nh.getClient();
            
            KeyStore ks = new KeyStore(nh.getFilesDir() + keystoreLocation, Geth.LightScryptN, Geth.LightScryptP);
            Account acc = ks.getAccounts().get(0);
            BoundContract boundContract = Geth.bindContract(Geth.newAddressFromHex(contractAddress), abi, ec);

            // configuring smart contract args
            Interface height = Geth.newInterface();
            Interface chainId = Geth.newInterface();
            height.setBigInt(Geth.newBigInt(target));
            chainId.setBigInt(Geth.newBigInt(blockchainId));
            Interfaces params = Geth.newInterfaces(2);
            params.set(0, chainId);
            params.set(1, height);

            // configuring return
            Interface result = Geth.newInterface();
            result.setDefaultBigInts();
            Interfaces results = Geth.newInterfaces(1);
            results.set(0, result);

            // configure options
            CallOpts opts = Geth.newCallOpts();
            opts.setContext(ctx);

            boundContract.call(opts, results, "getClosestHash", params);

            // return result in callback
            cb.invoke(results.get(0).getBigInts().get(0).string(),
                    results.get(0).getBigInts().get(1).string());
        } catch (Exception e) {
            cb.invoke("error", e.getMessage());
            android.util.Log.d("error", e.getMessage());
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void getSyncProgress(Callback cb) {
        try {
            Context ctx = new Context();
            NodeHolder nh = NodeHolder.getInstance();
            SyncProgress sp = nh.getNode().getEthereumClient().syncProgress(ctx);
            if (sp != null) {
                cb.invoke(sp.getCurrentBlock());
                return;
            }
        } catch (Exception e) {
            cb.invoke("error");
            android.util.Log.d("error", e.getMessage());
            e.printStackTrace();
        }
    }
}
