from flask import Blueprint, jsonify, make_response
import random

main_api = Blueprint('main_api', __name__)

@main_api.route('/')
def home():
    data = "Hello World!"
    return (data)
