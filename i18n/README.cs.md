# ZeroLaunch

**Jazyky**: [English](../README.md) | [简体中文](README.zh.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [Tiếng Việt](README.vi.md) | [Italiano](README.it.md) | [Čeština](README.cs.md)

## 📥 Stáhnout

**[Stáhnout zde](https://github.com/zerojs/zero-launch/releases/latest)** - Získejte nejnovější verzi

🌐 **Web**: [www.zerojs.cn](https://www.zerojs.cn/)  
📚 **Dokumentace**: [www.zerojs.cn](https://www.zerojs.cn/)

⭐ Zvažte označení hvězdičkou [ZeroLaunch](https://github.com/zerojs/zero-launch) a zejména [LaunchNow](https://github.com/ggkevinnnn/LaunchNow)!

| | |
|:---:|:---:|
| ![](../public/banner.webp) | ![](../public/setting1.webp) |
| ![](../public/setting2.webp) | ![](../public/setting3.webp) |

macOS Tahoe odstranila Launchpad a náhrada je k ničemu — nedokáže ani využít váš GPU. Apple, dejte prosím lidem alespoň možnost přepnout zpět. Než se tak stane, tady je ZeroLaunch.

*Postaveno na [LaunchNext](https://github.com/RoversX/LaunchNext) od RoversX — obrovské díky původnímu projektu!❤️ LaunchNext je zase založen na [LaunchNow](https://github.com/ggkevinnnn/LaunchNow) od ggkevinnnn.*

*LaunchNow si vybral licenci GPL 3. LaunchNext a ZeroLaunch následují stejné licenční podmínky.*

## ✨ ZeroLaunch Highlights

ZeroLaunch je aktivně vyvíjen na základě LaunchNext. Toto **přidává tento fork** oproti originálu:

- ⚡ **Úprava výkonu na úrovni enginu** — diffování stromu vrstev překresluje pouze změněné ikony místo přestavování 500+ vrstev; procházení stránek je stejné na 60Hz i 120Hz displejích; cache ikon s ohledem na měřítko a s omezenou velikostí; inkrementální ukládání (jedno přetažení = jeden zápis na disk)
- 🗑️ **Režim odinstalace dlouhým stiskem** — režim „třepání" ve stylu iOS s bezpečným přesunem do Koše a víceúrovňovým přístupem k oprávněním (i aplikace App Store vlastněné rootem lze přesunout do Koše)
- 📁 **Otevírání složek při najetí kurzorem** — podržte aplikaci nad složkou a po chvíli se sama rozbalí; přetažením dovnitř ji umístíte přesně tam, kam chcete
- 🧲 **Otáčení stránek u okraje s nápovědou** — přetáhněte aplikace k okraji obrazovky a stránka se otočí s viditelným indikátorem; prázdné stránky se znovu používají, takže se nehromadí nepořádek
- 🎬 **Symetrické animace otevření a zavření** — při otevření se panel smršťuje ke středu, při zavření se rozpíná ven, s nastavitelnou délkou trvání
- 🗂️ **Rozbalování složek ve stylu LaunchOS** — složky rostou z ikony, na kterou jste klikli; přejmenování jedním klikem s adaptivním vstupním polem
- ⚙️ **Zcela přepracované Nastavení** — vyhledávání v nastavení s navigací klávesnicí, obnovení podle oddílů, přepínač rozsahu Celá obrazovka/OKNO a související možnosti seskupené do karet
- 🧹 **Prověřené a vyčištěné možnosti** — odstraněna mrtvá nastavení, sjednocené názvy Celá obrazovka/OKNO, číselný posuvník pro váhu písma, živý údaj o využití paměti a zkratka pro okamžitý restart po změně režimu výkonu
- 🌍 **14 jazyků** — každé nové nastavení je hned lokalizované (en, zh-Hans, zh-Hant, ja, ko, fr, es, de, ru, it, cs, pt-BR, vi, hi)
- 🚢 **Nezávislá distribuce** — vlastní Bundle ID, příkaz `zerolaunch`, vestavěný automatický update a skripty pro vydání
- 🛠️ **Skutečné opravy chyb** — pozadí tapety v macOS 26 (lokální párování okna + záloha na úrovni souboru), ztráta fokusu okna nastavení, příliš malé klikací oblasti u nebezpečných tlačítek a další

## 🚀 Instalace

### Možnost 1 — Stáhnout vydání
1. Získejte `ZeroLaunch<verze>.zip` z [posledního vydání](https://github.com/zerojs/zero-launch/releases/latest)
2. Rozbalte a přetáhněte `ZeroLaunch.app` do složky `/Applications`
3. Spusťte jej — pokud jej macOS zablokuje, viz poznámka níže

### Možnost 2 — Sestavení ze zdroje

Viz [Sestavení ze zdrojového kódu](#sestavení-ze-zdrojového-kódu) níže.

> ⚠️ **Pokud macOS zablokuje aplikaci, spusťte toto v Terminálu:**
```bash
sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app
```
**Proč**: vydání ZeroLaunch jsou aktuálně podepsána ad hoc a dosud nejsou notarizována (bez placeného účtu Apple Developer), takže macOS ve výchozím nastavení blokuje nepodepsané aplikace. Tento příkaz odstraní příznak karantény a umožní spuštění. **Používejte jej pouze u aplikací, kterým důvěřujete.** Můžete také kliknout na aplikaci pravým tlačítkem → **Otevřít** → potvrdit.

**Stav podpisu**: vydání jsou nyní **podepsána ad hoc, nikoli notarizována**. Gatekeeper může při prvním spuštění varovat; viz příkaz výše nebo klikněte pravým tlačítkem → Otevřít. Jakmile v budoucnu přibude placený účet Apple Developer, vydání přejdou na podpis Developer ID a notarizaci. Sestavujete ze zdroje? Viz [Nastavení místního podepisování](#configure-local-code-signing).

### Co ZeroLaunch přináší
- ✅ **Import jedním klikem ze starého systémového Launchpadu** — přímo čte nativní SQLite databázi Launchpadu (`/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`) a přesně obnovuje vaše složky, pozice aplikací a rozložení
- ✅ **Klasický zážitek z Launchpadu** — funguje přesně jako milované původní rozhraní
- ✅ **Vícejazyčná podpora** — plná internacionalizace s angličtinou, zjednodušenou a tradiční čínštinou, japonštinou, francouzštinou, španělštinou, němčinou, ruštinou a dalšími
- ✅ **Skrytí popisků ikon** — čistý minimalistický pohled, když nepotřebujete názvy aplikací
- ✅ **Vlastní velikost ikon** — upravte rozměry ikon podle svých preferencí
- ✅ **Chytrá správa složek** — vytvářejte a organizujte složky jako dřív
- ✅ **Rozmazané vyhledávání a navigace klávesnicí** — najděte aplikace rychle, i při neúplném nebo nepřesném zadání
- ✅ **Podpora CLI / TUI** — kontrolujte a spravujte rozložení z terminálu příkazem `zerolaunch`
- ✅ **Hot Corner a nativní gesta** — otevírejte ZeroLaunch rohy obrazovky, gesty trackpadu a možnostmi pro 4 / 5 prstů
- ✅ **Přetažení aplikací přímo do Docku** — dostupné v Next Engine + Core Animation
- ✅ **Složky Core Animation** — obsah složek podporuje stránkové i svislé posouvání
- ✅ **Lepší kontextová nabídka** — Zobrazit ve Finderu, Kopírovat cestu k aplikaci, Přejmenovat složku a nastavené akce odinstalace
- ✅ **Karta aktualizací s Markdown poznámkami k vydání** — bohatší zážitek z aktualizací v aplikaci
- ✅ **Vylepšení záloh, ovladače a hlasové podpory** — vyšší spolehlivost a dostupnost

### Co macOS Tahoe vzal
- ❌ Žádná vlastní organizace aplikací
- ❌ Žádné uživatelem vytvořené složky
- ❌ Žádné přizpůsobení přetažením
- ❌ Žádná vizuální správa aplikací
- ❌ Vynucené kategoriální seskupení


### Ukládání dat
Data aplikace jsou bezpečně uložena zde:
```
~/Library/Application Support/ZeroLaunch/Data.store
```

### Nativní integrace Launchpadu
Čte přímo ze systémové databáze Launchpadu:
```bash
/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db
```

## Sestavení ze zdrojového kódu

### Požadavky
- macOS 26 (Tahoe) nebo novější
- Procesor Apple Silicon nebo Intel
- Xcode 26 (pro sestavení ze zdrojového kódu)

### Sestavení ze zdrojového kódu

1. **Klonujte repozitář**
   ```bash
   git clone https://github.com/zerojs/zero-launch.git
   cd zero-launch
   ```

2. **Otevřete v Xcode**
   ```bash
   open LaunchNext.xcodeproj
   ```

3. <a name="configure-local-code-signing"></a>**Nastavte místní podepisování kódu**
   - Pro sestavení ani přispívání do ZeroLaunch není potřeba placený účet Apple Developer.
   - Vyberte cíl **LaunchNext**, otevřete **Signing & Capabilities**, nastavte **Team** na svůj tým (stačí bezplatný Personal Team) nebo nastavte **Team** na `None` a jako podpisový certifikát vyberte `Sign to Run Locally`.
   - Ponechte zapnutý Hardened Runtime.
   - Xcode může po změně těchto místních nastavení označit soubor projektu jako upravený. Do pull requestu nezahrnujte změny týkající se pouze podpisu.

4. **Sestavte a spusťte**
   - Chcete-li aplikaci spustit pomocí `⌘+R`, vyberte jako cíl spuštění `My Mac`, nikoli `Any Mac`.
   - `Any Mac (arm64, x86_64)` je určen pro obecné sestavení a archivy; nelze s ním aplikaci spustit pro ladění.
   - Stiskněte `⌘+B`, pokud chcete pouze sestavit.

### Sestavení z příkazové řádky

**Běžné sestavení:**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release
```

**Univerzální binárka (Intel + Apple Silicon):**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO clean build
```

**Vydavatelský balíček (zip + kontrolní součty, podepsáno ad hoc):**
```bash
./scripts/release.sh
```

## Použití

### Začínáme
1. **První spuštění**: ZeroLaunch automaticky naskenuje všechny nainstalované aplikace
2. **Výběr**: kliknutím aplikaci vyberete, dvojklikem spustíte
3. **Hledání**: začněte psát a aplikace se okamžitě filtrují
4. **Organizace**: přetahujte aplikace a vytvářejte složky a vlastní rozložení
5. **Automatizace**: v Nastavení povolte CLI, pokud chcete pracovat z terminálu

### Import vašeho Launchpadu
1. Otevřete Nastavení (ozubené kolečko)
2. Klikněte na **„Import Launchpad"**
3. Stávající rozložení a složky se automaticky importují


### Režimy zobrazení
- **OKNO**: plovoucí okno se zaoblenými rohy
- **Celá obrazovka**: režim přes celou obrazovku pro maximální přehlednost
- **Legacy Engine** a **Next Engine + Core Animation** jsou dostupné v Nastavení
- ZeroLaunch může pro režim celé obrazovky a okna uchovávat samostatná nastavení
- Volitelné skrytí lišty nabídek v režimu celé obrazovky; při zapnutí macOS skryje i Dock

## Pokročilé funkce

### Hledání a práce se složkami
- **Rozmazané hledání**: najděte aplikace podle částečných názvů, zkratek i nepřesného zadání
- **Nastavitelné zpoždění hledání**: upravte prodlevu (debounce) hledání v Nastavení
- **Režimy rozložení složek**: vyberte mezi stránkovanými složkami ve stylu Launchpadu a složkami se svislým posouváním
- **Vykreslování složek Core Animation**: plynulejší práce s velkými složkami

### Chytrá práce s pozadím
- Inteligentní detekce kliknutí zabraňuje náhodnému zavření
- Kontextové zpracování gest
- Ochrana vyhledávacího pole

### Optimalizace výkonu
- **Cache ikon**: inteligentní ukládání obrázků pro plynulé posouvání
- **Líné načítání**: efektivní využití paměti
- **Skenování na pozadí**: vyhledávání aplikací bez blokování

### Automatizace a aktivace
- **CLI / TUI**: spravujte ZeroLaunch z terminálu příkazem `zerolaunch`
- **Hot Corner**: otevírejte ZeroLaunch z nastavitelného rohu obrazovky
- **Experimentální nativní gesta**: akce sevření (pinch) a klepnutí (tap) 4 / 5 prsty, včetně výběru externího trackpadu
- **Přetažení do Docku**: přetahujte aplikace přímo do macOS Docku v Next Engine + Core Animation

### Správa aplikací
- **Akce v kontextové nabídce**: zobrazit aplikace ve Finderu, kopírovat cesty, přejmenovat složky a použít nastavený nástroj pro odinstalaci

### Aktualizace a zálohy
- **Karta aktualizací**: kontrolujte aktualizace a čtěte Markdown poznámky k vydání v Nastavení
- **Nástroje pro zálohy**: vytvářejte a obnovujte zálohy bezpečněji
- **Oznámení**: podpora moderního API oznámení

### Podpora více displejů
- Automatická detekce obrazovek
- Umístění podle jednotlivých displejů
- Bezproblémová práce s více monitory

## Řešení problémů

### Běžné problémy

**Q: Aplikace se nespustí?**  
A: Ujistěte se, že máte macOS 26.0 nebo novější, a zkontrolujte systémová oprávnění. Pokud aplikaci zablokuje Gatekeeper, spusťte `sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app` nebo klikněte pravým tlačítkem → Otevřít.

**Q: Který engine mám použít?**  
A: `Next Engine + Core Animation` je doporučený pro nejlepší zážitek. `Legacy Engine` zůstává dostupný, pokud potřebujete starou cestu kompatibility.

**Q: Proč příkaz CLI ještě neexistuje?**  
A: Nejdříve povolte rozhraní příkazové řádky v Nastavení. ZeroLaunch za vás může nainstalovat i odebrat spravovaný příkaz `zerolaunch`.

## Přispívání

Příspěvky jsou vítány! Postupujte prosím takto:

1. Forkněte repozitář
2. Vytvořte feature branch (`git checkout -b feature/amazing-feature`)
3. Commitněte změny (`git commit -m 'Add amazing feature'`)
4. Pushněte branch (`git push origin feature/amazing-feature`)
5. Otevřete Pull Request

### Pokyny pro vývoj
- Dodržujte konvence stylu Swift
- Přidávejte smysluplné komentáře ke složité logice
- Testujte na více verzích macOS
- Zachovávejte zpětnou kompatibilitu

## Budoucnost správy aplikací

Jak se Apple vzdaluje od přizpůsobitelných rozhraní, ZeroLaunch představuje snahu o větší kontrolu a personalizaci ze strany uživatele. Stále doufám, že Apple Launchpad vrátí.

**ZeroLaunch** není jen náhrada Launchpadu — je to prohlášení, že na volbě uživatele záleží.


---

**ZeroLaunch** - Získejte zpět kontrolu nad svým spouštěčem aplikací 🚀

*Pro uživatele macOS, kteří nechtějí dělat kompromisy v přizpůsobení.*

## Vývojové nástroje

- Claude Code 
- Cursor 
- OpenAI Codex CLI
- Perplexity
- Google



- Experimentální podpora gest je postavená na [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport) a forku od [KrishKrosh](https://github.com/KrishKrosh/OpenMultitouchSupport).❤️


![GitHub downloads](https://img.shields.io/github/downloads/zerojs/zero-launch/total)
