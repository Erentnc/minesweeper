import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mayin_tarlasi/mayin_home_page.dart';

class OzelTarla extends StatelessWidget {
  final int mineCount;
  const OzelTarla({super.key, required this.mineCount});

  @override
  Widget build(BuildContext context) {
    return OzelMayin(mineCount: mineCount);
  }
}

class OzelMayin extends StatefulWidget {
  final int mineCount;
  const OzelMayin({super.key, required this.mineCount});

  @override
  OzelMayinState createState() => OzelMayinState();
}

class OzelMayinState extends State<OzelMayin> {
  static const int gridSize = 12;
  late int mineCount;

  late List<List<Cell>> grid;

  @override
  void initState() {
    super.initState();
    mineCount = widget.mineCount;
    _tarlaOlusturma();
  }

  void _tarlaOlusturma() {
    grid = List.generate(
      gridSize,
      (_) => List.generate(
        gridSize,
        (_) => Cell(),
      ),
    );

    _mayinYerlestirme();
  }

  void _mayinYerlestirme() {
    final random = Random();
    int placedMines = 0;

    while (placedMines < mineCount) {
      int row = random.nextInt(gridSize);
      int col = random.nextInt(gridSize);

      if (!grid[row][col].isMine) {
        grid[row][col].isMine = true;
        placedMines++;
      }
    }

    _komsulariHesapla();
  }

  void _komsulariHesapla() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (!grid[row][col].isMine) {
          grid[row][col].neighborCount = _mayinHesapla(row, col);
        }
      }
    }
  }

  int _mayinHesapla(int row, int col) {
    int count = 0;

    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int newRow = row + i;
        int newCol = col + j;

        if (newRow >= 0 &&
            newRow < gridSize &&
            newCol >= 0 &&
            newCol < gridSize &&
            grid[newRow][newCol].isMine) {
          count++;
        }
      }
    }

    return count;
  }

  void _hucreGorunum(int row, int col) {
    if (grid[row][col].isRevealed) return;

    setState(() {
      grid[row][col].isRevealed = true;

      if (grid[row][col].isMine) {
        _alertshowGameOverDialog();
      } else if (grid[row][col].neighborCount == 0) {
        _bosKomsu(row, col);
      } else {
        _winMi();
      }
    });
  }

  void _bosKomsu(int row, int col) {
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int newRow = row + i;
        int newCol = col + j;

        if (newRow >= 0 &&
            newRow < gridSize &&
            newCol >= 0 &&
            newCol < gridSize) {
          _hucreGorunum(newRow, newCol);
        }
      }
    }
  }

  void _winMi() {
    bool kazandin = true;

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (!grid[row][col].isMine && !grid[row][col].isRevealed) {
          kazandin = false;
          break;
        }
      }
    }

    if (kazandin) {
      _alertshowWinDialog();
    }
  }

  void _tumTarlayiAc() {
    setState(() {
      for (int row = 0; row < gridSize; row++) {
        for (int col = 0; col < gridSize; col++) {
          grid[row][col].isRevealed = true;
        }
      }
    });
  }

  void _alertshowWinDialog() {
    _tumTarlayiAc();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text("Tebrikler!"),
        titleTextStyle: TextStyle(
            fontSize: 24,
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold),
        content: Text("Oyunu kazandınız!"),
        contentTextStyle: TextStyle(fontSize: 18, color: Colors.black87),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              setState(() {
                _tarlaOlusturma();
              });
            },
            child: Text("Tekrar Oyna"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MayinHomePage()),
              );
            },
            child: Text("Çıkış"),
          ),
        ],
      ),
    );
  }

  void _alertshowGameOverDialog() {
    _tumTarlayiAc();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text("Game Over"),
        titleTextStyle: TextStyle(
            fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
        content: Text("Mayına bastınız!"),
        contentTextStyle: TextStyle(fontSize: 18, color: Colors.black87),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              setState(() {
                _tarlaOlusturma();
              });
            },
            child: Text("Tekrar Oyna"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MayinHomePage()),
              );
            },
            child: Text("Çıkış"),
          ),
        ],
      ),
    );
  }

  Color _kutuRengi(int neighborCount) {
    switch (neighborCount) {
      case 1:
        return Colors.lightBlue;
      case 2:
        return Colors.purple.shade800;
      case 3:
        return Colors.deepOrange.shade700;
      case 4:
        return Colors.yellowAccent;
      case 5:
        return Colors.grey.shade700;
      case 6:
        return Colors.teal.shade700;
      default:
        return Colors.brown.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MAYIN TARLASI"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  "Seviye: Özel",
                  style: TextStyle(fontSize: 24),
                ),
                Text(
                  "*Tarlada $mineCount adet mayın bulunmaktadır",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) {
                      int row = index ~/ gridSize;
                      int col = index % gridSize;

                      Color parselRengi;

                      if (grid[row][col].isRevealed) {
                        if (grid[row][col].isMine) {
                          parselRengi = Colors.red;
                        } else {
                          parselRengi =
                              _kutuRengi(grid[row][col].neighborCount);
                        }
                      } else {
                        parselRengi = const Color.fromARGB(255, 19, 213, 29);
                      }

                      return GestureDetector(
                        onTap: () => _hucreGorunum(row, col),
                        child: Container(
                          margin: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: parselRengi,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade900,
                                offset: Offset(4, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: grid[row][col].isRevealed &&
                                    !grid[row][col].isMine
                                ? Text(
                                    grid[row][col].neighborCount > 0
                                        ? '${grid[row][col].neighborCount}'
                                        : '',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Cell {
  bool isMine = false;
  bool isRevealed = false;
  int neighborCount = 0;
}
