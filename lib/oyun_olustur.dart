import 'package:flutter/material.dart';

class OyunOlustur extends StatelessWidget {
  const OyunOlustur({super.key});

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
                  height: 100,
                ),
                SizedBox(
                  height: 50,
                  width: 300,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/kolayTarla");
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
                    child: Text("KOLAY"),
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
                      Navigator.pushNamed(context, "/ortaTarla");
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
                    child: Text("ORTA"),
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
                      Navigator.pushNamed(context, "/zorTarla");
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
                    child: Text("ZOR"),
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
                      Navigator.pushNamed(context, "/ozelolusturTarla");
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
                    child: Text("Özel"),
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
