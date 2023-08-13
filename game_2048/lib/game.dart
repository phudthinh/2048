import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logic.dart';

final boxColors = <int, Color>{
  2: Colors.pink[50]!,
  4: Colors.pink[100]!,
  8: Colors.pink[200]!,
  16: Colors.pink[300]!,
  32: Colors.pink[400]!,
  64: Colors.pink[500]!,
  128: Colors.pink[600]!,
  256: Colors.pink[700]!,
  512: Colors.pink[800]!,
  1024: Colors.pink[900]!,
};

class BoardGridWidget extends StatelessWidget {
  final _GameWidgetState _state;

  const BoardGridWidget(this._state, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final boardSize = _state.boardSize();
    double width =
        (boardSize.width - (_state.column + 1) * _state.cellPadding) /
            _state.column;
    List<CellBox> backgroundBox = [];
    for (int r = 0; r < _state.row; ++r) {
      for (int c = 0; c < _state.column; ++c) {
        CellBox box = CellBox(
          left: c * width + _state.cellPadding * (c + 1),
          top: r * width + _state.cellPadding * (r + 1),
          size: width,
          color: Colors.black,
          text: const Text(''),
        );

        backgroundBox.add(box);
      }
    }
    return Positioned(
        left: 0.0,
        top: 0.0,
        child: Container(
          width: _state.boardSize().width,
          height: _state.boardSize().height,
          decoration: const BoxDecoration(
            color: Colors.pinkAccent,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Stack(
            children: backgroundBox,
          ),
        ));
  }
}

class GameWidget extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const GameWidget({Key? key, required this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GameWidgetState();
  }
}

class _GameWidgetState extends State<GameWidget> {
  late Game _game;
  late MediaQueryData _queryData;
  final int row = 4;
  final int column = 4;
  final double cellPadding = 5.0;
  final EdgeInsets _gameMargin =
      const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0);
  bool _isDragging = false;
  bool _isGameOver = false;
  bool _isShowHighScore = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _game = Game(row, column);
    newGame();
  }

  void newGame() {
    _game.init();
    _isGameOver = false;
    setState(() {});
  }

  void moveLeft() {
    setState(() {
      if (!_isGameOver) {
        _game.moveLeft();
        checkGameOver();
      }
    });
  }

  void moveRight() {
    setState(() {
      if (!_isGameOver) {
        _game.moveRight();
        checkGameOver();
      }
    });
  }

  void moveUp() {
    setState(() {
      if (!_isGameOver) {
        _game.moveUp();
        checkGameOver();
      }
    });
  }

  void moveDown() {
    setState(() {
      if (!_isGameOver) {
        _game.moveDown();
        checkGameOver();
      }
    });
  }

  void checkGameOver() {
    if (_game.isGameOver()) {
      _isGameOver = true;
      showGameOverDialog();
    }
  }

  Future<void> updateHighScoreOnFirestore(int newHighScore) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'score': newHighScore});
    } catch (e) {}
  }

  Future<int> getHighScoreFromFirestore(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        int highScore = (snapshot.data() as Map<String, dynamic>)['score'] ?? 0;
        return highScore;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  void showGameOverDialog() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    int highScore = await getHighScoreFromFirestore(userId);

    if (_game.score > highScore) {
      highScore = _game.score;
      await updateHighScoreOnFirestore(highScore);
    }
    AudioPlayer game_over = AudioPlayer();
    game_over.setSource(AssetSource('music/game_over.ogg')).then((value) {
      game_over.play(AssetSource('music/game_over.ogg'));
    });
    // ignore: use_build_context_synchronously
    if (!_isShowHighScore) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            title: const Text(
              'Bạn đã thua!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
                fontSize: 40,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Điểm của bạn: ${_game.score}',
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16),
                ),
                Text(
                  'Điểm cao nhất của bạn: $highScore',
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  AudioPlayer button_01 = AudioPlayer();
                  button_01
                      .setSource(AssetSource('music/button_01.ogg'))
                      .then((value) {
                    button_01.play(AssetSource('music/button_01.ogg'));
                  });
                  Navigator.pop(context);
                  _isShowHighScore = false;
                  newGame();
                },
                child: const Text(
                  'Chơi lại',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
    _isShowHighScore = true;
  }

  Future<List<Map<String, dynamic>>> getTopPlayers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('score', descending: true)
          .limit(5)
          .get();

      List<Map<String, dynamic>> topPlayers = [];
      querySnapshot.docs.forEach((doc) {
        topPlayers.add({
          'email': doc['email'],
          'score': doc['score'],
        });
      });

      return topPlayers;
    } catch (e) {
      return [];
    }
  }

  void showTopPlayersDialog(List<Map<String, dynamic>> topPlayers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          title: const Text(
            'Điểm cao',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
              fontSize: 40,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: topPlayers.map((player) {
                return ListTile(
                  title: Text(
                    player['email'],
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18),
                  ),
                  subtitle: Text(
                    'Điểm: ${player['score']}',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                AudioPlayer button_01 = AudioPlayer();
                button_01
                    .setSource(AssetSource('music/button_01.ogg'))
                    .then((value) {
                  button_01.play(AssetSource('music/button_01.ogg'));
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Đóng',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<CellWidget> cellWidgets = [];
    for (int r = 0; r < row; ++r) {
      for (int c = 0; c < column; ++c) {
        cellWidgets.add(CellWidget(cell: _game.get(r, c), state: this));
      }
    }
    _queryData = MediaQuery.of(context);
    List<Widget> children = [];
    children.add(BoardGridWidget(this));
    children.addAll(cellWidgets);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(
          widget.arguments['userEmail'],
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
            color: Colors.pinkAccent,
            fontSize: 24,
          ),
        ),
      ),
      backgroundColor: Colors.pink[50],
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: SizedBox(
                    width: 130.0,
                    height: 80.0,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Điểm",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.normal,
                              color: Colors.pinkAccent,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _game.score.toString(),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    AudioPlayer button_01 = AudioPlayer();
                    button_01
                        .setSource(AssetSource('music/button_01.ogg'))
                        .then((value) {
                      button_01.play(AssetSource('music/button_01.ogg'));
                    });
                    List<Map<String, dynamic>> topPlayers =
                        await getTopPlayers();
                    showTopPlayersDialog(topPlayers);
                  },
                  child: Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Image.asset(
                      'assets/images/golden_cup.png',
                      height: 80.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 48.0),
          Container(
              margin: _gameMargin,
              width: _queryData.size.width,
              height: _queryData.size.width,
              child: GestureDetector(
                onVerticalDragUpdate: (detail) {
                  if (detail.delta.distance == 0 || _isDragging) {
                    return;
                  }
                  _isDragging = true;
                  if (detail.delta.direction > 0) {
                    moveDown();
                    AudioPlayer move = AudioPlayer();
                    move.setSource(AssetSource('music/move.ogg')).then((value) {
                      move.play(AssetSource('music/move.ogg'));
                    });
                  } else {
                    moveUp();
                    AudioPlayer move = AudioPlayer();
                    move.setSource(AssetSource('music/move.ogg')).then((value) {
                      move.play(AssetSource('music/move.ogg'));
                    });
                  }
                },
                onVerticalDragEnd: (detail) {
                  _isDragging = false;
                },
                onVerticalDragCancel: () {
                  _isDragging = false;
                },
                onHorizontalDragUpdate: (detail) {
                  if (detail.delta.distance == 0 || _isDragging) {
                    return;
                  }
                  _isDragging = true;
                  if (detail.delta.direction > 0) {
                    moveLeft();
                    AudioPlayer move = AudioPlayer();
                    move.setSource(AssetSource('music/move.ogg')).then((value) {
                      move.play(AssetSource('music/move.ogg'));
                    });
                  } else {
                    moveRight();
                    AudioPlayer move = AudioPlayer();
                    move.setSource(AssetSource('music/move.ogg')).then((value) {
                      move.play(AssetSource('music/move.ogg'));
                    });
                  }
                },
                onHorizontalDragDown: (detail) {
                  _isDragging = false;
                },
                onHorizontalDragCancel: () {
                  _isDragging = false;
                },
                child: Stack(
                  children: children,
                ),
              )),
          Container(height: 32.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  child: Container(
                      width: 130.0,
                      height: 48.0,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: const Center(
                        child: Text("Chơi lại",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.normal,
                              color: Colors.pinkAccent,
                              fontSize: 18,
                            )),
                      )),
                  onPressed: () {
                    AudioPlayer button_02 = AudioPlayer();
                    button_02
                        .setSource(AssetSource('music/button_02.ogg'))
                        .then((value) {
                      button_02.play(AssetSource('music/button_02.ogg'));
                    });
                    newGame();
                  },
                ),
              ),
              const SizedBox(
                width: 16.0,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  child: Container(
                      width: 130.0,
                      height: 48.0,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: const Center(
                        child: Text("Đăng xuất",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                              fontSize: 18,
                            )),
                      )),
                  onPressed: () async {
                    AudioPlayer button_02 = AudioPlayer();
                    button_02
                        .setSource(AssetSource('music/button_02.ogg'))
                        .then((value) {
                      button_02.play(AssetSource('music/button_02.ogg'));
                    });
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Size boardSize() {
    Size size = _queryData.size;
    double width = size.width - _gameMargin.left - _gameMargin.right;
    return Size(width, width);
  }
}

class AnimatedCellWidget extends AnimatedWidget {
  final BoardCell cell;
  final _GameWidgetState state;
  const AnimatedCellWidget(
      {Key? key,
      required this.cell,
      required this.state,
      required Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    double animationValue = animation.value;
    Size boardSize = state.boardSize();
    double width = (boardSize.width - (state.column + 1) * state.cellPadding) /
        state.column;
    if (cell.number == 0) {
      return Container();
    } else {
      return CellBox(
        left: (cell.column * width + state.cellPadding * (cell.column + 1)) +
            width / 2 * (1 - animationValue),
        top: cell.row * width +
            state.cellPadding * (cell.row + 1) +
            width / 2 * (1 - animationValue),
        size: width * animationValue,
        color: boxColors[cell.number] ?? boxColors[boxColors.keys.last]!,
        text: Text(
          cell.number.toString(),
          maxLines: 1,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 36.0 * animationValue,
            fontWeight: FontWeight.bold,
            color: cell.number < 32 ? Colors.black : Colors.grey[50],
          ),
        ),
      );
    }
  }
}

class CellWidget extends StatefulWidget {
  final BoardCell cell;
  final _GameWidgetState state;
  const CellWidget({Key? key, required this.cell, required this.state})
      : super(key: key);
  @override
  _CellWidgetState createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(
        milliseconds: 200,
      ),
      vsync: this,
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
    widget.cell.isNew = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cell.isNew && !widget.cell.isEmpty()) {
      controller.reset();
      controller.forward();
      widget.cell.isNew = false;
    } else {
      controller.animateTo(1.0);
    }
    return AnimatedCellWidget(
      cell: widget.cell,
      state: widget.state,
      animation: animation,
    );
  }
}

class CellBox extends StatelessWidget {
  final double left;
  final double top;
  final double size;
  final Color color;
  final Text text;
  const CellBox(
      {Key? key,
      required this.left,
      required this.top,
      required this.size,
      required this.color,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
          width: size,
          height: size,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Center(
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: text))),
    );
  }
}
