# relay

[English](README.md) · **Italiano**

Un plugin per Claude Code che fa lavorare un progetto «prima i documenti»: ogni sessione parte dai documenti della repo e finisce aggiornandoli. Come in una staffetta, il testimone sono i documenti.

## A cosa serve
Un agente di programmazione non ricorda la sessione precedente, e nemmeno un collega sa cosa hai fatto ieri con il tuo. Ciò che non è scritto nella repo va perso: si rifà lavoro già fatto, si riapre una decisione già presa, due persone prendono lo stesso task.

`relay` risolve questo con tre cose:

- **Un posto per ogni informazione.** Cosa si sta costruendo, quali task restano, perché è stata fatta una scelta, cosa è successo nell'ultima sessione: ognuna ha il suo documento.
- **Task che si spiegano da soli.** Ogni task ha una scheda che dice perché esiste, cosa deve funzionare alla fine e quando è finito. Chi non c'era può cominciarlo senza chiedere.
- **Un ciclo fisso.** Otto comandi coprono la vita del progetto: impostarlo, aprire una sessione, cambiare il piano, chiuderla.

È pensato per chi lavora con Claude Code da solo o in più persone sulla stessa repo, su un progetto nuovo o su uno da ricostruire a partire da un prototipo.

## Installazione
In Claude Code:

```
/plugin marketplace add stemee-org/relay
/plugin install relay@stemee-org
```

Poi `/reload-plugins`, oppure apri una sessione nuova. Servono `git` e, per le pull request, la CLI `gh`.

## Primi dieci minuti
1. Apri Claude Code nella cartella del progetto (anche vuota) e lancia:
   ```
   /relay:new-project
   ```
   Se hai un prototipo o altro materiale da cui partire, indicalo: `/relay:new-project . ../il-mio-prototipo`.
2. La skill crea i documenti, installa i plugin di supporto, legge il materiale e ti fa alcune domande tecniche.
3. Ti mostra l'elenco dei task proposti. Correggilo finché ti convince, poi dai l'ok: scrive le schede e committa.
4. Da qui in poi ogni sessione di lavoro è:
   ```
   /relay:start-session      scegli il task
   …lavori…
   /relay:end-session        handover, commit, pull request
   ```
5. Quando serve un task nuovo o uno va cambiato: `/relay:replan`.

## I comandi
| Quando | Comando | Cosa fa |
|---|---|---|
| Una volta, all'inizio | `/relay:new-project` | Imposta la repo: documenti, plugin, domande tecniche, task |
| A ogni inizio sessione | `/relay:start-session` | Legge i documenti, chiede quali task fare, carica le skill che servono |
| Per lavorare a più task insieme | `/relay:start-multi-session` | Divide i task su più tab, scrive un prompt per ognuna e le segue tutte da una sola: file toccati, pull request, run di CI, ordine dei merge |
| Quando il piano cambia | `/relay:replan` | Aggiunge, modifica, divide, unisce o toglie task, e aggiorna i documenti che ne dipendono |
| Prima di un task grande | `/relay:plan` | Scrive il piano della feature e lo fa approvare |
| A ogni scelta difficile da rovesciare | `/relay:adr` | Registra la decisione e le alternative scartate |
| Per passare un task a un'altra sessione | `/relay:write-prompt` | Scrive il prompt per un orchestratore con la sua squadra |
| A ogni fine sessione | `/relay:end-session` | Verifica, revisione, handover, stato, commit, pull request |

Nessun comando scrive su `main` né unisce una pull request: push e pull request si fanno solo dopo aver chiesto.

**Come si usa ogni comando, con esempi: [docs/guida.md](docs/guida.md).**

## Cosa trovi nella repo dopo `/relay:new-project`
```
CLAUDE.md                 ciò che ogni sessione deve sapere: stack, comandi, regole
CONTRIBUTING.md           come si lavora: branch, squadra, plugin
docs/
  PLAN.md                 obiettivo, milestone, tabellone dei task
  tasks/                  una scheda per task
  STATUS.md               cosa è vero adesso, in una schermata
  handover/               un file per sessione: cosa è stato fatto, cosa resta
  decisions/              le decisioni (ADR): perché X e non Y
  plans/                  i piani delle feature grandi
  ARCHITECTURE.md         come sta insieme il sistema
  GLOSSARY.md             le parole del progetto, un significato ciascuna
.claude/                  permessi, due hook, tre agenti di revisione
.github/                  CI generica, template di issue e pull request
```

## Gli altri plugin
`/relay:new-project` installa e abilita per la repo anche:

- [`mattpocock-skills`](https://github.com/mattpocock/skills), per le parti tecniche: sviluppo guidato dai test, diagnosi dei difetti, progettazione dei moduli.
- [`ponytail`](https://github.com/DietrichGebert/ponytail), per il codice: cerca ciò che esiste già e scrive solo ciò che serve.

In base allo stack propone anche [`modern-web-guidance`](https://github.com/GoogleChrome/modern-web-guidance) (codice che gira nel browser), `playwright` (controllo delle pagine in un browser vero) e `context7` (documentazione aggiornata delle librerie). Lo chiede una volta e installa solo ciò che accetti.

`/relay:start-session` carica le loro skill quando il task le richiede. I documenti e le decisioni del progetto vengono comunque prima di qualsiasi skill.

## Stato
Versione 0.5.0. Lo scaffold, il controllo dei task e l'installazione sono provati da `tests/run.sh`, che gira in CI a ogni pull request. Non ancora provati: un progetto vero dall'inizio alla fine, e l'uso dentro Codex.

Il metodo nasce dalla ricostruzione di stemee a partire da un prototipo (novembre 2026): il kit è quello usato lì, ripulito da ciò che era specifico del progetto.

## Per chi vuole modificarlo
- `skills/<nome>/SKILL.md`: le otto skill. Ognuna ha una sola copia, qui: il kit non le copia nelle repo.
- `skills/new-project/reference/`: il metodo (`method.md`), come si legge un riferimento (`from-reference.md`), le domande tecniche e com'è fatto un buon task (`tasks.md`).
- `skills/new-project/templates/`: il kit copiato nel progetto. Il prefisso `dot-` diventa un punto (`dot-claude/` → `.claude/`).
- `skills/new-project/scripts/scaffold.sh`: copia il kit; con `--check` elenca ciò che è ancora da riempire.
- `tests/run.sh`: le prove. `./tests/run.sh` prima di ogni commit.

Chi cambia una regola del metodo la cambia in `method.md`, nei template che la ripetono e nelle skill che la applicano: si cerca la vecchia formulazione con `grep` prima di committare. La documentazione esiste in inglese e in italiano: una modifica va in entrambe (`README.md` e `README.it.md`, `docs/guide.md` e `docs/guida.md`).

## Codice di comportamento
Partecipare a questo progetto significa rispettarne il [codice di comportamento](CODE_OF_CONDUCT.it.md). Un comportamento inaccettabile si segnala a relay@stemee.eu.

## Licenza
[MIT](LICENSE).
