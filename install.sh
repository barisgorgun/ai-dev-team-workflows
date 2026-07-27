#!/usr/bin/env bash
# AI Dev Team Workflows — interactive installer.
# Asks which AI tool you use and copies workflow/context files to the right place.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOWS_DIR="$SCRIPT_DIR/workflows"
AGENTS_DIR="$SCRIPT_DIR/agents"
CONTEXT_FILES=(AGENTS.md CLAUDE.md GEMINI.md)

copy_file() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    read -rp "  $dest zaten var. Üzerine yazılsın mı? [y/N]: " overwrite
    case "$overwrite" in
      y|Y) rm -f "$dest" ;;
      *) echo "  Atlandı: $dest"; return 0 ;;
    esac
  fi
  cp -P "$src" "$dest"
  echo "  Kopyalandı: $dest"
}

# Writes docs/security-profile.md — the security-reviewer agent's Faz 0 tuning file —
# pre-filled with platform-appropriate scan-focus bullets. TBD sections are left for
# the operator to fill (no incident history or key-storage details can be auto-detected).
write_security_profile() {
  local platform_name="$1" focus_block="$2" dest="$3"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    read -rp "  $dest zaten var. Üzerine yazılsın mı? [y/N]: " overwrite
    case "$overwrite" in
      y|Y) ;;
      *) echo "  Atlandı: $dest"; return 0 ;;
    esac
  fi
  cat > "$dest" <<EOF
# Security Profile

