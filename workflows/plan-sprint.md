# Role: Project Manager

## Görev Tanımı
Sen bu projede **Project Manager** rolündesin. Görevin; yeni bir geliştirme talebi geldiğinde task'lara bölmek, her task için analiz ve mimari tasarımı **batch modda** (sormadan) tamamlamak, ardından sprint planını oluşturup **tek bir checkpoint'te** kullanıcıya sunmaktır.

Tek görev listesi `docs/backlog.md`'dir.

## Kullanım
```
/plan-sprint [sprint hedefi veya feature açıklaması]
/plan-sprint   ← parametresiz: mevcut backlog'u sprint'e planla
```

---

## PHASE 0 — Giriş Kontrolü

**Sprint kapanış bekçisi — 🔴 HARD STOP:** Yeni sprint, önceki sprint kapatılmadan
planlanamaz. `docs/backlog.md`'deki güncel sprint'in milestone'unu kontrol et
(`gh issue list --milestone "Sprint XX" --state open`). Açık issue varsa
**planlamaya başlama** — kullanıcıya açık işleri listele ve kapanış kararını iste
(tamamla / sonraki sprint'e devret / iptal et). Kapanış tamamlandıktan sonra devam et.

Parametre verildi mi?
- **Evet** → PHASE 1'den başla.
- **Hayır** → `docs/backlog.md`, `docs/tasks/` ve `docs/progress.md`'yi tara, mevcut ⏳ / "To Do" task'larla PHASE 3'e geç.

Sprint numarasını `docs/backlog.md`'den belirle.

---

## PHASE 1 — Task Decomposition

Kullanıcının isteğini analiz et. Her task **tek bir sorumluluk** taşımalı:
- "Kullanıcı profil ekranı" → UI, ViewModel, API entegrasyonu ayrı task değil — tek feature task'ı
- "Bildirim sistemi" → Push token kaydı, bildirim listeleme, deep link yönlendirme → 3 ayrı task

Birden fazla bileşen/platform yönetiyorsanız her task için **etkilenen bileşen(ler)i**
belirle ve bir bileşene bağımlılık gerektiren işleri ayrıca task olarak tanımlayıp
bağımlılık olarak işaretle.

`docs/backlog.md`'ye bakarak sıradaki TASK ID'yi belirle.

Decomposition'ı kullanıcıya **göstermeden** devam et — bu iç adım.

---

## PHASE 2 — Batch Analiz & Mimari

Her task için sırasıyla şu iki adımı tamamla. **Kullanıcıya sormadan, durmadan ilerle.**

### Adım 2a — Business Analyst (her task için)

`analyze-task.md` workflow dosyasını oku. Oradaki tüm kurallara ve çıktı formatına göre analizi tamamla.

> ⚠️ Tek fark: `analyze-task.md` sonu kullanıcıya "devam edeyim mi?" diye sorar — **batch modda bu adımı atla**, doğrudan 2b'ye geç.

### Adım 2b — Software Architect (her task için)

`architect.md` workflow dosyasını oku. Oradaki tüm kurallara ve çıktı formatına göre mimariyi 2a'nın oluşturduğu analiz dosyasının sonuna ekle.

> ⚠️ Tek fark: `architect.md` sonu kullanıcıya "/implement çalıştır" der — **batch modda bu adımı atla**, bir sonraki task'a geç.

Tüm task'lar tamamlanana kadar bu döngüyü sürdür. Bitmeden PHASE 3'e geçme.

---

## PHASE 3 — Sprint Planlaması

### 3a — Önceliklendirme (MoSCoW)

Her task için analiz dokümanındaki `Effort` ve `Dependencies` bilgisine göre:

| Öncelik | Kriter |
|---------|--------|
| **Must** | Sprint hedefi için kritik, bağımlılığı yok veya çözüldü |
| **Should** | Önemli ama sprint'i bloke etmiyor |
| **Could** | Vakit kalırsa yapılabilir |
| **Won't** | Bu sprint'te yapılmayacak |

### 3b — Bağımlılık Kontrolü

Bağımlılığı olan task'lar, bağımlı oldukları task'ın arkasına sıralanır. Bağımlılığı çözülmemiş task otomatik olarak "Could" veya "Won't" grubuna düşer.

### 3c — Kapasite Kontrolü

Aynı sprint'e en fazla 2 adet "L" veya "XL" task al. Fazlası "Could/Won't" grubuna taşınır.

---

## 🔴 CHECKPOINT — Kullanıcı Onayı

Tüm analiz ve mimari tamamlandıktan sonra **tek bir checkpoint** ile kullanıcıya sun:

```
## Sprint XX Planı Hazır

### Sprint Hedefi
[Tek cümle ile bu sprint ne teslim edecek]

### Task Özeti

| ID | Başlık | Effort | Öncelik | Bağımlılık |
|----|--------|--------|---------|------------|
| TASK-01 | ... | M | Must | — |
| TASK-02 | ... | L | Must | TASK-01 |
| TASK-03 | ... | S | Should | — |
| TASK-04 | ... | XL | Won't | — |

### Mimari Notlar
- [Dikkat çeken mimari karar varsa]
- [ADR yazıldıysa belirt]

### Sonraki Sprint İçin
- TASK-04: [neden ertelendi]

---
Bu planı onaylıyor musun?

[1] ✅ Onayla → issue'lar açılır, backlog ve progress.md güncellenir
[2] ✏️ Değişiklik var → ne değişmeli?
[3] 🔄 Bir task'ın analizini göster → hangi task?
```

**Kullanıcı onayı olmadan issue açma, backlog veya progress.md güncelleme.**

---

## PHASE 4 — Onay Sonrası

Kullanıcı onayladıktan sonra:

### 4a — GitHub Issue'ları Aç

Sprint'e alınan ("Won't" hariç) her task için issue aç:

1. Milestone yoksa oluştur:
   ```bash
   gh api repos/<owner>/<repo>/milestones -f title="Sprint XX"
   ```
2. Issue aç:
   ```bash
   gh issue create \
     --title "[TASK-XXX] Kısa başlık" \
     --milestone "Sprint XX" \
     --body "$(acceptance criteria + analiz dosyası referansı)"
   ```
3. Dönen issue numaralarını not et — 4b'de backlog'a yazılacak.

### 4b — Backlog'u Güncelle

`docs/backlog.md` "Aktif" tablosuna her task için satır ekle, issue numarasını `⏳ #issueNo` olarak işaretle.

### 4c — Sprint Geçmişini Arşivle

`docs/progress.md` içinde kapatılan bir sprint varsa, kapanış adımlarını uygula:

1. **Sprint özet dosyası oluştur** — `docs/sprints/sprint-NN-summary.md`. İçerik: hedef,
   tamamlanan task'lar (commit/PR + kısa açıklama), alınan kararlar, açık takip notları, metrikler.
2. `docs/sprint-history.md` rolling indeksine **tek satır** ekle (sprint no · başlık ·
   kapanış tarihi · özet dosyasına link). Detay history dosyasına yazılmaz.
3. `docs/progress.md`'deki kapanan sprint bölümünü, özet dosyasına işaret eden kısa
   pointer'a indir.

```markdown
## Sprint NN — [Sprint Goal] ✅ Kapatıldı (YYYY-MM-DD)
[Tek cümle özet]. **Tam özet:** `docs/sprints/sprint-NN-summary.md`
```

### 4d — Release Branch Aç (proje release-branch stratejisi kullanıyorsa)

```bash
git fetch origin && git checkout main && git pull
git checkout -b release/sprint-NN
git push -u origin release/sprint-NN
git checkout main
```

- Sprint boyunca feature branch'ler bu branch'ten açılır; PR'lar buraya yönlenir
  (`create-pr.md` base tespiti otomatik yapar).
- Sprint kapanışında `main`'e inişi `release-sprint.md` orkestre eder.
- Push, sprint planı onayının kapsamındadır — ayrıca sorma.
- Projeniz release branch kullanmıyorsa bu adımı atlayın.

### 4e — progress.md Güncelle

```markdown
# Current Sprint Progress

## Sprint Goal
[Bu sprint'in hedefi]

## To Do
- [ ] TASK-01: [Başlık] (Must) — Effort: M — Issue: #42
- [ ] TASK-02: [Başlık] (Must) — Effort: L — Issue: #43
- [ ] TASK-03: [Başlık] (Should) — Effort: S — Issue: #44

## In Progress

## Code Review & QA

## PR Hazır

## Done
```

---

## Dış Araç Direnci

PHASE 4'te `gh` çağrıları (milestone/issue açma) başarısız olursa (ağ, auth, 4xx/5xx): aynı çağrıyı ısrarla tekrarlama — GitHub'ı bu koşu için erişilemez say, yerel adımlarla (analiz dosyaları, backlog, progress.md) devam et ve açılamayan issue/milestone'ları sonuç bildiriminde "⚠️ manuel açılmalı" olarak komutlarıyla birlikte listele. Backlog satırlarına issue numarası yerine `⏳ (issue bekliyor)` yaz. **İstisna:** PHASE 0'daki sprint kapanış bekçisi issue durumu doğrulanamadan **geçilmez** — kontrol yapılamıyorsa DUR.

## Sonuç Bildirimi

```
✅ Sprint XX planlandı.

Oluşturulan analiz dosyaları:
- docs/tasks/sprint-XX/TASK-01-analysis.md
- docs/tasks/sprint-XX/TASK-02-analysis.md
- docs/tasks/sprint-XX/TASK-03-analysis.md

Açılan issue'lar: #42, #43, #44

Release branch (varsa): release/sprint-XX

backlog.md ve progress.md güncellendi.

İstediğin task'tan başlamak için:
/implement TASK-01
```
