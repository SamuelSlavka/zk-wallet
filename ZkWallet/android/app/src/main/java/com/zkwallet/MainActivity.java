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
import org.json.JSONObject;

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
      // rinkeby
      nodeConfig.setEthereumNetworkID(4);
      
      String genesis = Geth.rinkebyGenesis();
      nodeConfig.setEthereumGenesis(genesis);
      nodeConfig.addBootstrapNode(Geth.newEnode("enode://b6b28890b006743680c52e64e0d16db57f28124885595fa03a562be1d2bf0f3a1da297d56b13da25fb992888fd556d4c1a27b1f39d531bde7de1921c90061cc6@159.89.28.211:30303"));
      nodeConfig.addBootstrapNode(Geth.newEnode("enode://343149e4feefa15d882d9fe4ac7d88f885bd05ebb735e547f12e12080a9fa07c8014ca6fd7f373123488102fe5e34111f8509cf0b7de3f5b44339c9f25e87cb8@52.3.158.184:30303"));
      nodeConfig.addBootstrapNode(Geth.newEnode("enode://a24ac7c5484ef4ed0c5eb2d36620ba4e4aa13b8c84684e1b4aab0cebea2ae45cb4d375b77eab56516d34bfbd3c1a833fc51296ff084b770b94fb9028c4d25ccf@52.169.42.101:30303"));

      Node node = Geth.newNode(getFilesDir() + "/.rby1", nodeConfig);

      NodeHolder nh = NodeHolder.getInstance();
      nh.isDevEnv = true;
      node.start();

      nh.setFilesDir(getFilesDir());
      nh.setNode(node);
    } catch (Exception e) {
      Log.d("fail",e.getMessage());
    }
  
  }
}
