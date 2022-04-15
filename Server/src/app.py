from flask import Flask

from src.ethereum import init_eth_with_pk, get_contract_info
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

@app.route('/api/contract/')
def getContractInfo():
    """ Deployed contract information """
    return get_contract_info(), 200

# Run the server
if __name__ == '__main__':
    app.run(host='0.0.0.0')