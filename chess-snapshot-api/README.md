![Banner](banner.png)

# Chess Snapshot API

The Chess Snapshot API provides an easy-to-use RESTful interface for detecting and analyzing chess positions from images. It utilizes the [Chess Position Detector](https://github.com/tbtiberiu/chess-position-detector.git) to convert a chessboard image into a FEN string and integrates the powerful Stockfish chess engine to determine the best move from any given position.

This API is intended for integration with a Flutter application, offering seamless support for the [Chess Snapshot App](https://github.com/tbtiberiu/chess_snapshot_app.git).

## Installation

### Prerequisites

- Python 3 ([Python 3.10](https://www.python.org/downloads/release/python-31014/) is recommended)
- [Ngrok](https://ngrok.com/download)

### Requirements

Ensure that Python is installed on your machine. You can install the necessary dependencies using `pip` and the `requirements.txt` file.

```bash
pip install -r requirements.txt
```

### Dependencies

- OpenCV
- Numpy
- Flask
- Stockfish
- ...

These dependencies are necessary for image processing, detection algorithms, and chess analysis.

## Usage

To use the `Chess Snapshot API`, follow these steps:

1. **Start the Flask Server**:

   ```bash
   python app.py
   ```

2. **Expose the Server with Ngrok**:
   ```bash
   ngrok http --domain=knowing-fit-poodle.ngrok-free.app 8080
   ```

### Endpoints

1. **Get Chess Position (FEN String)**

   - **URL**: `/api/get_chess_position`
   - **Method**: `POST`
   - **Description**: This endpoint accepts an image file of a chessboard and returns the FEN string representing the position on the board.
   - **Response Example**:
     ```json
     {
       "fen": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
     }
     ```

2. **Get Best Move**
   - **URL**: `/api/get_best_move`
   - **Method**: `POST`
   - **Description**: This endpoint accepts a FEN string and returns the best move as calculated by Stockfish.
   - **Response Example**:
     ```json
     {
       "best_move": "e2e4"
     }
     ```

## Acknowledgments

This project is based on advanced computer vision techniques and was supervised by Lect. Dr. Ioana Cristina Plajer.

**Read More:** [Chess Snapshot Full Documentation in Romanian (PDF)](ChessSnapshot.pdf)

## Additional Resources

- [Chess Position Detector GitHub Repository](https://github.com/tbtiberiu/chess-position-detector.git)
- [Chess Snapshot App GitHub Repository](https://github.com/tbtiberiu/chess_snapshot_app.git)
