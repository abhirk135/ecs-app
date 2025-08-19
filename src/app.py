from flask import Flask
from .main import main_api

app = Flask(__name__)
app.register_blueprint(main_api)

if __name__ == '__main__':
    app.run(debug=True)