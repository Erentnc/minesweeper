/// Uygulama genelinde kullanılan tüm kullanıcı arayüzü metinleri.
class AppStrings {
  AppStrings._();

  // Uygulama genel
  static const String appName = 'Minesweeper';
  static const String appTitle = 'MINESWEEPER';
  static const String appSubtitle = 'NEON EDITION';

  // Ana sayfa
  static const String homeTagline = 'Strateji, hız ve refleks.';
  static const String startGame = 'OYNA';
  static const String statsTitle = 'İSTATİSTİKLER';
  static const String settingsTitle = 'AYARLAR';
  static const String exitGame = 'ÇIKIŞ';

  // Seviye seçimi
  static const String selectDifficulty = 'ZORLUK SEÇ';
  static const String selectDifficultyHint =
      'Oyun tahtası boyutunu ve mayın yoğunluğunu belirle';
  static const String back = 'GERİ DÖN';

  // Zorluk isimleri
  static const String easy = 'KOLAY';
  static const String medium = 'ORTA';
  static const String hard = 'ZOR';
  static const String custom = 'ÖZEL';

  // Özel kurulum
  static const String customSetupTitle = 'ÖZEL TARLA OLUŞTUR';
  static const String customSetupHint = 'Tahta boyutu ve mayın sayısını özelleştir';
  static const String gridSizeLabel = 'Tahta Boyutu';
  static const String mineCountLabel = 'Mayın Sayısı';
  static const String startCustomGame = 'ÖZEL OYUNU BAŞLAT';

  // Oyun ekranı
  static const String remainingMines = 'MAYIN';
  static const String elapsedTime = 'SÜRE';
  static const String digMode = 'Kaz';
  static const String flagMode = 'Bayrak';
  static const String restartGame = 'Yeniden Başlat';
  static const String resetZoom = 'Yakınlaştırmayı Sıfırla';
  static const String gameControlsHint =
      'Dokun: Aç  •  Basılı tut / Sağ tık: Bayrak  •  Sayıya dokun: Hızlı aç';

  // Oyun sonu diyalogları
  static const String winTitle = 'TEBRİKLER!';
  static const String winMessage = 'Tüm mayınları başarıyla temizledin!';
  static const String lossTitle = 'OYUN BİTTİ';
  static const String lossMessage = 'Bir mayına bastın! Tekrar dene.';
  static const String newRecordBadge = 'YENİ REKOR!';
  static const String bestTimeLabel = 'EN İYİ';
  static const String playAgain = 'Tekrar Oyna';
  static const String changeDifficulty = 'Seviye Seç';
  static const String mainMenu = 'Ana Menü';

  // Ayarlar ekranı
  static const String soundEffectsLabel = 'Ses Efektleri';
  static const String soundEffectsDesc = 'Hücre açma, bayrak, patlama ve zafer sesleri';
  static const String hapticsLabel = 'Dokunsal Titreşim';
  static const String hapticsDesc = 'Hamlelerde hafif titreşim geri bildirimi';
  static const String firstClickSafetyLabel = 'İlk Tıklama Güvenliği';
  static const String firstClickSafetyDesc =
      'İlk hamlede mayına basılmaz, güvenli alanla başlarsın';
  static const String themeAccentLabel = 'Neon Tema Vurgusu';

  // İstatistik ekranı
  static const String totalGames = 'TOPLAM OYUN';
  static const String winRate = 'KAZANMA ORANI';
  static const String currentStreak = 'MEVCUT SERİ';
  static const String bestStreak = 'EN İYİ SERİ';
  static const String resetStats = 'İstatistikleri Sıfırla';
  static const String resetStatsConfirmTitle = 'İstatistikler Sıfırlansın mı?';
  static const String resetStatsConfirmBody =
      'Tüm en iyi süreler ve kazanma kayıtları kalıcı olarak silinecek.';
  static const String cancel = 'Vazgeç';
  static const String confirmReset = 'Sıfırla';
}
