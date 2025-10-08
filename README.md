# Minesweeper / Mayın Tarlası

Flutter ile geliştirilmiş klasik **Mayın Tarlası (Minesweeper)** oyunu. Oyuncular, mayınlara basmadan tüm güvenli alanları açmaya çalışır. Uygulama farklı zorluk seviyeleri ve özel oyun modu içerir.

---

## 🎮 Özellikler

* **Dört oyun modu:** Kolay, Orta, Zor ve Özel seviye
* **Özel seviye:** Kullanıcı, mayın sayısını kendi belirleyebilir
* **Rastgele mayın yerleşimi**
* **Temiz ve sade arayüz** (Material Design uyumlu)
* **Oyun yeniden başlatma ve sıfırlama** seçenekleri
* **Mobil ve masaüstü uyumlu Flutter yapısı**

---

## 🧱 Proje Yapısı

```
lib/
├── main.dart                 # Uygulama başlangıç noktası
├── mayin_home_page.dart      # Ana menü / giriş ekranı
├── oyun_olustur.dart         # Oyun tahtasının oluşturulması ve mantığı
├── seviye/
│   ├── kolay.dart            # Kolay seviye ayarları ve grid yapısı
│   ├── orta.dart             # Orta seviye ayarları
│   ├── zor.dart              # Zor seviye ayarları
│   ├── ozel.dart             # Özel seviye ayar ekranı (kullanıcı mayın sayısı seçer)
│   └── ozel_oyna.dart        # Özel seviye oyun ekranı
```

---

## ⚙️ Kurulum ve Çalıştırma

Projeyi kendi bilgisayarında çalıştırmak için aşağıdaki adımları izle:

1. Depoyu klonla:

   ```bash
   git clone https://github.com/Erentnc/minesweeper.git
   cd minesweeper
   ```

2. Bağımlılıkları indir:

   ```bash
   flutter pub get
   ```

3. Uygulamayı çalıştır:

   ```bash
   flutter run
   ```

   veya web üzerinde çalıştırmak için:

   ```bash
   flutter run -d chrome
   ```

---

## 🧩 Kod Özeti

* `main.dart`: Uygulamanın başlangıç noktası, MaterialApp yapısı burada tanımlanır.
* `mayin_home_page.dart`: Oyuncunun seviye seçtiği veya özel oyun oluşturduğu ana sayfa.
* `oyun_olustur.dart`: Oyun tahtasının oluşturulması, hücrelerin kontrolü ve mayın sayısının belirlenmesi.
* `seviye/` klasörü: Zorluk seviyelerine göre oyun ekranlarını içerir. Her biri farklı grid boyutu ve mayın sayısı içerir.

---

## 📱 Kullanım

1. Uygulama açıldığında seviye seçme ekranı gelir.
2. Kolay, Orta, Zor veya Özel seçeneklerinden biri seçilir.
3. Hücrelere tıklayarak güvenli bölgeleri aç, mayınlara basmadan tüm alanı temizle.
4. Özel modda, oyun başlamadan önce mayın sayısını belirleyebilirsin.

---

## 💡 Geliştirici Notları

* Kodlar Flutter framework’ü ile yazılmıştır.
* Arayüz sade tutulmuştur ve görsel olarak klasik Minesweeper mantığını korur.

---



## 🧪 Testler

Testleri çalıştırmak için:

```bash
flutter test
```

---

## 🤝 Katkıda Bulunma

1. Fork oluşturun
2. Yeni bir branch açın (`feature/özellik-adi`)
3. Değişikliklerinizi commit edin
4. Pull Request gönderin

---

**Geliştirici:** Eren Tunç
**GitHub:** [Erentnc](https://github.com/Erentnc)
