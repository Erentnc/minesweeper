import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MayinHomePage extends StatelessWidget {
  const MayinHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/mayin.png',
              fit: BoxFit.fill,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 300,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/oyunOlustur");
                    },
                    style: OutlinedButton.styleFrom(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        side: BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade400),
                    child: Text("OYUN OLUŞTUR"),
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  height: 50,
                  width: 300,
                  child: OutlinedButton(
                    onPressed: () {
                      SystemNavigator.pop();
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
                    child: Text(
                      "OYUNDAN ÇIK",
                    ),
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
