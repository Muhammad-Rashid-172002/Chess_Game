import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class ChessGame extends StatefulWidget {
  const ChessGame({super.key});

  @override
  State<ChessGame> createState() => _ChessGameState();
}

class _ChessGameState extends State<ChessGame> {
  final ChessBoardController controller = ChessBoardController();
  String currentTurn = "White";

  int totalTime = 20; // 5 minutes
  Timer? gameTimer;
  bool gameStarted = false;
  bool gameOver = false;

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalTime > 0) {
        setState(() => totalTime--);
      } else {
        timer.cancel();
        setState(() => gameOver = true);
        showTimeUpDialog();
      }
    });
  }

  void showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("⏰ Time's Up!"),
        content: const Text("Game time has ended."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child: const Text("🔁 Restart"),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop(); // Closes the app
            },
            child: const Text("❌ Exit"),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    controller.resetBoard();
    setState(() {
      totalTime = 300;
      currentTurn = "White";
      gameOver = false;
      gameStarted = false;
    });
    gameTimer?.cancel();
  }

  String formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  @override
  Widget build(BuildContext context) {
    final isLowTime = totalTime <= 10;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          'Chess Game',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            gameOver ? "🏁 Game Over" : "Turn: $currentTurn",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Time Left: ${formatTime(totalTime)}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isLowTime ? Colors.red : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          AbsorbPointer(
            absorbing: gameOver,
            child: ChessBoard(
              controller: controller,
              boardColor: BoardColor.brown,
              boardOrientation: PlayerColor.white,
              enableUserMoves: true,
              onMove: () {
                setState(() {
                  if (!gameStarted) {
                    gameStarted = true;
                    startTimer(); // ⏱️ Start timer after first move
                  }
                  currentTurn = currentTurn == "White" ? "Black" : "White";
                });
              },
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple, // Purple
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.black45,
            ),
            child: const Text(
              "♻️ Reset Game",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
