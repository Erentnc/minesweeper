/// Uygulama genelinde kullanılan sabit boyut, boşluk ve yuvarlatma değerleri.
class AppDimensions {
  AppDimensions._();

  // Boşluklar (Spacing)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  // Kenar yuvarlatma (Radius)
  static const double radiusSm = 6.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 18.0;
  static const double radiusXl = 24.0;

  // Buton ve kart ölçüleri
  static const double buttonHeight = 56.0;
  static const double maxContentWidth = 480.0;
  static const double boardMaxWidth = 520.0;

  // Özel oyun sınırları
  static const int minCustomGridSize = 6;
  static const int maxCustomGridSize = 16;
  static const int defaultCustomGridSize = 12;
  static const int minCustomMines = 3;
  static const int defaultCustomMines = 20;
}

