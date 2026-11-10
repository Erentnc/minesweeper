# Minesweeper — Neon Edition

Flutter ve Riverpod ile geliştirilmiş modern **Minesweeper (Neon Edition)** oyunu. Klasik mayın tarlası stratejisini neon görsel efektler, akıcı animasyonlar, sentezlenmiş ses efektleri, dokunsal geri bildirim ve kalıcı istatistiklerle birleştirir.

---

## 🎮 Özellikler

* **Açılış Ekranı & Özel Marka Tasarımı:**
  * Uygulama açılışında özel neon logo ([`mine_logo.png`](assets/images/mine_logo.png)) ve animasyonlu [`SplashScreen`](lib/screens/splash/splash_screen.dart) ile başlayıp [`HomeScreen`](lib/screens/home/home_screen.dart) menüsüne geçiş
  * Android Adaptive Icon (`mipmap-anydpi-v26`) desteği ile tüm platform başlatıcılarında tam alan dolgulu uygulama ikonu
* **4 Oyun Modu:** Kolay (`5×5`, `3` mayın), Orta (`8×8`, `10` mayın), Zor (`10×10`, `15` mayın) ve **Özel** (`6×6`–`16×16` tahta boyutu, yoğunluk kontrollü mayın seçimi)
* **İlk Tıklama Güvenliği:** İlk hamlede tıklanan hücre ve `3×3` çevresi (yeterli alan varsa) mayından arındırılır; ayarlardan klasik moda geçilebilir
* **Bayrak & Hızlı Açma (Chording):**
  * Uzun basma, sağ tık (masaüstü/web) veya **Kaz / Bayrak** mod anahtarı ile bayrak yerleştirme
  * Açılmış bir sayı hücresine dokunarak çevredeki bayrak sayısı eşleştiğinde kalan komşuları tek dokunuşta açma
* **Neon Görsel Efektler & Animasyonlar:**
  * Sibernetik arka plan ızgarası (`NeonBackground`) ve 4 seçilebilir **Neon Tema Vurgusu** (`Siber Mavi`, `Matrix Yeşili`, `Synthwave`, `Güneş Enerjisi`)
  * Tıklama merkezinden dalga halinde yayılan hücre açılma animasyonları (`CellRevealAnimation`)
  * Mayına basıldığında tahta sarsıntısı (`BoardShakeWrapper`) ve merkezden yayılan şok dalgası (`ExplosionOverlay`)
  * Kazanma anında neon konfeti yağmuru (`ConfettiOverlay`) ve canlı emoji durum göstergesi (`🙂` / `😮` / `😎` / `😵`)
  * Büyük tahtalar için `InteractiveViewer` ile yakınlaştırma ve kaydırma desteği
* **Ses Efektleri & Titreşim:** `assets/audio/` içindeki sentezlenmiş WAV varlıklarıyla açma, zincirleme açılış, bayrak, patlama ve zafer sesleri (`audioplayers`) + dokunsal geri bildirim (`HapticFeedback`)
* **Kalıcı Skor & İstatistikler:** `SharedPreferences` ile zorluk bazlı en iyi süreler, ortalama süreler, kazanma oranı, yeni rekor rozeti ve seri takibi

---

## 🧱 Proje Mimarisi

```text
assets/
├── audio/                                     # Sentezlenmiş ses efektleri (reveal, cascade, flag, explosion, win)
└── images/mine_logo.png                       # Uygulama ve açılış/ana sayfa logosu

lib/
├── main.dart                                  # ProviderScope + SharedPreferences ön yükleme + dinamik neon tema
├── animations/
│   ├── cell_reveal_animation.dart             # Dalga gecikmeli hücre açılma & basma ölçek animasyonu
│   ├── confetti_animation.dart                # Kazanma anı neon konfeti efekti
│   └── explosion_animation.dart               # Tahta sarsıntısı ve patlama şok dalgası
├── core/
│   ├── constants/                             # Renk paleti, boyutlar ve arayüz metinleri
│   ├── router/app_router.dart                 # Merkezi rota yönetimi ve sayfa geçiş animasyonları
│   ├── services/                              # Ses (audioplayers) ve yerel depolama (SharedPreferences)
│   ├── theme/app_theme.dart                   # Dinamik neon tema ve arrow_back_ios_new_rounded geri ikonu
│   └── utils/haptic_helper.dart               # Dokunsal titreşim yardımcıları
├── models/
│   ├── app_settings.dart                      # Ayarlar ve 4 neon tema vurgusu
│   ├── cell_model.dart                        # Değişmez (immutable) hücre modeli
│   ├── difficulty.dart                        # Zorluk konfigürasyonları ve özel sınırlar
│   ├── game_state.dart                        # Oyun durumu, dalga mesafesi ve patlama yardımcıları
│   └── game_stats.dart                        # Zorluk bazlı rekor ve seri istatistikleri
├── providers/
│   ├── game_provider.dart                     # Riverpod oyun motoru (ilk tıklama güvenliği, BFS, chording, sayaç)
│   ├── settings_provider.dart                 # Kalıcı ayarlar yöneticisi
│   └── stats_provider.dart                    # Kalıcı skor ve istatistik yöneticisi
├── screens/
│   ├── splash/splash_screen.dart              # Logo animasyonlu açılış ekranı
│   ├── home/home_screen.dart                  # Logo, başlık ve ana menü
│   ├── difficulty/                            # Zorluk seçimi ve özel tarla kurulum ekranları
│   ├── game/game_screen.dart                  # Tüm seviyeler için tek parametrik oyun ekranı
│   ├── stats/stats_screen.dart                # İstatistikler ve en iyi süreler
│   └── settings/settings_screen.dart          # Ses, titreşim, güvenlik ve tema ayarları
└── widgets/                                   # Yeniden kullanılabilir oyun tahtası, hücre ve arayüz bileşenleri

test/
├── game_provider_test.dart                    # Oyun motoru birim testleri
├── stats_and_settings_test.dart             # Kalıcı istatistik ve ayar testleri
└── widget_test.dart                           # Açılış, navigasyon, bayrak, patlama ve kazanma widget testleri
```

---

## ⚙️ Kurulum, Test ve Derleme

> **Not:** Android derlemesi Flutter `3.41.9` / JDK `17+` ile uyumlu olacak şekilde Gradle `8.14`, Android Gradle Plugin `8.11.1` ve Kotlin `2.2.20` sürümleriyle yapılandırılmıştır.

1. Bağımlılıkları yükle:
   ```bash
   flutter pub get
   ```
2. Statik analiz ve testleri çalıştır:
   ```bash
   flutter analyze
   flutter test
   ```
3. Uygulamayı çalıştır veya APK derle:
   ```bash
   flutter run
   flutter build apk --debug
   ```

---

**Geliştirici:** Eren Tunç
**GitHub:** [Erentnc](https://github.com/Erentnc)
