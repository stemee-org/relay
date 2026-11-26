# Guida a relay

[English](guide.md) · **Italiano**

Come si usa ogni comando, cosa aspettarsi e cosa resta nella repo. Per installarlo e per una panoramica: [README](../README.it.md).

- [Il ciclo](#il-ciclo)
- [`new-project`: impostare la repo](#new-project-impostare-la-repo)
- [`start-session`: aprire una sessione](#start-session-aprire-una-sessione)
- [`start-multi-session`: più task, una sola tab](#start-multi-session-più-task-una-sola-tab)
- [`replan`: cambiare il piano](#replan-cambiare-il-piano)
- [`plan`, `adr`, `write-prompt`](#plan-adr-write-prompt)
- [`end-session`: chiudere una sessione](#end-session-chiudere-una-sessione)
- [I task](#i-task)
- [In più persone](#in-più-persone)
- [Domande frequenti](#domande-frequenti)

## Il ciclo
```
/relay:new-project            una volta
        │
        ▼
/relay:start-session  ──►  lavoro sul task  ──►  /relay:end-session
        ▲                        │                       │
        │                        ▼                       │
        │                 /relay:replan                  │
        │           (il piano deve cambiare)             │
        └────────────── sessione successiva ◄────────────┘
```

Tre regole tengono insieme tutto:

- **Ciò che non è nella repo non esiste.** Una sessione comincia leggendo i documenti e finisce aggiornandoli.
- **Ogni informazione ha un solo posto.** Gli altri documenti rimandano con un link.
- **Niente di finto.** Nessun comando che non esiste, nessuna data che nessuno ha fissato, nessuna decisione che nessuno ha preso.

## `new-project`: impostare la repo
```
/relay:new-project [cartella o nome] [riferimento]
```

Esempi:

```
/relay:new-project                               nella cartella corrente, da zero
/relay:new-project gestionale                    in una cartella nuova
/relay:new-project . ../prototipo                ricostruendo un prototipo
/relay:new-project . https://github.com/org/repo ispirandosi a una repo esistente
```

Il **riferimento** è qualunque cosa il progetto debba ricostruire, copiare o migliorare: un prototipo, una versione vecchia, il prodotto di qualcun altro, una specifica, dei PDF. Viene solo letto, mai modificato.

### Cosa succede
1. **Crea i documenti**, senza fare domande. In una repo che ne ha già alcuni non sovrascrive nulla: elenca quelli che ha lasciato com'erano e li integra dopo, a mano.
2. **Installa i plugin di supporto** (`mattpocock-skills` e `ponytail`) per quella repo soltanto, e li abilita per chi la apre. Se l'installazione non riesce ti lascia i comandi da digitare e va avanti.
3. **Legge il riferimento per intero**, poi fa le **domande tecniche**. Chiede solo ciò che la lettura non dice, e ogni domanda ha tre parti: cosa ha trovato, cosa consiglia, cosa cambia con la risposta. Esempio:

   > In `api/import.py` le query SQL sono costruite unendo stringhe. Consiglio query parametrizzate: è la prima cosa che una revisione di sicurezza fermerebbe. Se sei d'accordo diventa una correzione dentro il task dell'import, non un task a parte.

   Le domande toccano: rapporto con il riferimento, cosa entra nella prima milestone, stack, struttura, dati, accessi, servizi esterni, livello di qualità, persone.
4. **Registra le decisioni** (un ADR per ogni scelta difficile da rovesciare), il glossario e l'architettura.
5. **Propone i plugin per lo stack**, se lo stack ne richiede, dicendoti cosa esegue o cosa invia ciascuno: vedi [le domande frequenti](#domande-frequenti). Installa solo quelli che accetti.
6. **Mostra l'elenco dei task e aspetta.** Per ognuno: titolo, perché esiste, cosa funziona alla fine, da cosa è bloccato. Puoi chiedere di unire, dividere, togliere, riordinare. È il punto in cui la skill si ferma e aspetta.
7. **Scrive le schede**, riempie il resto dei documenti, controlla che non resti nulla di incompleto e committa sul branch `<nome>/T00-docs-setup`.

Alla fine ti dice quali documenti ha scritto, quali decisioni ha registrato, quante sono le domande rimaste aperte e qual è il primo task da prendere.

### Cosa non fa
Non scrive codice di prodotto. Non fa push e non apre pull request senza chiedere. Non inventa: una scelta di stack ancora aperta diventa un ADR «proposto» e un task per deciderla.

### Rilanciarla
Si può rilanciare sulla stessa repo: salta ciò che c'è già e riprende dal primo punto incompleto.

## `start-session`: aprire una sessione
```
/relay:start-session
```

1. **Legge i documenti**: stato, ultimo handover, piano. Solo i Markdown, non il codice. Guarda anche i branch non uniti e le pull request aperte, perché un task preso lì non compare ancora su `main`, ed elimina i branch delle pull request già unite.
2. **Riassume** in meno di dieci righe: cosa è stato fatto, cosa è in corso e di chi, cosa viene dopo.
3. **Chiede quali task vuoi fare**, proponendo quelli che nessuno blocca e nessuno ha preso. Di quello scelto legge la scheda, lo segna a tuo nome nel piano e crea il branch.
4. **Carica le skill** che servono a quel lavoro e ti dice quali:

   | Il task richiede | Skill caricata |
   |---|---|
   | Di essere chiarito | `grilling` |
   | Un disegno: confini e interfaccia di un modulo | `codebase-design` |
   | Un termine nuovo o una decisione | `domain-modeling`, poi `/relay:adr` |
   | Un comportamento da costruire o cambiare | `tdd` |
   | Un difetto | `diagnosing-bugs` |
   | Un esperimento usa e getta | `prototype` |
   | Fatti da documentazione | `research` |
   | Codice, sempre | `ponytail`, prima della prima riga |
   | Ciò che copre un plugin per lo stack | Quello scelto dal progetto: vedi `CONTRIBUTING.md` |

5. **Mostra la squadra**: quali parti fa la sessione principale e quali i subagenti, con quale modello. Aspetta il tuo ok prima di toccare un file.

Se ciò che vuoi fare non è nel piano, la skill ti manda prima a `/relay:replan`. Se un plugin di supporto non è installato lo dice e prosegue senza.

Funziona anche per fare solo il punto: «a che punto siamo?» si ferma al riassunto.

## `start-multi-session`: più task, una sola tab
```
/relay:start-multi-session
```

Per quando vuoi far avanzare più task insieme senza seguire quattro o cinque tab. La tab in cui lo lanci diventa l'orchestratore ed è l'unica che leggi; le altre lavorano.

1. **Controlla il suo modello**: Fable 5.2 con effort `high`, oppure Opus 5.5 con effort `xhigh` dove Fable non c'è. Su un altro ti dice di cambiarlo.
2. **Legge i documenti**, come `start-session`, e guarda come funziona la CI nella repo.
3. **Propone la divisione**: quali task possono andare in parallelo (nessuno blocca un altro, nessuno tocca i file di un altro), in quante sessioni (da 2 a 5), con quale modello ciascuna. Aspetta il tuo via, poi chiede una volta sola ciò che altrimenti chiederebbe ogni tab: se possono aprire la pull request da sole, se possono partire senza aspettare.
4. **Prepara un branch e una cartella per task** (un worktree di git), così le sessioni non si pestano i piedi.
5. **Ti dà un prompt per task.** Apri una tab per ognuno, scegli il modello scritto sopra e incolli. Da lì in poi torni dall'orchestratore.
6. **Le segue tutte.** Ogni sessione scrive all'orchestratore quando parte, quando ha una domanda, quando le serve un file non suo, quando la pull request è aperta. L'orchestratore risponde a ciò a cui rispondono i documenti, porta a te le decisioni che sono tue e tiene un solo tabellone:

   | Tiene d'occhio | Come |
   |---|---|
   | I file | Cosa ha modificato ogni sessione, rispetto ai file che le erano stati dati: un file toccato da due sessioni viene fermato prima che diventi un conflitto |
   | Le pull request | Quali sono aperte, i loro controlli, quali sono in conflitto con `main` |
   | Le run di CI | L'obiettivo è una per pull request; ognuna in più ha un motivo scritto nel tabellone |
   | I merge | Propone l'ordine e unisce solo quando lo chiedi |

7. **Chiude il giro**: lo stato, una volta per tutti, e un resoconto con le run di CI spese rispetto alle pull request aperte.

### Come tiene basse le run di CI
- Ogni sessione fa **un solo push**: dopo aver portato dentro `main`, aver eseguito in locale tutto ciò che esegue la CI, e con handover, revisione e segno `in review` già nei commit.
- Una run fallita si riproduce in locale e si corregge per intero prima del push successivo. Nessuno fa push per vedere cosa dice la CI.
- Prima dei merge, l'orchestratore unisce tutti i branch del giro in una cartella usa e getta ed esegue i controlli una volta, in locale: ciò che si rompe solo insieme si trova senza spendere una run.
- Dopo un merge, le altre pull request **non** vengono tutte aggiornate. Solo quella in conflitto, o la prossima in fila se la repo richiede branch aggiornati.

## `replan`: cambiare il piano
```
/relay:replan [cosa cambia]
```

Esempi:

```
/relay:replan aggiungi l'esportazione in PDF delle fatture
/relay:replan T12 è troppo grande, dividilo
/relay:replan togli T09, non serve più
/relay:replan T15 deve venire prima di T11
/relay:replan lavorando a T07 è venuto fuori che manca la validazione degli importi
```

### I casi
| Caso | Cosa succede |
|---|---|
| **Aggiungere** | Scheda e riga nuove. Prima controlla che un task esistente non lo copra già |
| **Modificare** | Cambiano le sezioni della scheda, con una riga datata che dice cosa e perché |
| **Dividere** | L'originale tiene il suo id con lo scopo ridotto, il resto prende un id nuovo |
| **Unire** | Un id sopravvive e la sua scheda dice quale task ha assorbito |
| **Riordinare** | Cambiano i blocchi tra i task; controlla che non nasca un ciclo |
| **Togliere** | Riga e scheda vanno via; resta una riga nei non-obiettivi con il motivo |
| **In corsa** | Un pezzo emerso a metà di un task: vedi sotto |

Per un pezzo **in corsa** la skill decide con te dove va:

- Senza di esso il task in corso non può dirsi finito → fa parte del task, e la scheda si corregge.
- Può aspettare → è un task nuovo. Il task in corso non si allarga in silenzio.
- Va fatto prima → è un task nuovo che blocca quello in corso.

### Cosa succede
1. Capisce il caso e chiede solo ciò che manca.
2. Legge il piano, le schede coinvolte e ogni punto dei documenti che nomina quei task, anche sui branch non uniti.
3. Calcola l'impatto: tabellone, schede, blocchi degli altri task, milestone, decisioni, glossario, architettura, stato.
4. **Mostra il prima e il dopo**, con l'elenco dei documenti toccati, e aspetta il tuo ok.
5. Scrive tutto insieme, controlla la coerenza e committa.

### Regole che non si piegano
- Un id non si riusa mai, nemmeno quello di un task tolto.
- Un task già `done` non si riscrive: ciò che ha lasciato fuori è un task nuovo.
- Il task di un'altra persona non si cambia senza sentirla.
- Una modifica che va contro una decisione registrata richiede prima una decisione nuova (`/relay:adr`).
- Ogni modifica lascia nella scheda la data, il motivo e chi l'ha chiesta.

Una modifica che riguarda solo il task in corso si committa sul suo branch. Ogni altra va su un branch suo e in una pull request, perché il piano su `main` è quello che leggono gli altri.

## `plan`, `adr`, `write-prompt`
**`/relay:plan`**: prima di un task che tocca più di qualche file. Legge architettura, decisioni e codice coinvolto, ti chiede ciò che dovrebbe altrimenti indovinare e scrive `docs/plans/<task>-<nome>.md`: obiettivo, cosa resta fuori, approccio, squadra, passi piccoli e verificabili, test. Aspetta l'approvazione prima che si scriva codice.

**`/relay:adr`**: quando si prende una scelta difficile da rovesciare (libreria, modello dei dati, autenticazione, hosting). Crea un file numerato in `docs/decisions/` con contesto, decisione, alternative e conseguenze. Una decisione accettata non si modifica: si sostituisce con una nuova.

**`/relay:write-prompt [task] [opus|fable]`**: quando vuoi affidare un task intero a un'altra sessione. Scrive il prompt, pronto da incollare, per un modello orchestratore con la sua squadra di subagenti. Scrive solo il prompt: non esegue il task.

## `end-session`: chiudere una sessione
```
/relay:end-session
```

Due casi, stessa skill.

**Il task è finito:**

1. Controlla il branch: mai `main`.
2. Lancia test, lint e type-check. Se uno fallisce lo corregge e riprova.
3. Fa rivedere il diff: l'agente `code-reviewer`, `security-auditor` se il task tocca input, accessi o pagamenti, più le revisioni dei plugin di supporto se installati.
4. Scrive l'handover, aggiorna lo stato e la riga del task. Se è nato lavoro non previsto ti manda a `/relay:replan`.
5. Committa: il messaggio dice cosa cambia, perché, cosa è stato scartato, come è stato verificato e cosa resta non verificato.
6. **Chiede** se fare push e aprire la pull request, con il task già segnato `in review`: un push, una run di CI. Poi controlla la CI.

**Ti fermi a metà:** scrive handover e stato, committa, e fa push solo se lo chiedi. Nessuna pull request. L'handover dice esattamente cosa è a metà e qual è la prossima mossa.

In nessun caso unisce la pull request: è una decisione a parte. Quando chiedi di unirla, il branch viene eliminato insieme.

## I task
Il tabellone in `docs/PLAN.md` ha una riga per task: id, titolo, milestone, da cosa è bloccato, di chi è, branch, stato. Un task si può prendere quando tutti quelli che lo bloccano sono `done`.

Ogni task ha poi una scheda in `docs/tasks/`:

| Sezione | Dice |
|---|---|
| Titolo | Cosa funziona quando è finito |
| Why | Perché esiste e perché a questo punto: cosa sblocca, da quale decisione nasce |
| What to build | Il comportamento alla fine, visto da chi lo usa |
| From the reference | Dove sta l'originale; cosa si tiene, cosa si cambia e perché, cosa si toglie |
| Done when | Controlli che si possono eseguire o vedere |
| Out of scope | Cosa ci si aspetterebbe qui e invece sta altrove |
| Notes | Decisioni che si applicano, domande aperte, modifiche con la data |

Un task scritto male:

> **T07 · Backend fatture.** Portare il codice delle fatture dal prototipo. Finito quando funziona.

Lo stesso task scritto bene:

> **T07 · Un cliente può creare una fattura e vederne il totale**
>
> **Perché.** È la prima funzione e attraversa database, API e pagina: T08–T12 ne copiano la forma, quindi un errore qui costa meno adesso. Gli importi seguono l'ADR 0006 (interi in centesimi).
>
> **Cosa costruire.** Un cliente che ha fatto l'accesso aggiunge righe a una fattura nuova, la salva e vede imponibile, imposta e totale; riaprendola trova gli stessi numeri.
>
> **Dal riferimento.** `server/invoices.js`. Si tiene: l'arrotondamento per riga. Si cambia: gli importi diventano centesimi interi, perché i decimali del prototipo perdono un centesimo su alcuni totali. Si toglie: l'esportazione CSV, che nessuno usava.
>
> **Finito quando.** ☐ I totali coincidono con i casi svolti nel piano. ☐ Una riga con quantità negativa è rifiutata con un messaggio che la nomina. ☐ Test, lint e type-check passano.
>
> **Fuori.** Il download in PDF (T08).

La prova di una scheda: chi non era nella sessione, con la sola scheda, sa dire perché il task esiste, può cominciarlo senza chiedere e sa quando fermarsi.

## In più persone
- **Un task ha un solo proprietario**, scritto nel piano prima di cominciare. `start-session` guarda anche i branch non uniti, quindi un task preso da un collega risulta preso anche se `main` dice ancora `todo`.
- **Ognuno lavora su un branch suo** (`<nome>/<task>-<descrizione>`) e apre una pull request. Mai push su `main`.
- **Un branch unito si elimina.** Quando la pull request è su `main` il branch sparisce, su GitHub e sul tuo computer, così ogni branch rimasto significa lavoro in corso. `new-project` attiva l'eliminazione automatica di GitHub; `start-session` toglie quelli rimasti.
- **Handover, decisioni e piani sono un file per voce**: nessun conflitto, e nessuno modifica il file di un altro.
- **Chi apre la repo riceve i plugin**: `.claude/settings.json` li abilita e Claude Code propone di installarli.

## Domande frequenti
**Funziona su una repo che ha già del codice?**
Sì. Il kit si aggiunge attorno al codice senza spostare nulla; i documenti descrivono ciò che esiste e il piano parte dai difetti di oggi.

**In che lingua sono i documenti?**
La scegli durante le domande. I titoli delle sezioni restano in inglese, perché le skill li cercano; codice, commenti e nomi in inglese.

**Devo usare per forza `mattpocock-skills` e `ponytail`?**
No. Se mancano, `start-session` ed `end-session` lo dicono e proseguono senza. Per non farli proporre a chi apre la repo, toglili da `enabledPlugins` in `.claude/settings.json`.

**Quali altri plugin propone?**
Tre, ciascuno solo se lo stack lo richiede. `modern-web-guidance` per il codice che gira nel browser: solo guide, non esegue nulla. `playwright` per controllare le pagine in un browser vero: avvia un server locale con `npx`, quindi serve Node. `context7` per la documentazione aggiornata delle librerie: i nomi delle librerie e le domande vanno a un servizio esterno, quindi non è adatto a un progetto con dipendenze riservate. Qualsiasi altro plugin si aggiunge chiedendolo; la skill prima legge cosa aggiunge e avvisa se ripete qualcosa che c'è già.

**`ponytail` si accende in tutti i miei progetti?**
No: `new-project` lo installa solo per quella repo.

**Posso modificare una skill per il mio progetto?**
Le skill stanno nel plugin, non nella repo, quindi si aggiornano da sole ma non si ritoccano in casa. Le regole del progetto si scrivono in `CLAUDE.md` e `CONTRIBUTING.md`, che vengono prima di ogni skill. Per una skill diversa: clona questa repo, modificala e installala con `./install.sh claude`.

**Uso Codex o un altro agente.**
Clona la repo e lancia `./install.sh codex`: collega le skill nella cartella dell'agente. Non è ancora stato provato fino in fondo.

**Come aggiorno il plugin?**
Si aggiorna con il marketplace. A mano: `/plugin marketplace update stemee-org`.

**Ho lanciato `/setup-matt-pocock-skills`. È un problema?**
Sposta glossario, decisioni e ticket in posti diversi da quelli del kit. Il kit contiene già ciò che quel setup scrive (`docs/agents/`), puntato sui propri documenti: non serve lanciarlo.

**Cosa controlla lo script di verifica?**
`scaffold.sh --check <repo>` elenca i segnaposto `{{…}}` rimasti, i task del tabellone senza scheda, le schede senza riga e quelle a cui manca il perché, il cosa o il quando è finito. Lo lanciano `new-project` e `replan`; se non stampa nulla è tutto a posto.
