PLUGIN_ROOT  := $(shell pwd)
CORNER_DIR   := $(HOME)/claude-corner
SETTINGS     := $(HOME)/.claude/settings.json
HOOK_CMD     := $(PLUGIN_ROOT)/hooks/corner-trigger.sh
GLOBAL_CMDS  := $(HOME)/.claude/commands/corner

.PHONY: help install uninstall test status

help:
	@echo ""
	@echo "claude-corner — comandos disponíveis:"
	@echo ""
	@echo "  make install    disponibiliza o plugin (comandos globais + hook executável)"
	@echo "  make uninstall  remove tudo que o install criou"
	@echo "  make test       testa o hook e dispara uma sessão curta"
	@echo "  make status     mostra o estado atual da instalação"
	@echo ""
	@echo "  Após 'make install', abra o Claude Code e rode /corner:setup para ativar."
	@echo ""

# ─── install ──────────────────────────────────────────────────────────────────

install:
	@echo "🏠 Instalando corner..."

	@# Tornar hook executável
	chmod +x $(HOOK_CMD)
	@echo "  ✓ Hook pronto: $(HOOK_CMD)"

	@# Copiar comandos para ~/.claude/commands/corner/ (disponíveis globalmente)
	mkdir -p $(GLOBAL_CMDS)
	cp .claude/commands/*.md $(GLOBAL_CMDS)/
	@echo "  ✓ Comandos instalados em ~/.claude/commands/corner/"

	@echo ""
	@echo "  Pronto! Abra o Claude Code em qualquer pasta e rode /corner:setup para ativar."

# ─── uninstall ────────────────────────────────────────────────────────────────

uninstall:
	@echo "🗑️  Removendo corner..."

	@# Remover comandos globais
	rm -rf $(GLOBAL_CMDS)
	@echo "  ✓ Comandos removidos de ~/.claude/commands/corner/"

	@# Remover hook do settings.json (registrado pelo /corner:setup)
	@python3 -c "\
import json; \
path = '$(SETTINGS)'; \
s = json.load(open(path)); \
entries = s.get('hooks', {}).get('UserPromptSubmit', []); \
[entries.remove(e) for e in entries[:] if '$(PLUGIN_ROOT)' in str(e)]; \
open(path, 'w').write(json.dumps(s, indent=2))" 2>/dev/null \
		&& echo "  ✓ Hook removido de ~/.claude/settings.json" \
		|| echo "  — Hook não encontrado (ok, /corner:setup talvez não tenha sido rodado)"

	@# Remover arquivos de estado
	rm -f $(HOME)/.claude/.corner-count $(HOME)/.claude/.corner-lock $(HOME)/.claude/.corner-done
	@echo "  ✓ Arquivos de estado removidos"

	@# Remover settings.json de confinamento
	rm -f $(CORNER_DIR)/.claude/settings.json
	@rmdir $(CORNER_DIR)/.claude 2>/dev/null || true
	@echo "  ✓ settings.json de confinamento removido"

	@echo ""
	@echo "  Desinstalado. ~/claude-corner/ foi mantida (seus arquivos estão lá)."
	@echo "  Para apagar a pasta também: rm -rf ~/claude-corner/"

# ─── test ─────────────────────────────────────────────────────────────────────

test:
	@echo "🧪 Testando hook..."
	@CLAUDE_PLUGIN_ROOT=$(PLUGIN_ROOT) bash $(HOOK_CMD) && echo "  ✓ Hook ok" || echo "  ✗ Hook falhou"

	@echo ""
	@echo "🧪 Testando sessão do corner (30s, 3 turnos)..."
	mkdir -p $(CORNER_DIR)
	@[ -f "$(CORNER_DIR)/PROMPT.md" ] || cp templates/PROMPT.md $(CORNER_DIR)/PROMPT.md
	cd $(CORNER_DIR) && timeout 30 claude \
		--allowedTools "Read,Write,Edit" \
		--max-turns 3 \
		-p "Você tem 30 segundos de tempo livre. Crie um arquivo chamado test-$(shell date +%Y%m%d).md com uma frase criativa." \
		2>/dev/null \
		&& echo "  ✓ Sessão ok — verifique ~/claude-corner/" \
		|| echo "  ⚠️  Sessão encerrou (pode ser normal se timeout)"

# ─── status ───────────────────────────────────────────────────────────────────

status:
	@echo ""
	@echo "  Comandos globais: $$([ -d '$(GLOBAL_CMDS)' ] && echo instalados || echo não instalados)"
	@echo "  Hook ativo:       $$(grep -q '$(PLUGIN_ROOT)' $(SETTINGS) 2>/dev/null && echo sim || echo não)"
	@echo "  ~/claude-corner:  $$([ -d '$(CORNER_DIR)' ] && echo existe || echo não existe)"
	@echo "  settings.json:    $$([ -f '$(CORNER_DIR)/.claude/settings.json' ] && echo existe || echo não existe)"
	@echo "  Corner rodando:   $$([ -f '$(HOME)/.claude/.corner-lock' ] && echo sim || echo não)"
	@echo "  Prompts contados: $$(cat '$(HOME)/.claude/.corner-count' 2>/dev/null || echo 0)"
	@echo "  Arquivos criados: $$(ls '$(CORNER_DIR)' 2>/dev/null | grep -v PROMPT.md | wc -l | tr -d ' ')"
	@echo ""
