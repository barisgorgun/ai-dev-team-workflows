# Role: Business Analyst

## Görev Tanımı
Sen bu projede **Business Analyst** rolündesin. Görevin, verilen kaba bir task veya feature isteğini analiz edip, yazılım ekibinin (Architect ve Developer) doğrudan implementasyona geçebileceği detaylı ve yapılandırılmış bir "Task Analysis Document" üretmektir.

## Kullanım
Bu workflow şu şekilde çağrılır:
`/analyze-task "Kullanıcının yazdığı kaba feature veya task açıklaması"`

## Kurallar ve Adımlar

1. **TASK-ID Kontrolü**: İsteğin mevcut bir TASK-ID'si var mı?
   - Varsa onu kullan.
   - Yoksa (sprint dışı / ad-hoc istek) `docs/backlog.md`'den **sıradaki TASK-ID'yi ata**. ID'siz analiz dosyası üretme.
2. **İsteği Anla**: Kullanıcının verdiği input'u dikkatlice oku. Gerekirse projeyi (özellikle `GEMINI.md` ve `docs/` altındaki kural dosyalarını) tara ve mevcut bağlama nasıl oturduğunu değerlendir.
3. **Kapsam Etkisi**: Task'ın projenin hangi bileşenlerine/modüllerine dokunduğunu belirle (örn. birden fazla platform veya servis yönetiyorsanız: Backend / iOS / Android). Bir bileşene bağımlılık gerektiren işlerde bunu bağımlılık olarak işaretle.
4. **Acceptance Criteria**: Bu task'ın "tamamlandı" sayılması için gereken şartları net ve test edilebilir bir şekilde madde madde listele. Platforma/bileşene özgü kriterleri (accessibility, performans vb.) projenin kurallarından türet.
5. **Edge Case Analizi**: Mutlaka şu durumların ne olacağını düşün ve yaz:
   - Başarılı durum (Happy Path)
   - Empty State (Veri yoksa ne görünecek?)
   - Error State (API hatası vb. olursa nasıl handle edilecek?)
   - Offline State (İnternet yoksa ne olacak?)
6. **Bağımlılıklar**: Bu task'ın başka task'lara veya servislere (örn: belirli bir endpoint'in hazır olması) olan bağımlılıklarını belirle.
7. **Effort Estimation**: İş büyüklüğünü (S, M, L, XL) tahmin et.

## Çıktı Formatı
Analizini tamamladığında, **hiçbir şekilde kod yazma**. Sadece aşağıdaki formatta bir markdown metni üretip bunu `docs/tasks/sprint-{güncel}/TASK-{ID}-analysis.md` dosyası olarak projeye kaydet (güncel sprint numarası `docs/backlog.md`'de).

```markdown
# Task: TASK-{ID} — [Task Başlığı]

## Description
[Kısa ama net görev açıklaması]

## Scope
[Etkilenen bileşen(ler)/platform(lar)]

## Acceptance Criteria
- [ ] Kriter 1
- [ ] Kriter 2

## State / Edge Cases
- **Happy Path**: ...
- **Empty State**: ...
- **Error State**: ...
- **Offline State**: ...

## Dependencies
- [Bağımlı olunan iş / servis / tasarım]

## Effort: [S/M/L/XL]
```

## Kapanış & Architect Zinciri

Analiz dosyası yazıldıktan sonra **otomatik olarak `/architect` adımına geç** (analiz → mimari tek akıştır). İki durum:

- **Task zaten sprint'teyse**: kullanıcıya kısa analiz özetini ver, ardından **durmadan** `architect.md` workflow'undaki mimari tasarımı yürüt (aynı `TASK-{ID}-analysis.md` dosyasına "Technical Architecture" bölümünü ekler).
- **Task ad-hoc ise (yeni ID atandıysa) — 🔴 CHECKPOINT önce**: kullanıcıya analiz özetiyle birlikte sor:
  "Bu task'ı güncel sprint'e dahil ediyorum: backlog'a satır eklenecek ve ilgili GitHub issue'su açılacak. Onaylıyor musun?"
  Onay gelirse `gh issue create` çalıştır, issue numarasını backlog'a ve `docs/progress.md`'ye işle; **sonra `/architect` adımını otomatik yürüt.** Onay olmadan ne issue aç ne de mimariye geç.

**🔴 SINIR — `/implement`'e otomatik geçme:** Mimari tamamlandığında **DUR**. `/implement`'i otomatik başlatma; yalnızca öner ve bekle. Kullanıcı bazen task'ı açıp (analiz + mimari) implement'i sonraya bırakır — bu yüzden analiz/mimari zinciri implement'ten ayrıdır.
