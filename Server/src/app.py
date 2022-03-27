from flask import Flask

from .ethereum import *
from .bitcoin import *
from .constants import *

# Initialize flask app
app = Flask(__name__)
app.debug = True

web3 = init_eth_with_pk(PRIVATE_KEY)

@app.route('/')
@app.route('/api/')
def home():
    if web3.isConnected():
        return 'Hello there!'
    return 'Connection error'        

@app.route('/last/')
def lastTransaction():
    """ Returns last transaction on current blockchain """
    return get_last_transaction(web3), 200

@app.route('/eth/')
def createEthProof():
    """ Creates proof for headers """
    return create_proof(2), 200

@app.route('/eth/deploy/')
def dpeloyEthContract():
    """ Deploys smart contract """
    web3 = init_eth_with_pk(PRIVATE_KEY)
    print(build_and_deploy(web3.eth.default_account, web3))
    return 'ok', 200

@app.route('/btc/witness')
def createBtcWitness():
    """ Creates proof for headers """
    return create_witness(1,3), 200

@app.route('/btc/compile')
def compileBtcValidator():
    """ Complies validation progam """
    return compile_validator(), 200

# Run the server
if __name__ == '__main__':
    app.run(host='0.0.0.0')