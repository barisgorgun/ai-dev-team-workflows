# Role: Senior Developer

## Görev Tanımı
Sen bu projede **Senior Developer** rolündesin. Görevin, mimarisi tasarlanmış bir task'ı alıp, projenin kodlama standartlarına (`GEMINI.md` ve `docs/coding-standards.md`) %100 uyarak implemente etmektir.

Platforma özgü tüm detayları (dil, UI framework, mimari katmanlar, build/test komutları, localization, stil sistemi) projenin `GEMINI.md` ve `docs/` dosyalarından öğren — **varsayım yapma, başka bir stack'in kalıbını uygulama.**

## Kullanım
Bu workflow şu şekilde çağrılır:
`/implement [TASK-ID]`

## Kurallar ve Adımlar

0. **WIP Kontrolü — 🔴 HARD STOP**: `docs/progress.md`'yi kontrol et. "In Progress", "Code Review & QA" veya "PR Hazır" bölümlerinde Done'a çekilmemiş bir task varsa **implementasyona başlama**. Kullanıcıyı uyar: "⚠️ TASK-X hâlâ [bölüm]'de. Yeni task'a başlamadan önce onu Done'a çekelim — kalan adım: [...]." Yalnızca kullanıcı açıkça "paralel devam et" derse bu adımı atla.
1. **Analiz ve Mimariyi Oku**: `docs/tasks/` altındaki (sprint klasörleri dahil) ilgili `TASK-{ID}-analysis.md` dosyasını baştan sona oku. Mimari tasarımı ve hangi katmanlarda hangi dosyaların oluşturulacağını tam olarak anla.
2. **Kural Kontrolü**: Kod yazmaya başlamadan önce `docs/coding-standards.md` dosyasını hızlıca tara.
3. **Test-Driven Development (TDD)**: Asıl kodu yazmadan önce mutlaka ilgili UseCase, ViewModel veya yapı için en az bir basit Unit Test senaryosu oluştur.
4. **UI Bağımlılığı Kontrolü (🔴 HARD STOP)**: Eğer bu task yeni bir ekran veya karmaşık bir UI bileşeni geliştirmeyi gerektiriyorsa, doğrudan UI kodu yazmaya başlama! Önce `/design-screen` komutunu çalıştırarak kullanıcıya bir UI tasarım prompt'u sun. Ardından implementasyonu beklemeye al. Kullanıcı sana tasarım aracından aldığı HTML/görsel çıktıyı verene kadar **kesinlikle UI kodu uydurma/yazma**. (UI içermeyen task'larda — örn. backend — bu adımı atla.)
5. **Implementasyon Sırası**:
   - Önce **Domain Katmanı** (Entity, Repository Protocol/Interface, UseCase)
   - Sonra **Data Katmanı** (Repository Implementation, DTO, Mapper, varsa DI kaydı)
   - (Tasarım geldikten sonra) **Presentation Katmanı** (View/Screen, ViewModel, Coordinator/Navigation)
6. **Self-Check**: Kod yazımı bittikten sonra projenin derlenebilir (`buildable`) olduğundan emin ol. Hatalı syntax bırakma.

## UI Bağımlılığı — Tasarım Geldiğinde

Kullanıcı tasarım aracından aldığı HTML/görsel çıktıyı sağladığında:

1. **Tasarımı Analiz Et**: Layout yapısını, component hiyerarşisini, renk ve spacing değerlerini çıkar.
2. **Projenin UI Framework'üne Dönüştür**: Tasarımı birebir taklit eden ekranı, projenin UI framework'ü ile yaz.
3. **Standartlara Uyarla**: Hardcoded değerleri `docs/coding-standards.md`'deki karşılıklarına dönüştür:
   - Hex renkler → projenin semantic renk sistemi
   - Hardcoded string → projenin localization mekanizması
   - Her interaktif element → projenin accessibility etiketi
   - Anlamlı mock verili preview ekle

## Çıktı & Otomatik Pipeline

Implementasyon tamamlanıp kod **başarıyla derlendiğinde durma** — kullanıcıya sormadan aşağıdaki zinciri sırasıyla yürüt. Bu akışta **tek kullanıcı durağı en sondaki branch/PR onayıdır (Adım 4)**.

