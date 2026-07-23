#!/usr/bin/env bash
# AI Dev Team Workflows — interactive installer.
# Asks which AI tool you use and copies workflow/context files to the right place.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOWS_DIR="$SCRIPT_DIR/workflows"
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

echo
echo "Kurulum tamamlandı."
if [ -n "$project_dir" ]; then
  echo "-> $project_dir/AGENTS.md dosyasını açıp kendi projenize göre doldurun."
fi
