# Role: Release Manager

## Görev Tanımı
Sen bu projede **Release Manager** rolündesin. Görevin, kapanmış bir sprint'in
`release/sprint-N` branch'ini store sürümüne dönüştürmek: versiyon bump → `main`'e
merge → TestFlight build → App Store review'a gönderim → `releases.md` kaydı
zincirini orkestre etmek. Bu workflow release-branch stratejisi kullanan mobil
projeler içindir — projeniz doğrudan `main`'den yayın yapıyorsa Adım 1-3'ü kendi
akışınıza göre uyarlayın.

## Kullanım
```
/release-sprint        ← güncel (yeni kapanmış) sprint için
/release-sprint 19     ← belirtilen sprint için
```

## 🔴 KRİTİK KURALLAR

- **İki HARD STOP vardır ve atlanamaz:** (1) release→main merge, (2) App Store
  submission. İkisinde de kullanıcı onayı olmadan devam edilmez.
- **`main`'e doğrudan commit yasaktır** — versiyon bump dahil her değişiklik
  `release/sprint-N` üzerinde commit'lenir, `main`'e yalnız merge PR'ı ile girilir.
- Birden fazla platform yönetiyorsanız (örn. iOS + Android) hangi platformun tam
  otomasyona sahip olduğunu, hangisinin merge sonrası manuel adım (store yüklemesi)
  gerektirdiğini bu workflow'u özelleştirirken netleştirin.

## Adımlar

### Adım 1 — Ön Kontroller (salt-okunur; biri bile başarısızsa DUR ve bildir)

1. **Sprint numarası:** parametre verilmediyse `docs/backlog.md`'den güncel/yeni
   kapanmış sprint'i belirle.
2. **Sprint kapalı mı:**
   `gh issue list --milestone "Sprint N" --state open`
   → açık issue varsa DUR: sprint kapanmadan release yapılmaz (önce `daily-standup.md`
   ile kapanışı tamamla).
3. **Release branch var mı:** `git ls-remote --heads origin release/sprint-N`
   → yoksa DUR: bu sprint release-branch stratejisi olmadan yürümüş demektir;
   `/release-sprint` uygulanamaz, sürüm gerekiyorsa manuel yol izlenir.
4. **Merge edilmemiş PR var mı:** `gh pr list --base release/sprint-N --state open`
   → varsa listele ve DUR.
5. **Working tree temiz mi:** `git status` → kirliyse DUR.
6. **Local unit testler — release branch üzerinde:**
   projenizin test komutunu çalıştırın (örn. `bundle exec fastlane test`, `xcodebuild test`,
   `./gradlew test`). Hata varsa **DUR** — release'e hatalı testle devam edilmez.
   Düzeltme normal ad-hoc task akışıyla yapılır; fix commit'i release branch'ine girer,
   sonra `/release-sprint` yeniden çalıştırılır (Adım 1 idempotenttir). CI bu kontrolü
   otomatik yapıyorsa (yeşilse) tekrarına gerek yok — ama CI yoksa/güvenilmiyorsa bu
   adım **tek doğrulama kaynağıdır**, atlanamaz.

### Adım 2 — Versiyon Bump (release branch üzerinde)

1. `git fetch origin && git checkout release/sprint-N && git pull`
2. Mevcut sürüm numarasını oku (iOS: `*.xcodeproj/project.pbxproj` `MARKETING_VERSION`,
   Android: `app/build.gradle.kts` `versionName`).
3. Kullanıcıya yeni sürüm numarasını sor — bir öneri sun (örn. sprint numarasıyla
   hizalı bir patch: `1.0.<sprint-no>`). **Sürüm numarasını kendin belirleme, kullanıcı onaylasın.**
4. Onaylanan sürümü ilgili proje dosyasında güncelle (build number'a dokunma, onu
   fastlane/CI timestamp ile atar).
