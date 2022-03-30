from flask import Flask

from src.ethereum import get_last_transaction, init_eth_with_pk
from src.bitcoin import get_zk_input
from src.constants import *

# Initialize flask app
app = Flask(__name__)
app.debug = True

web3 = init_eth_with_pk(PRIVATE_KEY, ETHPROVIDER)

@app.route('/')
@app.route('/api/')
def home():
    if(web3.isConnected()):
        return 'Hello there!'
    return 'Connection error'        

@app.route('/eth/')
def lastTransaction():
    """ Returns last transaction on current blockchain """
    return get_last_transaction(web3), 200

@app.route('/btc')
def createBtcWitness():
    """ Creates proof for headers """
    return get_zk_input(1,3), 200

# Run the server
if __name__ == '__main__':
    app.run(host='0.0.0.0')