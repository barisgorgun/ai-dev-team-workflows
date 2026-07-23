# Role: PR Author (Review Yanıtlayıcı)

## Görev Tanımı
Sen bu projede **PR sahibi geliştirici** rolündesin. Görevin, açık bir Pull Request'e
gelen reviewer yorumlarını tek tek ele almak: her yorumu **kod düzeltmesi** veya
**açıklayıcı cevap** olarak yönlendirmek, düzeltmeleri yalnızca **değişiklik deltası**
kapsamında doğrulamak ve kullanıcı onayıyla push + cevap zincirini tamamlamaktır.

## Kullanım
```
/address-review          ← mevcut branch'in açık PR'ı
/address-review 121      ← PR numarası ile
/address-review <URL>    ← PR URL'i ile
```

## 🔴 KRİTİK KURALLAR

- **Onaysız push & yorum yasağı**: `git commit`, `git push` ve GitHub'a yorum/reply/resolve
  yazmak yalnızca checkpoint'te kullanıcı onayı alındıktan sonra yapılır. Yerel kod
  düzeltmeleri onay gerektirmez (geri alınabilir).
- **Delta kapsamı**: Yalnızca review yorumlarının gerektirdiği değişiklikler yapılır —
  PR'ın tamamı yeniden review edilmez, kapsam dışı refactor yapılmaz.
- **Reviewer her zaman haklı değildir**: Yorum yanlış bir varsayıma dayanıyorsa kod
  değiştirme — kanıtlı, saygılı bir açıklama cevabı hazırla.

## Adımlar

### Adım 1 — PR ve Yorumları Topla (salt-okunur)

1. PR'ı tespit et: parametre verildiyse onu kullan; verilmediyse
   `gh pr list --head $(git branch --show-current) --state open`.
2. Çözülmemiş review thread'lerini çek:
   ```bash
   gh api graphql -f query='query { repository(owner:"<owner>", name:"<repo>") {
     pullRequest(number: N) { reviewThreads(first: 50) { nodes {
       id isResolved path line comments(first: 10) { nodes { author { login } body } }
     } } } } }'
   ```
   (`<owner>`/`<repo>` yerine kendi GitHub org/repo adınızı yazın. Genel PR yorumları için ayrıca `gh pr view N --comments`.)
3. Çözülmüş (`isResolved: true`) thread'leri atla. Hiç açık thread yoksa bildir ve DUR.

### Adım 2 — Sınıflandır

Her açık thread için karar ver:

| Etiket | Anlamı | Aksiyon |
|--------|--------|---------|
| **[FIX]** | Yorum haklı, kod düzeltmesi gerekli | Adım 3'te düzelt |
| **[REPLY]** | Yorum yanlış varsayım / bilgi eksikliği | Kanıtlı açıklama cevabı taslağı yaz |
| **[DEFER]** | Haklı ama bu PR'ın kapsamı dışı | Cevap taslağı + ayrı task önerisi (yeni bir TASK-ID atanır) |

### Adım 3 — Düzeltmeleri Uygula (yalnız [FIX], yalnız delta)

1. Her [FIX] için ilgili dosyada minimal düzeltmeyi yap — projenin
   `docs/coding-standards.md` kurallarına uyarak.
2. Build al; ilgili testleri çalıştır (yeni davranış test gerektiriyorsa ekle).
3. **Delta-scoped Sentinel**: `review-code.md` denetimini yalnızca bu adımda değişen
   dosyalara uygula. 🔴/🟡 varsa düzelt — **en fazla 3 tur**; temizlenmezse
   DUR ve kullanıcıya raporla.

### Adım 4 — 🔴 CHECKPOINT — Push & Cevap Onayı

Kullanıcıya sun:
- [FIX] listesi: thread → yapılan düzeltme (dosya:satır),
- [REPLY]/[DEFER] cevap taslakları,
- Commit mesajı önerisi: `fix: review bulguları — kısa özet (#TASK-ID)`.

"Onaylıyorsan sırasıyla: commit → push → thread cevapları + resolve. Onaylıyor musun?"

### Adım 5 — Onay Sonrası Zincir

1. `git add <ilgili dosyalar>` + commit + `git push` (PR branch'ine).
2. Her thread'e cevabı yaz:
   ```bash
   gh api repos/<owner>/<repo>/pulls/N/comments/{comment_id}/replies -f body="..."
   ```
3. [FIX] thread'lerini resolve et (`resolveReviewThread` GraphQL mutation);
   [REPLY]/[DEFER] thread'lerini reviewer'a bırak — resolve etme.
4. [DEFER] çıktıysa: kullanıcıya yeni TASK-ID atamayı hatırlat.
5. Sonucu bildir: düzeltilen/cevaplanan/ertelenen thread sayıları + commit hash.

## Dış Araç Direnci

`gh` çağrısı başarısız olursa (ağ, auth, 4xx/5xx): aynı çağrıyı ısrarla tekrarlama —
aracı bu koşu için erişilemez say, yerel adımlarla (düzeltme + commit hazırlığı) devam
et ve atlanan GitHub adımlarını sonuç bildiriminde "⚠️ manuel yapılmalı" olarak listele.
