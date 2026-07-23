# AI Dev Team Workflows (Google Antigravity)

12 workflow dosyası, tek bir AI agent'ı (Antigravity / Gemini) sırayla farklı yazılım
ekibi rollerine büründürerek uçtan uca bir "task → analiz → mimari → kod → review →
PR" hattı çalıştırır: Business Analyst, Software Architect, Senior Developer, Code
Review Sentinel, QA Engineer, DevOps/Release Manager, Project Manager, Scrum Master,
PR Author, Release Notes Writer, UI Designer.

## Kurulum

1. Bu repoyu klonlayın (`git clone git@github.com:barisgorgun/ai-dev-team-workflows.git`) ve `workflows/` klasöründeki 12 `.md` dosyasını kopyalayın:
   - **Global** (tüm workspace'lerde kullanılabilir): `~/.gemini/antigravity/global_workflows/`
   - **Workspace-özel** (yalnızca tek bir proje): `<proje-kökü>/.agent/workflows/`
2. Antigravity'yi açın (zaten açıksa workflow listesini yenilemesi için yeniden başlatmanız gerekebilir).
3. Agent chat panelinde `/architect`, `/implement`, `/plan-sprint` gibi komutları yazarak çağırın.

## Bu şablonun varsaydığı proje yapısı

Workflow'lar aşağıdaki dosya/klasörlere okur-yazar. Hiçbiri zorunlu değil — ilk
çalıştırmada kendileri oluşturulabilir — ama boş bir iskelet hazırlamak akışı hızlandırır:

```
GEMINI.md                          # Proje kuralları (veya AGENTS.md / README.md)
docs/
├── architecture.md                # Katman yapısı, dosya organizasyonu kuralları
├── coding-standards.md            # Kod yazım standartları
├── review-checklist.md            # Code review kontrol listesi
├── backlog.md                     # Task listesi, sıradaki TASK-ID kaynağı
├── progress.md                    # Güncel sprint panosu (To Do / In Progress / ...)
├── releases.md                    # Sürüm kaydı
├── decisions/                     # Mimari kararlar (ADR'ler, opsiyonel)
├── sprints/sprint-NN-summary.md   # Kapanan sprint özetleri
├── sprint-history.md              # Sprint kapanış indeksi
└── tasks/sprint-XX/
    ├── TASK-{ID}-analysis.md      # /analyze-task çıktısı + /architect'in eklediği bölüm
    ├── TASK-{ID}-result.md        # /implement teslimat raporu
    ├── TASK-{ID}-review.md        # /review-code raporu
    └── TASK-{ID}-rca.md           # /run-tests kök neden analizi (gerektiğinde)
```

Bu dosya adları/yolları **örnektir** — projenizde farklı bir konvansiyon varsa
`workflows/` içindeki dosyaların yol referanslarını bulup değiştirin (`docs/` geçen satırlar).

## Akış

```
/plan-sprint (veya /analyze-task) → /architect → /implement
                                                     └─ otomatik: /review-code → /create-pr
```

Bağımsız çağrılabilenler: `/daily-standup`, `/run-tests`, `/review-code`, `/create-pr`,
`/address-review`, `/release-notes`, `/release-sprint`, `/design-screen`.

## Repo Yapısı

```
ai-dev-team-workflows/
├── README.md
├── LICENSE
└── workflows/
    ├── analyze-task.md      # Business Analyst
    ├── architect.md         # Software Architect
    ├── implement.md         # Senior Developer
    ├── review-code.md       # Code Review Sentinel
    ├── run-tests.md         # QA Engineer
    ├── create-pr.md         # DevOps / Release Manager
    ├── address-review.md    # PR Author
    ├── plan-sprint.md       # Project Manager
    ├── daily-standup.md     # Scrum Master
    ├── release-notes.md     # Release Notes Writer
    ├── release-sprint.md    # Release Manager (store submission)
    └── design-screen.md     # UI Designer (prompt engineer)
```

## Özelleştirme notları

- **Tek repo varsayılır.** Backend/mobil gibi birden fazla repo yönetiyorsanız
  `docs/...` yol referanslarını ve `gh` komutlarındaki `<owner>/<repo>` yer
  tutucularını kendi yapınıza göre düzenleyin; gerekirse çoklu-repo döngülerini
  (`for repo in ...`) geri ekleyin.
- **Mobil örnekler.** `design-screen.md`, `release-sprint.md`, `implement.md` ve
  `review-code.md` içindeki iOS/Android, SwiftUI/Compose, App Store/Play Store
  örnekleri mobil app geliştirme senaryosundan geliyor — web/backend projelerinde
  ilgili örnekleri kendi stack'inize göre değiştirin, workflow'un adım mantığı aynı kalır.
- **ADR/karar kayıtları.** Kurallar kendi içinde açıklanmış durumda (dışarıdan bir
  "ADR-XXX" numarasına referans vermiyor). Kendi projenizde karar kayıtları
  tutuyorsanız `docs/decisions/`'a referans eklemek isteyebilirsiniz.
- **Marka/ton.** `release-notes.md` "What's New" metinlerinin tonunu placeholder
  olarak bırakır — kendi ürününüzün marka sesini siz tanımlarsınız.
