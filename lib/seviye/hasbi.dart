import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/seviye/hasbi_oyna.dart';

class HasbiOlustur extends StatefulWidget {
  const HasbiOlustur({super.key});

  @override
  State<HasbiOlustur> createState() => _HasbiOlusturState();
}

class _HasbiOlusturState extends State<HasbiOlustur> {
  final List<int> _mayinSayilari = [10, 20, 30, 40, 50];
  int secilenMayinSayisi = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/tarlayap.png',
              fit: BoxFit.fill,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 80,
                ),
                DropdownButton<int>(
                  value: secilenMayinSayisi,
                  items: _mayinSayilari.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        "$value Mayın",
                        style: TextStyle(
                          color: Colors.blue.shade200,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? deger) {
                    setState(() {
                      secilenMayinSayisi = deger!;
                    });
                  },
                  dropdownColor: Colors.white,
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  iconEnabledColor: Colors.blue,
                ),
                SizedBox(
                  height: 50,
                  width: 300,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HasbiTarla(
                            mineCount: secilenMayinSayisi,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        side: BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade400),
                    child: Text("HASBİ BAŞLAT"),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 50,
                  width: 300,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        side: BorderSide(
                          color: Colors.purple,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple.shade400),
                    child: Text("GERİ DÖN"),
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
