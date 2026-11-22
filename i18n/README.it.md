# ZeroLaunch

**Lingue**: [English](../README.md) | [简体中文](README.zh.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [Tiếng Việt](README.vi.md) | [Italiano](README.it.md) | [Čeština](README.cs.md)

## 📥 Download

**[Scarica qui](https://github.com/zerojs/zero-launch/releases/latest)** - Ottieni l'ultima versione

🌐 **Sito web**: [www.zerojs.cn](https://www.zerojs.cn/)  
📚 **Documentazione**: [www.zerojs.cn](https://www.zerojs.cn/)

⭐ Considera di mettere una stella a [ZeroLaunch](https://github.com/zerojs/zero-launch) e soprattutto a [LaunchNow](https://github.com/ggkevinnnn/LaunchNow)!

| | |
|:---:|:---:|
| ![](../public/banner.webp) | ![](../public/setting1.webp) |
| ![](../public/setting2.webp) | ![](../public/setting3.webp) |

macOS Tahoe ha rimosso Launchpad e la sostituzione è penosa da usare: non sfrutta nemmeno la tua GPU. Apple, date almeno agli utenti la possibilità di tornare indietro. Fino ad allora, ecco ZeroLaunch.

*Basato su [LaunchNext](https://github.com/RoversX/LaunchNext) di RoversX — un enorme grazie al progetto originale!❤️ LaunchNext, a sua volta, si basa su [LaunchNow](https://github.com/ggkevinnnn/LaunchNow) di ggkevinnnn.*

*LaunchNow ha scelto la licenza GPL 3. LaunchNext e ZeroLaunch seguono gli stessi termini di licenza.*

## ✨ ZeroLaunch Highlights

ZeroLaunch è sviluppato attivamente sulla base di LaunchNext. Ecco cosa **aggiunge questo fork** rispetto all'originale:

- ⚡ **Revisione delle prestazioni a livello di motore** — il diff dell'albero dei livelli ridisegna solo le icone modificate invece di ricostruirne oltre 500; lo scorrimento delle pagine è identico su display a 60 e 120 Hz; cache delle icone sensibile alla scala con limite di dimensione; persistenza incrementale (un trascinamento = una scrittura su disco)
- 🗑️ **Modalità disinstallazione con pressione prolungata** — modalità «jiggle» in stile iOS con un flusso sicuro di eliminazione nel Cestino e fallback multilivello sui permessi (anche le app dell'App Store di proprietà di root possono essere eliminate)
- 📁 **Cartelle che si aprono al passaggio del mouse** — tieni un'app sospesa su una cartella e si espande automaticamente dopo un istante; rilascia all'interno per posizionarla esattamente dove vuoi
- 🧲 **Cambio pagina al bordo con indicatore** — trascina le app al bordo dello schermo per cambiare pagina con una barra di indicazione visiva; le pagine vuote vengono riutilizzate, così non si accumula disordine
- 🎬 **Animazioni simmetriche di apertura e chiusura** — all'apertura il pannello si restringe verso il centro, alla chiusura si espande verso l'esterno, con durata configurabile
- 🗂️ **Espansione delle cartelle in stile LaunchOS** — le cartelle crescono dall'icona che hai cliccato; rinomina con un clic grazie a un campo di input adattivo
- ⚙️ **Impostazioni completamente ricostruite** — ricerca nelle impostazioni con navigazione da tastiera, ripristino per singola sezione, selettore di ambito Schermo intero/Finestra e opzioni correlate raggruppate in schede
- 🧹 **Opzioni riviste e ripulite** — impostazioni inutilizzate rimosse, denominazione uniforme Schermo intero/Finestra, cursore numerico per il peso del font, indicatore di utilizzo della memoria in tempo reale e scorciatoia per riavviare subito dopo il cambio di modalità di prestazioni
- 🌍 **14 lingue** — ogni nuova impostazione arriva localizzata (en, zh-Hans, zh-Hant, ja, ko, fr, es, de, ru, it, cs, pt-BR, vi, hi)
- 🚢 **Distribuzione indipendente** — Bundle ID proprio, comando `zerolaunch`, aggiornamento automatico integrato e script di rilascio
- 🛠️ **Correzioni reali di bug** — sfondo della carta da parati in macOS 26 (abbinamento locale della finestra + fallback a livello di file), perdita di focus del pannello Impostazioni, aree di clic troppo piccole sui pulsanti distruttivi e altro

## 🚀 Installazione

### Opzione 1 — Scarica la release
1. Prendi `ZeroLaunch<versione>.zip` dall'[ultima release](https://github.com/zerojs/zero-launch/releases/latest)
2. Estrai l'archivio e trascina `ZeroLaunch.app` in `/Applications`
3. Avviala — se macOS la blocca, vedi la nota qui sotto

### Opzione 2 — Compila dal sorgente

Vedi [Compila dal codice sorgente](#compila-dal-codice-sorgente) qui sotto.

> ⚠️ **Se macOS blocca l'app, esegui questo nel Terminale:**
```bash
sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app
```
**Perché**: le release di ZeroLaunch sono firmate ad hoc e non ancora notarizzate (nessuna membership Apple Developer a pagamento), quindi macOS blocca le app non firmate per impostazione predefinita. Questo comando rimuove il flag di quarantena per consentirne l'esecuzione. **Usa questo comando solo con app di cui ti fidi.** Puoi anche fare clic destro sull'app → **Apri** → conferma.

**Stato della firma**: attualmente le release sono **firmate ad hoc, non notarizzate**. Gatekeeper può avvisare al primo avvio; vedi il comando sopra oppure clic destro → Apri. Quando in futuro verrà aggiunta una membership Apple Developer a pagamento, le release passeranno alla firma Developer ID e alla notarizzazione. Compili dal sorgente? Vedi [Configura la firma locale](#configure-local-code-signing).

### Cosa offre ZeroLaunch
- ✅ **Importazione con un clic dal vecchio Launchpad di sistema** — legge direttamente il database SQLite nativo di Launchpad (`/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`) per ricreare perfettamente cartelle, posizioni delle app e layout
- ✅ **Esperienza classica di Launchpad** — funziona esattamente come l'interfaccia originale tanto amata
- ✅ **Supporto multilingua** — internazionalizzazione completa con inglese, cinese semplificato, cinese tradizionale, giapponese, francese, spagnolo, tedesco, russo e altro ancora
- ✅ **Nascondi le etichette delle icone** — vista pulita e minimalista quando non servono i nomi delle app
- ✅ **Dimensioni delle icone personalizzabili** — regola le dimensioni delle icone secondo le tue preferenze
- ✅ **Gestione intelligente delle cartelle** — crea e organizza le cartelle come prima
- ✅ **Ricerca approssimata e navigazione da tastiera** — trova le app rapidamente, anche con input parziale o impreciso
- ✅ **Supporto CLI / TUI** — ispeziona e gestisci il layout dal terminale con il comando `zerolaunch`
- ✅ **Hot Corner e gesti nativi** — apri ZeroLaunch dagli angoli, con gesti del trackpad e opzioni a 4 / 5 dita
- ✅ **Trascina le app direttamente nel Dock** — disponibile in Next Engine + Core Animation
- ✅ **Cartelle Core Animation** — il contenuto delle cartelle supporta layout a pagine e a scorrimento verticale
- ✅ **Menu contestuale migliorato** — Mostra nel Finder, Copia percorso app, Rinomina cartella e azioni di disinstallazione configurate
- ✅ **Scheda aggiornamenti con note di rilascio Markdown** — esperienza di aggiornamento integrata più ricca
- ✅ **Miglioramenti a backup, controller e supporto vocale** — maggiore affidabilità e accessibilità

### Cosa macOS Tahoe ha tolto
- ❌ Nessuna organizzazione personalizzata delle app
- ❌ Nessuna cartella creata dall'utente
- ❌ Nessuna personalizzazione drag-and-drop
- ❌ Nessuna gestione visiva delle app
- ❌ Raggruppamento categorico forzato


### Archiviazione dati
I dati dell'applicazione sono archiviati in modo sicuro in:
```
~/Library/Application Support/ZeroLaunch/Data.store
```

### Integrazione nativa con Launchpad
Legge direttamente dal database Launchpad del sistema:
```bash
/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db
```

## Compilazione dal codice sorgente

### Requisiti
- macOS 26 (Tahoe) o successivo
- Processore Apple Silicon o Intel
- Xcode 26 (per compilare dal sorgente)

### Compila dal codice sorgente

1. **Clona il repository**
   ```bash
   git clone https://github.com/zerojs/zero-launch.git
   cd zero-launch
   ```

2. **Apri in Xcode**
   ```bash
   open LaunchNext.xcodeproj
   ```

3. <a name="configure-local-code-signing"></a>**Configura la firma del codice locale**
   - Per compilare o contribuire a ZeroLaunch non serve una membership Apple Developer a pagamento.
   - Seleziona il target **LaunchNext**, apri **Signing & Capabilities**, imposta **Team** sul tuo team (va bene anche un Personal Team gratuito) oppure imposta **Team** su `None` e seleziona `Sign to Run Locally` come certificato di firma.
   - Lascia Hardened Runtime abilitato.
   - Xcode può segnare il file di progetto come modificato dopo aver cambiato queste impostazioni locali. Non includere modifiche relative solo alla firma in una pull request.

4. **Compila ed esegui**
   - Per avviare l'app con `⌘+R`, seleziona `My Mac` come destinazione di esecuzione, non `Any Mac`.
   - `Any Mac (arm64, x86_64)` è pensato per build e archivi generici; non può avviare l'app per il debug.
   - Premi `⌘+B` se vuoi solo compilare.

### Compilazione da riga di comando

**Build standard:**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release
```

**Build universale (Intel + Apple Silicon):**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO clean build
```

**Pacchetto release (zip + checksum, firmato ad hoc):**
```bash
./scripts/release.sh
```

## Utilizzo

### Iniziare
1. **Primo avvio**: ZeroLaunch scansiona automaticamente tutte le app installate
2. **Selezione**: clicca per selezionare le app, doppio clic per avviarle
3. **Ricerca**: inizia a digitare per filtrare istantaneamente le app
4. **Organizzazione**: trascina le app per creare cartelle e layout personalizzati
5. **Automazione**: abilita la CLI nelle Impostazioni se vuoi flussi di lavoro da terminale

### Importa il tuo Launchpad
1. Apri le Impostazioni (icona dell'ingranaggio)
2. Fai clic su **«Import Launchpad»**
3. Il layout e le cartelle esistenti vengono importati automaticamente


### Modalità di visualizzazione
- **Finestra**: finestra flottante con angoli arrotondati
- **Schermo intero**: modalità a schermo intero per la massima visibilità
- **Legacy Engine** e **Next Engine + Core Animation** sono disponibili nelle Impostazioni
- ZeroLaunch può mantenere impostazioni separate per la modalità a schermo intero e quella a finestra
- È disponibile il nascondimento opzionale della barra dei menu a schermo intero; quando è attivo, macOS nasconde anche il Dock

## Funzionalità avanzate

### Ricerca e cartelle
- **Ricerca approssimata**: trova le app con nomi parziali, abbreviazioni e input imprecisi
- **Ritardo di ricerca configurabile**: regola il tempo di debounce della ricerca nelle Impostazioni
- **Modalità di layout delle cartelle**: scegli tra cartelle a pagine in stile Launchpad e cartelle a scorrimento verticale
- **Rendering delle cartelle con Core Animation**: interazione più fluida con le cartelle grandi

### Interazione intelligente con lo sfondo
- Il rilevamento intelligente dei clic evita chiusure accidentali
- Gestione dei gesti sensibile al contesto
- Protezione del campo di ricerca

### Ottimizzazione delle prestazioni
- **Cache delle icone**: caching intelligente delle immagini per uno scorrimento fluido
- **Caricamento lazy**: uso efficiente della memoria
- **Scansione in background**: rilevamento delle app senza bloccare

### Automazione e attivazione
- **CLI / TUI**: gestisci ZeroLaunch dal terminale con `zerolaunch`
- **Hot Corner**: apri ZeroLaunch da un angolo configurabile dello schermo
- **Gesti nativi sperimentali**: azioni pinch e tap a 4 / 5 dita, con selezione di un dispositivo trackpad esterno
- **Trascinamento nel Dock**: consegna le app direttamente al Dock di macOS in Next Engine + Core Animation

### Gestione delle app
- **Azioni nel menu contestuale**: mostra le app nel Finder, copia i percorsi, rinomina le cartelle e usa uno strumento di disinstallazione configurato

### Aggiornamenti e backup
- **Scheda aggiornamenti**: controlla gli aggiornamenti e leggi le note di rilascio Markdown nelle Impostazioni
- **Strumenti di backup**: crea e ripristina backup in modo più sicuro
- **Notifiche**: supporto dell'API di notifica moderna

### Supporto multi-monitor
- Rilevamento automatico degli schermi
- Posizionamento per singolo display
- Flussi di lavoro fluidi con più monitor

## Risoluzione dei problemi

### Problemi comuni

**Q: L'app non si avvia?**  
A: Verifica di essere su macOS 26.0+ e controlla i permessi di sistema. Se l'app è bloccata da Gatekeeper, esegui `sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app` oppure fai clic destro → Apri.

**Q: Quale motore dovrei usare?**  
A: `Next Engine + Core Animation` è quello consigliato per la migliore esperienza. `Legacy Engine` resta disponibile se ti serve davvero il vecchio percorso di compatibilità.

**Q: Perché il comando CLI non esiste ancora?**  
A: Abilita prima l'interfaccia a riga di comando nelle Impostazioni. ZeroLaunch può installare e rimuovere per te il comando gestito `zerolaunch`.

## Contribuire

I contributi sono benvenuti! Per favore:

1. Fai fork del repository
2. Crea un branch funzionale (`git checkout -b feature/amazing-feature`)
3. Esegui il commit delle modifiche (`git commit -m 'Add amazing feature'`)
4. Esegui il push del branch (`git push origin feature/amazing-feature`)
5. Apri una Pull Request

### Linee guida per lo sviluppo
- Segui le convenzioni di stile Swift
- Aggiungi commenti significativi per la logica complessa
- Testa su più versioni di macOS
- Mantieni la compatibilità con le versioni precedenti

## Il futuro della gestione delle app

Mentre Apple si allontana da interfacce personalizzabili, ZeroLaunch rappresenta una spinta verso il controllo e la personalizzazione da parte dell'utente. Spero ancora che Apple riporti indietro Launchpad.

**ZeroLaunch** non è solo un sostituto di Launchpad: è una dichiarazione che la scelta dell'utente conta.


---

**ZeroLaunch** - Riprendi il controllo del tuo launcher di app 🚀

*Per utenti macOS che non vogliono scendere a compromessi sulla personalizzazione.*

## Strumenti di sviluppo

- Claude Code 
- Cursor 
- OpenAI Codex CLI
- Perplexity
- Google



- Il supporto sperimentale ai gesti è costruito su [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport) e sul fork di [KrishKrosh](https://github.com/KrishKrosh/OpenMultitouchSupport).❤️


![GitHub downloads](https://img.shields.io/github/downloads/zerojs/zero-launch/total)
