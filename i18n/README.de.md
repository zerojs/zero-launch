# ZeroLaunch

**Sprachen**: [English](../README.md) | [简体中文](README.zh.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [Tiếng Việt](README.vi.md) | [Italiano](README.it.md) | [Čeština](README.cs.md)

## 📥 Download

**[Hier herunterladen](https://github.com/zerojs/zero-launch/releases/latest)** - Holen Sie sich die neueste Version

🌐 **Website**: [www.zerojs.cn](https://www.zerojs.cn/)  
📚 **Dokumentation**: [www.zerojs.cn](https://www.zerojs.cn/)

⭐ Bitte geben Sie [ZeroLaunch](https://github.com/zerojs/zero-launch) und besonders dem ursprünglichen Projekt [LaunchNow](https://github.com/ggkevinnnn/LaunchNow) einen Stern!

| | |
|:---:|:---:|
| ![](../public/banner.webp) | ![](../public/setting1.webp) |
| ![](../public/setting2.webp) | ![](../public/setting3.webp) |

macOS Tahoe hat das Launchpad entfernt, und es ist so schwer zu bedienen, es nutzt nicht Ihre GPU. Bitte Apple, gebt den Leuten wenigstens eine Option, zurückzuwechseln. Bis dahin ist hier ZeroLaunch.

*Aufbauend auf [LaunchNext](https://github.com/RoversX/LaunchNext) von RoversX — ein riesiges Dankeschön an das Originalprojekt!❤️ LaunchNext selbst basiert wiederum auf [LaunchNow](https://github.com/ggkevinnnn/LaunchNow) von ggkevinnnn.*

*LaunchNow hat die GPL 3 Lizenz gewählt. LaunchNext und ZeroLaunch folgen denselben Lizenzbedingungen.*

## ✨ ZeroLaunch-Highlights

ZeroLaunch wird aktiv auf Basis von LaunchNext weiterentwickelt. Hier ist, was **dieser Fork** gegenüber dem Originalprojekt **hinzufügt**:

- ⚡ **Performance-Overhaul auf Engine-Ebene** — Differenzierung des Layer-Baums zeichnet nur die geänderten Icons neu, statt 500+ Layer neu aufzubauen; das Blättern zwischen Seiten fühlt sich auf 60-Hz- und 120-Hz-Displays identisch an; skalierungsbewusstes Icon-Caching mit begrenztem Cache; inkrementelle Persistenz (ein Ziehen = ein Datenträgerzugriff)
- 🗑️ **Deinstallationsmodus per Langdruck** — iOS-artiger Wackelmodus mit sicherem Papierkorb-Ablauf und mehrstufigen Berechtigungs-Fallbacks (sogar App-Store-Apps im Besitz von root können in den Papierkorb verschoben werden)
- 📁 **Ordner öffnen beim Hover** — halte eine App über einen Ordner, und er klappt nach kurzer Zeit automatisch auf; lasse sie darin fallen, um die App genau dort zu platzieren, wo du sie haben willst
- 🧲 **Seitenwechsel über den Rand mit Randhinweisen** — ziehe Apps an den Bildschirmrand, um mit einer visuellen Hinweisleiste zwischen Seiten zu wechseln; leere Seiten werden wiederverwendet, damit sich kein Chaos ansammelt
- 🎬 **Symmetrische Öffnungs-/Schließanimationen** — das Panel zoomt beim Öffnen zur Mitte und dehnt sich beim Schließen nach außen aus, mit konfigurierbarer Dauer
- 🗂️ **Ordneraufklappen im LaunchOS-Stil** — Ordner wachsen aus dem angeklickten Icon heraus; Umbenennen mit einem Klick über ein adaptives Eingabefeld
- ⚙️ **Vollständig neu gestaltete Einstellungen** — Suche innerhalb der Einstellungen mit Tastaturnavigation, Zurücksetzen pro Abschnitt, Umschalter für Vollbild/Fenster-Bereich und zusammengehörige Optionen in Karten gruppiert
- 🧹 **Geprüfte, entrümpelte Optionen** — tote Einstellungen entfernt, einheitliche Vollbild/Fenster-Benennung, numerischer Schieberegler für die Schriftstärke, Live-Anzeige der Speichernutzung und Direkt-Neustart nach dem Wechsel des Performance-Modus
- 🌍 **14 Sprachen** — jede neue Einstellung wird lokalisiert ausgeliefert (en, zh-Hans, zh-Hant, ja, ko, fr, es, de, ru, it, cs, pt-BR, vi, hi)
- 🚢 **Unabhängige Distribution** — eigene Bundle-ID, `zerolaunch`-CLI, integrierter Self-Updater und Release-Skripte
- 🛠️ **Echte Bugfixes** — macOS-26-Hintergrundbild (lokalisierte Fensterzuordnung + Fallback auf Dateiebene), Fokusverlust des Einstellungs-Fensters, zu kleine Klickbereiche bei destruktiven Buttons und mehr

## 🚀 Installation

### Option 1 — Release herunterladen

1. Lade `ZeroLaunch<Version>.zip` aus dem [neuesten Release](https://github.com/zerojs/zero-launch/releases/latest) herunter
2. Entpacke es und ziehe `ZeroLaunch.app` nach `/Applications`
3. Starte die App — falls macOS sie blockiert, siehe den Hinweis unten

### Option 2 — Aus dem Quellcode bauen

Siehe [Aus dem Quellcode bauen](#aus-dem-quellcode-bauen) unten.

> ⚠️ **Wenn macOS die App blockiert, führe dies im Terminal aus:**
```bash
sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app
```
**Warum**: ZeroLaunch-Releases sind derzeit ad-hoc signiert und noch nicht notarisiert (kein kostenpflichtiges Apple-Entwicklerkonto), daher blockiert macOS unsignierte Apps standardmäßig. Dieser Befehl entfernt das Quarantäne-Flag, damit die App laufen kann. **Verwende diesen Befehl nur bei vertrauenswürdigen Apps.** Du kannst auch mit der rechten Maustaste auf die App klicken → **Öffnen** → bestätigen.

**Code-Signing-Status**: Releases sind derzeit **ad-hoc signiert, nicht notarisiert**. Gatekeeper kann beim ersten Start warnen; siehe den Befehl oben oder nutze Rechtsklick → Öffnen. Sobald später ein kostenpflichtiges Apple-Entwicklerkonto hinzukommt, wechseln die Releases zu Developer-ID-Signierung + Notarisierung. Du baust aus dem Quellcode? Siehe [Lokale Code-Signierung konfigurieren](#configure-local-code-signing).

### Was ZeroLaunch bietet

- ✅ **Ein-Klick-Import vom alten System-Launchpad** - liest direkt die native Launchpad-SQLite-Datenbank (`/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`), um deine bestehenden Ordner, App-Positionen und dein Layout exakt wiederherzustellen
- ✅ **Klassische Launchpad-Erfahrung** - funktioniert genau wie die geliebte Originaloberfläche
- ✅ **Mehrsprachige Unterstützung** - vollständige Internationalisierung in Englisch, Vereinfachtem Chinesisch, Traditionellem Chinesisch, Japanisch, Französisch, Spanisch, Deutsch, Russisch und mehr
- ✅ **Icon-Beschriftungen ausblenden** - saubere, minimalistische Ansicht, wenn du keine App-Namen brauchst
- ✅ **Individuelle Icon-Größen** - passe die Icon-Abmessungen an deine Vorlieben an
- ✅ **Intelligente Ordnerverwaltung** - erstelle und organisiere Ordner wie zuvor
- ✅ **Fuzzy-Suche und Tastaturnavigation** - finde Apps schnell, selbst bei unvollständiger oder fehlerhafter Eingabe
- ✅ **CLI / TUI-Unterstützung** - prüfe und bediene dein Layout im Terminal mit dem Befehl `zerolaunch`
- ✅ **Hot Corner und native Gesten** - öffne ZeroLaunch über Ecken, Trackpad-Gesten und 4-/5-Finger-Optionen
- ✅ **Apps direkt ins Dock ziehen** - verfügbar in Next Engine + Core Animation
- ✅ **Core-Animation-Ordner** - der Ordnerinhalt unterstützt seitenbasierte und vertikal scrollende Layouts
- ✅ **Bessere Kontextmenüs** - Im Finder anzeigen, App-Pfad kopieren, Ordner umbenennen und konfigurierte Deinstallationsaktionen
- ✅ **Update-Tab mit Markdown-Release-Notes** - reichhaltigere In-App-Update-Erfahrung
- ✅ **Verbesserungen bei Backup, Controllern und Sprachausgabe** - mehr Zuverlässigkeit und Barrierefreiheit

### Was macOS Tahoe entfernt hat

- ❌ Keine benutzerdefinierte App-Organisation
- ❌ Keine benutzerdefinierten Ordner
- ❌ Keine Drag-and-Drop-Anpassung
- ❌ Keine visuelle App-Verwaltung
- ❌ Erzwungene kategorische Gruppierung

### Datenspeicherung

Anwendungsdaten werden hier gespeichert:

```text
~/Library/Application Support/ZeroLaunch/Data.store
```

### Native Launchpad-Integration

ZeroLaunch kann die System-Launchpad-Datenbank direkt lesen:

```bash
/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db
```

## Aus dem Quellcode bauen

### Anforderungen

- macOS 26 (Tahoe) oder neuer
- Apple Silicon oder Intel Prozessor
- Xcode 26 (zum Bauen aus dem Quellcode)

### Aus dem Quellcode bauen

1. **Repository klonen**
   ```bash
   git clone https://github.com/zerojs/zero-launch.git
   cd zero-launch
   ```

2. **In Xcode öffnen**
   ```bash
   open LaunchNext.xcodeproj
   ```

3. <a name="configure-local-code-signing"></a>**Lokale Code-Signierung konfigurieren**
   - Ein kostenpflichtiges Apple-Entwicklerkonto ist zum Bauen oder Mitwirken an ZeroLaunch nicht erforderlich.
   - Wähle das **LaunchNext-Target**, öffne **Signing & Capabilities**, setze **Team** auf dein eigenes Team (ein kostenloses Personal Team genügt), oder setze **Team** auf `None` und wähle `Sign to Run Locally` als Signaturzertifikat.
   - Lasse Hardened Runtime aktiviert.
   - Xcode kann die Projektdatei nach diesen lokalen Einstellungen als geändert markieren. Nimm reine Signaturänderungen nicht in einen Pull Request auf.

4. **Bauen und ausführen**
   - Um die App mit `⌘+R` zu starten, wähle `My Mac` als Ausführungsziel — nicht `Any Mac`.
   - `Any Mac (arm64, x86_64)` ist für generische Builds und Archive gedacht; damit lässt sich die App nicht zum Debuggen starten.
   - Drücke `⌘+B`, wenn du nur bauen möchtest.

### Kommandozeilen-Build

**Normaler Build:**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release
```

**Universelles Binary (Intel + Apple Silicon):**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO clean build
```

**Release-Paket (zip + Prüfsummen, ad-hoc signiert):**
```bash
./scripts/release.sh
```

## Verwendung

### Erste Schritte

1. **Erster Start**: ZeroLaunch scannt automatisch alle installierten Anwendungen
2. **Auswählen**: Klicken zum Auswählen von Apps, Doppelklick zum Starten
3. **Suchen**: Tippe, um Anwendungen sofort zu filtern
4. **Organisieren**: Ziehe Apps, um Ordner und eigene Layouts zu erstellen
5. **Automatisieren**: Aktiviere die CLI in den Einstellungen, wenn du Terminal-Workflows nutzen möchtest

### Ihr Launchpad importieren

1. Öffne die Einstellungen (Zahnrad-Symbol)
2. Klicke auf **„Import Launchpad"**
3. Dein bestehendes Layout und deine Ordner werden automatisch importiert

### Anzeigemodi

- **Fenster**: schwebendes Fenster mit abgerundeten Ecken
- **Vollbild**: Vollbildmodus für maximale Sichtbarkeit
- **Legacy Engine** und **Next Engine + Core Animation** sind in den Einstellungen verfügbar
- ZeroLaunch kann getrennte Einstellungen für Vollbild- und Fenstermodus speichern
- Optionales Ausblenden der Menüleiste im Vollbild; macOS blendet in diesem Modus auch das Dock aus

## Erweiterte Funktionen

### Such- und Ordner-Erlebnis

- **Fuzzy-Suche**: finde Apps anhand unvollständiger Namen, Abkürzungen und fehlerhafter Eingaben
- **Konfigurierbare Suchverzögerung**: passe das Debounce-Timing der Suche in den Einstellungen an
- **Ordner-Layoutmodi**: wähle zwischen seitenbasierten Ordnern nach Launchpad-Vorbild und vertikal scrollenden Ordnern
- **Core-Animation-Ordnerrendering**: flüssigere Ordnerinteraktion bei größeren Ordnern

### Intelligente Hintergrundinteraktion

- Intelligente Klickerkennung verhindert versehentliches Schließen
- Kontextabhängige Gestenverarbeitung
- Schutz des Suchfelds

### Leistungsoptimierung

- **Icon-Caching**: intelligentes Bild-Caching für flüssiges Scrollen
- **Lazy Loading**: effiziente Speichernutzung
- **Hintergrund-Scanning**: blockierungsfreie App-Erkennung

### Automatisierung und Aktivierung

- **CLI / TUI**: verwalte ZeroLaunch im Terminal mit `zerolaunch`
- **Hot Corner**: öffne ZeroLaunch aus einer konfigurierbaren Bildschirmecke
- **Experimentelle native Gesten**: 4-/5-Finger-Pinch- und Tap-Aktionen, inklusive Auswahl externer Trackpads
- **Dock-Drag**: ziehe Apps direkt in das macOS-Dock in Next Engine + Core Animation

### App-Verwaltung

- **Kontextmenü-Aktionen**: Apps im Finder anzeigen, App-Pfade kopieren, Ordner umbenennen und ein konfiguriertes Deinstallationswerkzeug nutzen

### Update- und Backup-Tools

- **Update-Tab**: prüfe Updates und lies Markdown-Release-Notes direkt in den Einstellungen
- **Backup-Tools**: erstelle und stelle Backups sicherer wieder her
- **Benachrichtigungs-Update**: Unterstützung der modernen Benachrichtigungs-API

### Multi-Monitor-Unterstützung

- Automatische Bildschirmerkennung
- Positionszuordnung pro Bildschirm
- Nahtlose Multi-Monitor-Workflows

## Fehlerbehebung

### Häufige Probleme

**F: Die App startet nicht?**  
A: Stelle sicher, dass macOS 26.0+ installiert ist, und prüfe die Systemberechtigungen. Wenn die App von Gatekeeper blockiert wird, führe `sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app` aus oder klicke mit der rechten Maustaste → Öffnen.

**F: Welche Engine sollte ich verwenden?**  
A: `Next Engine + Core Animation` wird für das beste Erlebnis empfohlen. `Legacy Engine` ist weiterhin verfügbar, falls du den älteren Kompatibilitätspfad brauchst.

**F: Warum existiert der CLI-Befehl noch nicht?**  
A: Aktiviere zuerst die Kommandozeilenschnittstelle in den Einstellungen. ZeroLaunch kann den verwalteten `zerolaunch`-Shim für dich installieren und entfernen.

## Mitwirken

Wir freuen uns über Beiträge! Bitte:

1. Forke das Repository
2. Erstelle einen Feature-Branch (`git checkout -b feature/amazing-feature`)
3. Committe deine Änderungen (`git commit -m 'Add amazing feature'`)
4. Pushe den Branch (`git push origin feature/amazing-feature`)
5. Öffne einen Pull Request

### Entwicklungsrichtlinien

- Folge den Swift-Stilkonventionen
- Füge aussagekräftige Kommentare für komplexe Logik hinzu
- Teste auf mehreren macOS-Versionen
- Erhalte die Rückwärtskompatibilität

## Die Zukunft der App-Verwaltung

Da Apple sich von anpassbaren Oberflächen abwendet, ist ZeroLaunch ein Vorstoß hin zu mehr Benutzerkontrolle und Personalisierung. Ich hoffe weiterhin, dass Apple Launchpad zurückbringt.

**ZeroLaunch** ist nicht nur ein Launchpad-Ersatz — es ist ein Bekenntnis dazu, dass die Wahl des Nutzers zählt.

---

**ZeroLaunch** - Hol dir deinen App-Launcher zurück 🚀

*Für macOS-Nutzer, die bei der Anpassbarkeit keine Kompromisse eingehen.*

## Entwicklungstools

- Claude Code
- Cursor
- OpenAI Codex CLI
- Perplexity
- Google

- Die experimentelle Gestenunterstützung basiert auf [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport) und dem Fork von [KrishKrosh](https://github.com/KrishKrosh/OpenMultitouchSupport).❤️

![GitHub downloads](https://img.shields.io/github/downloads/zerojs/zero-launch/total)
