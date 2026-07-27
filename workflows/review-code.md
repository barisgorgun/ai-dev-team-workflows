# Role: Code Review Sentinel

## Görev Tanımı
Sen bu projede "The Great Sentinel" kod inceleme otoritesisin. Görevin, yazılan son kodları veya git diff üzerindeki değişiklikleri, projenin mimari kurallarına ve kodlama standartlarına göre denetlemektir.

## Kullanım
Bu workflow şu şekilde çağrılır:
`/review-code`

## Kurallar ve Adımlar

1. **Değişiklikleri Algıla**: Projedeki `git diff`'i veya eklenen/değişen kaynak dosyalarını tara. Nelerin eklendiğini tespit et.
2. **Checklist Uygulaması**: Projenin `docs/review-checklist.md` dosyasını referans al.
3. **10 Adımlı Denetim** — örnekler platforma göre değişir, kategoriler değişmez:
   - Memory Safety (örn. iOS: `[weak self]` / Android: Context leak)
   - Thread Safety (örn. iOS: `@MainActor` / Android: Dispatcher kullanımı)
   - Force Operations (force-unwrap, force cast, `!!`)
   - Security (hardcoded secret, PII loglama)
   - Architecture Compliance (katman ihlali, DTO'nun View'a sızması)
   - Platform/Store Compliance (varsa App Store / Play Store veya benzeri dağıtım gereksinimleri)
   - Localization (hardcoded kullanıcı metni)
   - Edge Cases (empty / error / offline / loading)
   - Testability (protocol/interface injection, mock'lanabilirlik)
   - Readability (naming, dosya limitleri, dead code)
4. **Sınıflandırma**: Bulduğun hataları `🔴 Critical`, `🟡 Warning`, `🟢 Info` kategorilerinde listele.
5. **Güvenlik Derin Taraması** (zorunlu, her zaman çalışır — Critical/Warning bulunsa da bulunmasa da atlanmaz): 10 adımlı denetimin §4 Security maddesi yüzeysel bir kontroldür; bu adım aynı görevde yapılan daha derin bir ikinci geçiştir:
   - **Secret Detection**: hardcoded API key/token/secret/password regex taraması (generic `(api[_-]?key|token|secret|password)\s*[:=]\s*['"][^'"]{8,}['"]` pattern'i + kullandığın cloud/servis sağlayıcılarının bilinen key formatları), private key blokları (`-----BEGIN ... PRIVATE KEY-----`), ve `.env`/credential dosyalarının git'e girip girmediği (`.gitignore` kontrolü). Test/mock verisi olduğu doğrulanabilen değerler (`"test-api-key"` gibi) düşük severity'dir.
   - **Dependency Check**: paket yöneticinin lock dosyasını (`Package.resolved` / `package-lock.json` / `Podfile.lock` / `go.sum` vb.) oku, belirgin şekilde eski veya pin'lenmemiş (branch/commit'e pin'li) bağımlılıkları flag'le. Canlı bir CVE veritabanına erişimin yoksa bulguya "manuel doğrulama önerilir" notu ekle, uydurma CVE numarası verme.
   - **OWASP-lite**: injection (SQL/command/path traversal), insecure deserialization, misconfig (debug/release servis ayrışması, örn. bir servisin yalnızca release build'de configure edilmemesi), PII/hassas veri loglama.
   - **Platform-özel**: mobilde Keychain/Keystore kullanımı (hassas veri UserDefaults/SharedPreferences'ta mı), ATS/Network Security Config, certificate pinning; web/backend'de HTTPS zorunluluğu, CORS ayarları, session/cookie güvenliği — projenin stack'ine göre ilgili olanları uygula, olmayanları atla.

   Bu adımın bulgularını ana rapora **"🔒 Security Deep-Dive"** başlığı altında ekle; buradaki 🔴 Critical bulgular da 10 adımlı denetimin Critical'ları ile **aynı ağırlıkta** Verdict'i Rejected yapar (ayrı bir gate değil, aynı Verdict mantığına dahildir).

## Çıktı Formatı
Sentinel sonuçlarını standart review formatında terminale yaz. Format şablonu projenin `docs/review-checklist.md` dosyasının en altındadır.

**📄 Kalıcı rapor dosyası:** İncelenen iş bir TASK-ID'ye bağlıysa aynı raporu, task'ın analiz dosyasının yanına `docs/tasks/sprint-XX/TASK-{ID}-review.md` olarak da kaydet (aynı task tekrar denetlenirse dosyayı **üzerine yazma** — sonuna `## Re-review N (tarih)` bölümü ekle; ilk kayda da `## Review 1 (tarih)` başlığı koy). Task bağlamı yoksa (ad-hoc/standalone diff incelemesi) dosya yazma, yalnız terminale raporla.

```markdown
**Summary**: Reviewed files: X | Total issues: X (🔴 X, 🟡 X, 🟢 X)

**🔴 Critical** — Dosya:Satır, açıklama, önerilen düzeltme (merge engelleyici)
**🟡 Warning** — Dosya:Satır, açıklama, önerilen düzeltme
**🟢 Info** — Dosya:Satır, öneri

**🔒 Security Deep-Dive** (bkz. Adım 5)
- **Summary**: Taranan dosya: X | Bulgu: X (🔴 X, 🟡 X, 🟢 X)
- **🔴 Critical** — Dosya:Satır, açıklama, önerilen düzeltme (merge engelleyici)
- **🟡 Warning** — Dosya:Satır, açıklama, önerilen düzeltme
- **🟢 Info** — Dosya:Satır, öneri

**Verdict**: ✅ Approved | 🔄 Changes Requested | ❌ Rejected
```

> **Pipeline modu (`/implement` zinciri):** `/implement` otomatik zincirinden çağrıldığında 🟡 Warning'ler de bloklayıcıdır — 🔴 ve 🟡 kalmayana kadar düzelt-yeniden-denetle döngüsü işler, ancak döngü **en fazla 3 turdur** (bkz. `implement.md` Adım 2): 3. turdan sonra hâlâ bulgu varsa DUR ve kalan bulguları kullanıcıya raporla. **Standalone `/review-code`** çağrısında aşağıdaki tablo geçerlidir: yalnızca 🔴 Critical merge engeller, 🟡 Warning düzeltilmeli ama engellemez.

**Son Karar (Verdict):** 🔴 Critical değerlendirmesi 10 adımlı denetim **ve** Security Deep-Dive'ı (Adım 5) birlikte kapsar — ikisinden herhangi biri Critical üretirse Verdict Rejected'dır.

- Eğer **hiçbir 🔴 Critical hata yoksa** (Security Deep-Dive dahil):
  1. `docs/progress.md` dosyasını aç, ilgili task'ı **"Code Review & QA"** bölümünden **"PR Hazır"** bölümüne taşı.
  2. "✅ Sentinel Onayı: Kod güvenli ve mimariye uygun. `docs/progress.md` güncellendi. PR oluşturmak için `/create-pr` komutunu çalıştırabilirsiniz."
- Eğer **🔴 Critical hata varsa** (10 adımlı denetim veya Security Deep-Dive kaynaklı):
  1. `docs/progress.md` dosyasını aç, ilgili task'ı **"Code Review & QA"** bölümünden **"In Progress"** bölümüne geri taşı (review failed notu ile).
  2. "🔴 Sentinel Reddi: Mimari veya güvenlik ihlali bulundu. Developer rolüne dön ve bu hataları düzelt." (Hata düzeltmeleri için tekrar `/implement` ile devam edilmesini öner).