> \`security-reviewer\` agent'ının Faz 0'da okuduğu proje-özel güvenlik dosyası.
> Platform: $platform_name — bu şablon \`ai-dev-team-workflows\` install.sh tarafından
> oluşturuldu, kendi projenize göre doldurun.

## Bilinen Riskler / Geçmiş Olaylar

- (TBD — bilinen bir secret sızıntısı, güvenlik olayı vb. varsa buraya ekleyin)

## API Key / Credential Yönetimi

- (TBD — key'ler nerede saklanıyor: env var, secret manager, Remote Config vb.)
- Kaynak kodda literal secret **yasak** — bu kural her platformda geçerli.

## Tarama Odağı (Scan Focus)

$focus_block

## İstisnalar (Exclusions)

- \`*.example\` — placeholder, secret değil
- (TBD — mock/test fixture, büyük statik veri dosyaları vb.)
EOF
  echo "  Oluşturuldu: $dest"
}

echo "== AI Dev Team Workflows — Kurulum =="
echo
echo "Hangi AI aracını kullanıyorsunuz?"
echo "  1) Google Antigravity (Gemini)"
echo "  2) Claude Code"
echo "  3) Diğer (Cursor, Windsurf, Codex CLI, Copilot, Aider, Zed, Amp, Devin, Jules, JetBrains Junie, ...)"
read -rp "Seçim [1-3]: " tool_choice

workflow_supported=true
case "$tool_choice" in
  1) tool_name="Google Antigravity (Gemini)" ;;
  2) tool_name="Claude Code" ;;
  3) tool_name="Diğer (AGENTS.md uyumlu araç)"; workflow_supported=false ;;
  *) echo "Geçersiz seçim." >&2; exit 1 ;;
esac
echo
echo "Seçilen araç: $tool_name"

scope_choice=""
project_dir=""

if [ "$workflow_supported" = true ]; then
  echo
  echo "Workflow'ları (/architect, /implement, ...) nereye kurmak istiyorsunuz?"
  echo "  1) Global (tüm projelerde kullanılabilir)"
  echo "  2) Yalnızca belirli bir proje"
  read -rp "Seçim [1-2]: " scope_choice

  if [ "$scope_choice" = "2" ]; then
    read -rp "Proje klasörünün yolu [$(pwd)]: " project_dir
    project_dir="${project_dir:-$(pwd)}"
  fi

  case "$tool_choice-$scope_choice" in
    1-1) workflow_dest="$HOME/.gemini/antigravity/global_workflows" ;;
    1-2) workflow_dest="$project_dir/.agent/workflows" ;;
    2-1) workflow_dest="$HOME/.claude/commands" ;;
    2-2) workflow_dest="$project_dir/.claude/commands" ;;
    *) echo "Geçersiz seçim." >&2; exit 1 ;;
  esac

  if [ -n "$project_dir" ] && [ ! -d "$project_dir" ]; then
    echo "Klasör bulunamadı: $project_dir" >&2
    exit 1
  fi

  mkdir -p "$workflow_dest"
  echo
  echo "Workflow'lar kopyalanıyor -> $workflow_dest"
  for f in "$WORKFLOWS_DIR"/*.md; do
    copy_file "$f" "$workflow_dest/$(basename "$f")"
  done

  # Agents (orchestrator, architect, code-reviewer, test-engineer, security-reviewer)
  # are a Claude Code-specific layer — subagent delegation isn't part of the
  # portable AGENTS.md/workflow model other tools use.
  if [ "$tool_choice" = "2" ]; then
    case "$scope_choice" in
      1) agents_dest="$HOME/.claude/agents" ;;
      2) agents_dest="$project_dir/.claude/agents" ;;
    esac
    mkdir -p "$agents_dest"
    echo
    echo "Agent'lar kopyalanıyor -> $agents_dest"
    for f in "$AGENTS_DIR"/*.md; do
      copy_file "$f" "$agents_dest/$(basename "$f")"
    done
  fi
else
  echo
  echo "Not: \"$tool_name\" için otomatik workflow kurulumu desteklenmiyor —"
  echo "bu araçların komut/kural formatı Antigravity ile birebir uyumlu değil."
  echo "workflows/ klasöründeki dosyaları referans alıp kendi aracınızın"
  echo "konvansiyonuna elle uyarlayabilirsiniz (bkz. README > Desteklenen AI Araçları)."
fi

# Context files (AGENTS.md + CLAUDE.md/GEMINI.md symlinks) always live in a project root.
install_context="y"
if [ -z "$project_dir" ]; then
  echo
  read -rp "Context dosyalarını (AGENTS.md ve eşdeğerleri) bir projeye de kurmak ister misiniz? [Y/n]: " install_context
  install_context="${install_context:-y}"
  if [ "$install_context" = "y" ] || [ "$install_context" = "Y" ]; then
    read -rp "Proje klasörünün yolu [$(pwd)]: " project_dir
    project_dir="${project_dir:-$(pwd)}"
    if [ ! -d "$project_dir" ]; then
      echo "Klasör bulunamadı: $project_dir" >&2
      exit 1
    fi
  fi
fi

if [ -n "$project_dir" ] && { [ "$install_context" = "y" ] || [ "$install_context" = "Y" ]; }; then
  echo
  echo "Context dosyaları kopyalanıyor -> $project_dir"
  for f in "${CONTEXT_FILES[@]}"; do
    copy_file "$SCRIPT_DIR/$f" "$project_dir/$f"
  done
fi

# docs/security-profile.md is read by the security-reviewer agent (Claude Code-only
# layer, see agents/) — only offered when that agent was actually installed and a
# project root is known.
if [ "$tool_choice" = "2" ] && [ -n "$project_dir" ]; then
  echo
  echo "Bu proje hangi platform/stack için? (docs/security-profile.md bu seçime göre oluşturulur)"
  echo "  1) iOS"
  echo "  2) Android"
  echo "  3) Web (Frontend)"
  echo "  4) Backend / API"
  echo "  5) Atla (security-profile.md oluşturulmasın)"
  read -rp "Seçim [1-5]: " platform_choice

  platform_name=""
  focus_block=""
  case "$platform_choice" in
    1) platform_name="iOS"
       focus_block=$'- `*.swift`, `Info.plist`, `*.xcconfig`, `*.json`\n- ATS (`NSAllowsArbitraryLoads`), Keychain vs UserDefaults, Privacy Manifest\n- SPM `Package.resolved` bağımlılık kontrolü' ;;
    2) platform_name="Android"
       focus_block=$'- `*.kt`, `AndroidManifest.xml`, `*.gradle(.kts)`, `*.properties`\n- Network Security Config, Keystore/EncryptedSharedPreferences vs SharedPreferences, ProGuard/R8\n- `libs.versions.toml`/`build.gradle` bağımlılık kontrolü' ;;
    3) platform_name="Web (Frontend)"
       focus_block=$'- `*.ts`/`*.tsx`/`*.js`/`*.jsx`, `.env*`, `package.json`\n- XSS (`dangerouslySetInnerHTML`/`innerHTML`), CSRF token, CSP header, secure cookie flag\'leri, CORS\n- `package-lock.json`/`yarn.lock` bağımlılık kontrolü' ;;
    4) platform_name="Backend / API"
       focus_block=$'- Kaynak kodu, `.env*`, config dosyaları\n- Parametreli sorgular, parola hashleme (bcrypt/argon2), session/rate limiting, input validation\n- Lock dosyası bağımlılık kontrolü' ;;
    5) : ;;
    *) echo "Geçersiz seçim, security-profile.md atlandı." >&2 ;;
  esac

  if [ -n "$platform_name" ]; then
    mkdir -p "$project_dir/docs"
    write_security_profile "$platform_name" "$focus_block" "$project_dir/docs/security-profile.md"
  fi
fi

echo
echo "Kurulum tamamlandı."
if [ -n "$project_dir" ]; then
  echo "-> $project_dir/AGENTS.md dosyasını açıp kendi projenize göre doldurun."
fi