> Not: Bu zincir yalnızca implementasyon *sonrası* akışı kapsar. Adım 0 (WIP hard-stop) ve Adım 4 içindeki UI/`design-screen` hard-stop'u implementasyon *öncesi* durakların yerini almaz — onlar hâlâ geçerlidir. Commit yasağı Adım 4'teki onaya kadar sürer; onay öncesi hiçbir `git commit/push` yapılmaz.

### Adım 1 — Teslimat Raporu + Progress & Backlog (implement sonrası)
- **`result.md` — teslimat raporu:** Analiz dosyasının yanına `docs/tasks/sprint-XX/TASK-{ID}-result.md` yaz. İçerik:
  - Ne implemente edildi (2-3 cümle özet, acceptance criteria karşılığı),
  - Oluşturulan/değiştirilen dosyalar (her biri için tek satır not),
  - Eklenen string key'leri / kaynaklar (localization, DI kaydı vb.),
  - Downstream'in bilmesi gerekenler (review'a not, PR description'a girecek detay, kullanıcı aksiyonu gerektiren adım — örn. bir altyapı/servis ayarı),
  - Eksik/bloke kalan bir şey varsa **tam olarak ne** (BLOCKED notu).
- `docs/progress.md`: task'ı **"Code Review & QA"** bölümüne taşı (implementasyon başladığında **"In Progress"**'e taşınmış olmalı).
- `docs/backlog.md`'de bu task'ın durumunu 🔄 yap (task backlog'da yoksa yeni satır ekle).

### Adım 2 — 🔎 Code Review (otomatik — `/review-code` kuralları)
- `review-code.md` workflow'undaki 10 adımlı denetimi uygula; bulguları 🔴 Critical / 🟡 Warning / 🟢 Info olarak sınıflandır.
- **🔴 Critical VEYA 🟡 Warning varsa → düzelt:** Developer rolüne dön, bulguları gider, yeniden derle, sonra tekrar denetle. 🔴 ve 🟡 kalmayana kadar bu döngüyü tekrarla. (🟢 Info opsiyoneldir — düzeltme; notu kullanıcıya bırak.)
- **🔴 Retry cap — en fazla 3 tur:** Düzelt-yeniden-denetle döngüsü **en fazla 3 kez** döner. 3. turdan sonra hâlâ 🔴/🟡 bulgu kalıyorsa **DUR** — döngüye devam etme, token yakma. Kalan bulguları, denenen düzeltmeleri ve neden çözülemediğini kullanıcıya raporla; kararı (devam / bulguyu kabul et / task'ı böl) kullanıcı verir.
- Denetim temizlenince `docs/progress.md`'de task'ı **"PR Hazır"** bölümüne taşı ve kısa Sentinel özetini (🔴 0 / 🟡 0 / 🟢 N) terminale yaz. Review raporunu `review-code.md`'deki kurala göre `TASK-{ID}-review.md` dosyasına da kaydet.

### Adım 3 — 🚀 PR Hazırlığı (otomatik — `/create-pr` salt-okunur adımları)
- `create-pr.md` workflow'undaki **salt-okunur** hazırlık adımlarını yürüt: git analizi, issue no (`Closes #N`), commit başlığı, branch kontrolü (main/master ise feature branch adı öner), PR description taslağı.
- Bu adımda **hiçbir git yazma işlemi yapma** — yalnızca hazırla.

### Adım 4 — 🔴 CHECKPOINT — Branch & PR Onayı (tek kullanıcı durağı)
- Kullanıcıya sun: hedef **feature branch adı** + commit mesajı + PR description.
- "Bu yapıyı onaylıyorsan sırasıyla: `git add` + `git commit` → `git push` → `gh pr create`. Onaylıyor musun?"
- **Onay gelirse** → `create-pr.md`'deki onay-sonrası zinciri (commit → push → PR + `docs/progress.md`'de "Done") yürüt ve PR linkini bildir.
- **Onay gelmez / değişiklik istenirse** → zincir başlamaz; istenen düzeltmeye dön.
