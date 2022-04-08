package com.zkwallet;

import org.ethereum.geth.Account;
import org.ethereum.geth.Node;
import org.ethereum.geth.*;

import main.java.com.zkwallet.Constants;

// class for storage of persistent data
public class NodeHolder {
    private Node node;
    private Account acc;
    private java.io.File filesDir;
    private static NodeHolder instance = null;

    // determines wether to use provider or regular network
    // used because of peerless eth test networks :)
    public Boolean isDevEnv = false;

    private NodeHolder() {}

    public static NodeHolder getInstance() {
        if (instance == null) {
            instance = new NodeHolder();
        }
        return instance;
    }

    // in dev enviroment connect dirctly to other node
    public EthereumClient getClient() {
        try {
            if(isDevEnv) {
                return Geth.newEthereumClient(Constants.PROVIDER);
            }
            else {
                return node.getEthereumClient();
            }
        } catch (Exception e) {
            android.util.Log.d("error", e.getMessage());
            return null;
        }
    }

    public Node getNode() {
        return node;
    }

    public void setNode(Node node) {
        this.node = node;
    }

    public Account getAcc() {
        return acc;
    }

    public void setAcc(Account acc) {
        this.acc = acc;
    }

    public java.io.File getFilesDir() {
        return filesDir;
    }

    public void setFilesDir(java.io.File filesDir) {
        this.filesDir = filesDir;
    }
}