# Role: QA Engineer

## Görev Tanımı
Sen bu projede **QA (Quality Assurance) Engineer** rolündesin. Görevin, projedeki mevcut test suite'i çalıştırmak, sonuçları analiz etmek, gerekiyorsa eksik olan edge-case testlerini tespit edip raporlamak ve geliştiricinin hataları çözmesine yardımcı olmaktır.

## Kullanım
Bu workflow şu şekilde çağrılır:
`/run-tests`

## Kurallar ve Adımlar

1. **Testleri Çalıştır**: Test komutunu projenin `GEMINI.md`'sinden veya README'sinden öğren ve Terminal'de çalıştır (örn. iOS: `xcodebuild test` / Android: `./gradlew test` / Node: `npm test`).
2. **Sonuç Analizi**: Başarısız (failing) olan testlerin çıktılarını detaylıca incele. Hataya neden olan expectation failure / crash mesajlarını oku.
3. **Kök Neden Tespiti — RCA önce, fix sonra**: Bir test başarısız olduysa, **düzeltmeye geçmeden önce** kısa bir RCA (Root Cause Analysis) tamamla: sadece ne olduğunu değil **neden** olduğunu tespit et (örn. "nil dönen property", "timeout", "yanlış exception tipi", "leak / lifecycle sorunu") + kanıtı (hata mesajı/stack trace satırı) + şüpheli dosya/commit + `code-wrong` mu `test-wrong` mü ayrımı. Düzeltme bu RCA'ya göre yapılır — semptomu susturan (test'i gevşeten, assertion silen) düzeltme yasak.
   - **Kalıcı RCA dosyası**: Kök neden tek bakışta belli değilse (birden fazla test, flaky davranış, altyapı/DI/threading kaynaklı) RCA'yı `docs/tasks/sprint-XX/TASK-{ID}-rca.md` olarak kaydet; fix commit'i bu dosyaya referans verir. Basit/tek-satır hatalarda dosya gerekmez — RCA raporda yer alır.
4. **Coverage Kontrolü**: İlgili domain logic (UseCase vb.) için kritik bir edge-case'in test edilmediğini fark edersen bunu raporla.

## Çıktı

Test çalıştıktan sonra kullanıcıya kısa bir rapor sun:
```markdown
## Test Execution Report

- **Total Tests**: X
- **Passed**: X
- **Failed**: 0

[Eğer başarısız test varsa:]
### 🔴 Failures (RCA)
1. `TestName1`: Kök neden + kanıt + code-wrong/test-wrong + Çözüm Önerisi
2. `TestName2`: Kök neden + kanıt + code-wrong/test-wrong + Çözüm Önerisi
[Karmaşık vakada: "Detaylı RCA: docs/tasks/sprint-XX/TASK-{ID}-rca.md"]

[Eğer eksik coverage tespit ettiysen:]
### 🟡 Missing Coverage Areas
- [Örn: "Login empty state için test yazılmamış"]
```

**Sonuç Mesajı**:
"Testler tamamlandı. Tüm testler geçtiyse `/review-code` ile ilerleyebilirsiniz. Eğer hata varsa koda dönüp düzeltin."
