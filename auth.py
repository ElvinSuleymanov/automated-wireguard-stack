from flask import Flask
import os

app = Flask(__name__)

auth_key = os.getenv("AUTH_KEY_SCRIPT")

@app.route("/", methods=["GET"])
def authenticate_client_script():
    @wraps(f)
    def decorated_function(*args, **kwargs):
     ##main auth process goes in here
     user_provided_key = request.headers.get("X-Auth-Token")
     if not user_provided_key or user_provided_key != auth_key:
        return 
     return os.getenv("SERVER_PUBLIC_KEY")
     
    return decorated_function

