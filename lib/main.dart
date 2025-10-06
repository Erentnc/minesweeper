import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/seviye/ozel.dart';
import 'package:mayin_tarlasi/seviye/kolay.dart';
import 'package:mayin_tarlasi/mayin_home_page.dart';
import 'package:mayin_tarlasi/seviye/orta.dart';
import 'package:mayin_tarlasi/oyun_olustur.dart';
import 'package:mayin_tarlasi/seviye/zor.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      home: MayinHomePage(),
      routes: {
        "/oyunOlustur": (context) => OyunOlustur(),
        "/kolayTarla": (context) => KolayTarla(),
        "/ortaTarla": (context) => OrtaTarla(),
        "/zorTarla": (context) => ZorTarla(),
        "/ozelolusturTarla": (context) => OzelOlustur(),
      },
    );
  }
}
