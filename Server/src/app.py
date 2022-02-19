from flask import Flask

# Initialize flask app
app = Flask(__name__)
app.debug = True


@app.route('/')
@app.route('/api/')
def home():
    return "Hello There!"

# Run the server
if __name__ == '__main__':
    app.run(host='0.0.0.0')