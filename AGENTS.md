# AGENTS.md

Bu dosya, [AGENTS.md standardını](https://agents.md) destekleyen AI kodlama
araçları (OpenAI Codex, GitHub Copilot, Cursor, Windsurf, Amp, Devin, Aider,
Zed, Jules, JetBrains Junie, Claude Code ve daha fazlası) tarafından otomatik
okunan proje bağlam dosyasıdır.

Claude Code için `CLAUDE.md`, Gemini CLI / Google Antigravity için `GEMINI.md`
bu dosyaya **sembolik link** olarak sağlanmıştır — hangi aracı kullanıyorsanız
kullanın, aynı içeriği okur; üç ayrı dosyayı senkron tutmanız gerekmez.

> Bu repo bir **şablondur**. Kendi projenizde bu dosyanın içeriğini kendi
> mimarinize/standartlarınıza göre doldurun. Aşağıdaki yapı, `workflows/`
> altındaki 12 workflow'un okuduğu/yazdığı konvansiyonu tanımlar — detay için
> repo kökündeki `README.md`'ye bakın.

## Proje Kuralları

- **Mimari**: bkz. `docs/architecture.md`
- **Kodlama standartları**: bkz. `docs/coding-standards.md`
- **Code review checklist**: bkz. `docs/review-checklist.md`

## Task / Sprint Yönetimi

- **Backlog**: `docs/backlog.md`
- **Güncel sprint panosu**: `docs/progress.md`
- **Task dosyaları**: `docs/tasks/sprint-XX/TASK-{ID}-*.md`
- **Sürüm kaydı**: `docs/releases.md`

## Workflow'lar

Bu repo, `workflows/` klasöründe Google Antigravity formatında (plain
Markdown, `/komut-adı` ile çağrılır) 12 rol tabanlı workflow içerir:
Business Analyst, Software Architect, Senior Developer, Code Review
Sentinel, QA Engineer, DevOps/Release Manager, PR Author, Project Manager,
Scrum Master, Release Notes Writer, Release Manager, UI Designer.

Antigravity dışında bir araç kullanıyorsanız (örn. Claude Code custom
commands, Cursor rules) workflow dosyalarının markdown içeriğini o aracın
kendi klasör konvansiyonuna kopyalayabilirsiniz — içerik taşınabilir plain
Markdown'dır, formata özgü bir sözdizimi kullanmaz.
