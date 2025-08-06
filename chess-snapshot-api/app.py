import cv2 as cv
import numpy as np

from flask import Flask, request, jsonify
from stockfish import Stockfish
from detectors.chess_position_detector import ChessPositionDetector


app = Flask(__name__)

@app.route('/')
def hello_chess_snapshot():
    return 'Hello, Chess Snapshot!'

@app.route('/api/get_chess_position', methods=['POST'])
def get_chess_position():
    if 'image' not in request.files:
        return 'No image uploaded', 400

    image_file = request.files['image']
    image_bytes = image_file.read()

    nparr = np.frombuffer(image_bytes, np.uint8)
    original_image = cv.imdecode(nparr, cv.IMREAD_COLOR)

    chess_position_detector = ChessPositionDetector()
    fen = chess_position_detector.detect(original_image)

    return jsonify({'fen': fen})

@app.route('/api/get_best_move', methods=['POST'])
def get_best_move():
    data = request.get_json()
    fen = data['fen']

    stockfish = Stockfish(path='./stockfish/stockfish-16.1')
    stockfish.set_fen_position(fen)
    best_move = stockfish.get_best_move()

    return jsonify({'best_move': best_move})

if __name__ == '__main__':
    app.run(port=8080)
