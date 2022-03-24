// On creation also setup node
// refs https://www.zupzup.org/react-native-ethereum/

package com.zkwallet;

import android.os.Bundle;
import android.util.Log;
import com.facebook.react.ReactActivity;

import org.ethereum.geth.*;
import org.ethereum.geth.Account;
import org.ethereum.geth.Geth;
import org.ethereum.geth.KeyStore;
import org.ethereum.geth.Node;
import org.ethereum.geth.NodeConfig;

import static org.ethereum.geth.Geth.*;

public class MainActivity extends ReactActivity {

  /**
   * Returns the name of the main component registered from JavaScript. This is
   * used to schedule
   * rendering of the component.
   */
  @Override
  protected String getMainComponentName() {
    return "ZkWallet";
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
		Context ctx = new Context();
    try {
      NodeConfig nodeConfig = Geth.newNodeConfig();
      NodeHolder nh = NodeHolder.getInstance();

      Node node = Geth.newNode(getFilesDir() + "/.ethereum", nodeConfig);
      node.start();

      nh.setFilesDir(getFilesDir());
      nh.setNode(node);
    } catch (Exception e) {
      Log.d("fail", "what happened?" + e.getMessage());
    }

  }
}