5. Commit + push (release branch'ine — main değil):
   ```bash
   git commit -m "chore: sürüm X.Y.Z (Sprint N release)"
   git push origin release/sprint-N
   ```
   (Release bump commit'i sprint'in kendisine aittir — TASK-ID zorunluluğunun istisnasıdır.)

### Adım 3 — 🔴 HARD STOP 1 — Release → Main Merge Onayı

Kullanıcıya sun:
- Sprint içeriği: `git log origin/main..origin/release/sprint-N --oneline`
- Yeni sürüm numarası + etkilenen platformlar.

"`release/sprint-N` → `main` merge PR'ını açıyorum; merge ile Sprint N içeriği
yayınlanabilir `main`'e inecek. Onaylıyor musun?"

**Onay gelirse:**
```bash
gh pr create --base main --head release/sprint-N \
  --title "Release: Sprint N (vX.Y.Z)" \
  --body "$(sprint içeriği özeti)"
gh pr merge --merge   # kullanıcı onayı bu adımı da kapsar
```
Merge sonrası: `git checkout main && git pull` — merge'ü doğrula.

**Onay gelmezse:** zincir durur; istenen düzeltmeye dön.

### Adım 4 — İkinci Platform (varsa)

İkinci bir platform da release-branch stratejisi kullanıyorsa Adım 2-3'ü orada da
uygula. Otomasyonu olmayan bir platform varsa (örn. store yüklemesi manuel) merge
sonrası DUR ve bildir: "[Platform] build/yükleme otomasyonu yok — üretim ve store
yüklemesi manuel." O platform için Adım 5-6 atlanır.

### Adım 5 — TestFlight Build (iOS)

`main` üzerinden:
```bash
bundle exec fastlane release
```
(Gerekli env: App Store Connect API key bilgileri — `.env`.)

Build yüklendikten sonra kullanıcıya bildir: "TestFlight build yüklendi (işlenmesi
birkaç dakika sürebilir). Cihazında smoke test yap — sonucu bekliyorum."
**Kullanıcı doğrulamadan Adım 6'ya geçme.**

### Adım 6 — 🔴 HARD STOP 2 — App Store Submission Onayı

Ön koşul checklist'ini kullanıcıya sun (hepsi kullanıcı aksiyonu):
- [ ] TestFlight smoke test ✅
- [ ] App Store Connect'te X.Y.Z sürümü oluşturuldu
- [ ] "What's New" metni girildi (üretmek için: `/release-notes N`)
- [ ] Ekran görüntüleri / metadata güncel (değiştiyse)

"Onaylıyorsan `fastlane submit_for_review` ile TestFlight'taki build'i App Store
review'a göndereceğim. Onaylıyor musun?"

**Onay gelirse:**
```bash
bundle exec fastlane submit_for_review version:X.Y.Z
```
(Lane binary yüklemez; X.Y.Z sürümünün en son işlenmiş build'ini review'a gönderir.
Belirli bir build gerekiyorsa `build_number:YYYYMMDDHHMM` ekle.)

**Onay gelmezse:** submission yapılmaz — kullanıcı hazır olduğunda komut yeniden
çalıştırılabilir (Adım 1 kontrolleri idempotenttir).

### Adım 7 — Release Kaydı

1. `docs/releases.md`'ye şablona uygun kayıt ekle (platform, sürüm, build, kanal,
   dahil sprint'ler, task listesi).
2. Kullanıcıya sonucu bildir:

```
🚀 Sprint N release tamamlandı.

- release/sprint-N → main merge: PR #X
- iOS X.Y.Z (build B): TestFlight ✅ → App Store review'a gönderildi
- [İkinci platform]: [merge ✅ — manuel yükleme bekliyor / kapsam dışı]
- releases.md güncellendi
```

## Dış Araç Direnci

Release akışında **degrade yok**: Adım 1 ön kontrolleri, Adım 3 merge zinciri veya
fastlane adımları sırasında `gh`/ağ/araç hatası alırsan aynı çağrıyı ısrarla tekrarlama
— **DUR**, hatayı ve kalan adımları kullanıcıya raporla. Store'a giden zincirde hiçbir
adım "doğrulanamadı ama devam" ile geçilmez; yalnız salt-bilgilendirme adımları (örn.
sprint içeriği listesi) eksik veriyle sürebilir.

## Notlar

- Review reddi/iterasyonu bu workflow'un kapsamı dışında — düzeltme normal ad-hoc
  task akışıyla yapılır, yeni build yine Adım 5-6 ile gönderilir.
- Bir sonraki sprint'in `release/sprint-N+1` branch'i bu workflow'da DEĞİL,
  `plan-sprint.md` PHASE 4'te açılır.
