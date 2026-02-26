# lean-claude-code

Un setup Claude Code minimalista e collaudato. Niente framework, niente plugin inutili, niente crypto token. Solo quello che funziona.

## Filosofia

L'ecosistema Claude Code ha 100+ plugin, la maggior parte dei quali brucia token iniettando contesto che non serve. La plugin fatigue e' reale, e lo e' anche il budget di contesto sprecato.

La tesi: un setup lean con hook mirati batte 15 plugin. Questo repo e' il risultato di mesi di utilizzo quotidiano di Claude Code su 5+ progetti in produzione. Ogni file qui si guadagna il suo posto.

## Cosa c'e' dentro

| Componente | Cosa fa | Sostituisce |
|---|---|---|
| Regole di model routing | Instrada Haiku/Sonnet/Opus per complessita' — risparmia ~60% sui costi token | Bruciare Opus per cercare file |
| Hook file sensibili | Blocca scritture su `.env`, `.pem`, file credenziali a livello di hook | Plugin di sicurezza |
| Hook re-iniezione memoria | Ripristina il contesto del progetto automaticamente dopo `/compact` | Plugin di gestione memoria |
| Script statusline | Mostra modello + contesto% + costo sessione in tempo reale | Plugin statusline |
| Pattern multi-agent | Architettura commander/implementer per lavoro parallelo | Plugin framework agent |

## Quick Start

```bash
# 1. Istruzioni globali
cp configs/CLAUDE.md ~/.claude/CLAUDE.md

# 2. Settings con hook
cp configs/settings.json ~/.claude/settings.json

# 3. Script statusline
cp configs/statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

Poi personalizza:

- `CLAUDE.md` — soglie di routing modelli, principi di lavoro
- `settings.json` — path specifici del progetto nell'hook SessionStart (il path del file memoria), aggiungi i tuoi file memoria
- `statusline-command.sh` — tariffe costo se usi modelli diversi

## Pattern Multi-Agent

Quando un task ha 3+ sotto-task indipendenti, usa il pattern commander/implementer invece del lavoro seriale. Il commander legge i file condivisi, assegna ownership esclusiva dei file a ogni agent, e integra i risultati. Gli agent lavorano in parallelo dove possibile.

Vedi [`docs/multi-agent-pattern.md`](docs/multi-agent-pattern.md) per tutti i dettagli.

```
┌─────────────────────────────┐
│     Commander (Opus/Sonnet) │
│     Legge file condivisi    │
│     Assegna ownership file  │
└──────┬──────┬──────┬────────┘
       │      │      │
  ┌────▼──┐ ┌─▼───┐ ┌▼─────┐
  │Agent 1│ │Ag. 2│ │Ag. 3 │
  │Haiku  │ │Son. │ │Haiku │
  │file_a │ │b,c  │ │tests │
  └───────┘ └─────┘ └──────┘
```

## Cosa NON installare

La maggior parte dei plugin Claude Code inietta testo prompt a ogni turno, bruciando 500-2000 token per interazione. In una sessione, sono 10-50k token sprecati in istruzioni che Claude gia' conosce.

I tool built-in di Claude Code — Glob, Grep, Read, Edit, Bash — coprono gia' il 95% dei casi d'uso. Prima di installare qualsiasi plugin, chiediti se un hook di 3 righe fa la stessa cosa.

Red flag da cercare nei repo dei plugin:

- Link a memecoin o funzionalita' token-gated
- `--dangerously-skip-permissions` negli esempi di utilizzo
- Piu' di 500 righe di contesto iniettato per turno
- La proposta di valore e' "fa automaticamente X" senza spiegare come

Se il pitch di un plugin e' l'automazione, controlla l'implementazione. Nove volte su dieci e' un wrapper di prompt.

## L'unico plugin che vale la pena

[Context7](https://github.com/upstash/context7) fornisce documentazione aggiornata delle librerie cosi' Claude non si inventa le API. Recupera la documentazione reale al momento della query invece di affidarsi ai dati di training.

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

Aggiungi questo a `~/.claude/settings.json` sotto `mcpServers`.

## Licenza

MIT

---

- `README.md` — English
- `README.it.md` — Italiano
