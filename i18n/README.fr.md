# ZeroLaunch

**Langues**: [English](../README.md) | [简体中文](README.zh.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [Tiếng Việt](README.vi.md) | [Italiano](README.it.md) | [Čeština](README.cs.md)

## 📥 Télécharger

**[Télécharger ici](https://github.com/zerojs/zero-launch/releases/latest)** - Obtenez la dernière version

🌐 **Site web**: [www.zerojs.cn](https://www.zerojs.cn/)  
📚 **Documentation**: [www.zerojs.cn](https://www.zerojs.cn/)

⭐ Pensez à donner une étoile à [ZeroLaunch](https://github.com/zerojs/zero-launch) et au projet original [LaunchNow](https://github.com/ggkevinnnn/LaunchNow) !

| | |
|:---:|:---:|
| ![](../public/banner.webp) | ![](../public/setting1.webp) |
| ![](../public/setting2.webp) | ![](../public/setting3.webp) |

macOS Tahoe a supprimé le Launchpad, et la nouvelle interface est difficile à utiliser, elle n'utilise pas pleinement votre GPU. Apple, donnez au moins aux utilisateurs une option pour revenir en arrière. En attendant, voici ZeroLaunch.

*Construit sur [LaunchNext](https://github.com/RoversX/LaunchNext) par RoversX — un immense merci au projet original !❤️ LaunchNext est lui-même basé sur [LaunchNow](https://github.com/ggkevinnnn/LaunchNow) par ggkevinnnn.*

*LaunchNow a choisi la licence GPL 3. LaunchNext et ZeroLaunch suivent les mêmes conditions de licence.*

## ✨ Points forts de ZeroLaunch

ZeroLaunch est développé activement sur la base de LaunchNext. Voici ce que **ce fork apporte** par rapport au projet d'origine :

- ⚡ **Refonte des performances au niveau du moteur** — la comparaison différentielle de l'arbre de calques ne redessine que les icônes modifiées au lieu de reconstruire 500+ calques ; le défilement entre pages est identique sur écrans 60 Hz et 120 Hz ; mise en cache des icônes adaptée à l'échelle avec un cache de taille limitée ; persistance incrémentale (un glisser = une écriture sur disque)
- 🗑️ **Mode désinstallation par appui long** — mode « tremblement » façon iOS avec une mise à la Corbeille sûre et des replis sur plusieurs niveaux d'autorisations (même les apps du App Store appartenant à root peuvent être mises à la Corbeille)
- 📁 **Dossiers s'ouvrant au survol** — maintenez une app au-dessus d'un dossier, il s'ouvre automatiquement après un court instant ; déposez-la à l'intérieur pour placer l'app exactement où vous voulez
- 🧲 **Changement de page par le bord avec repères visuels** — glissez les apps vers le bord de l'écran pour changer de page avec une barre d'indication visuelle ; les pages vides sont recyclées pour que le désordre ne s'accumule jamais
- 🎬 **Animations symétriques d'ouverture/fermeture** — le panneau se zoom vers le centre à l'ouverture et s'étend vers l'extérieur à la fermeture, avec une durée configurable
- 🗂️ **Dépliage de dossiers façon LaunchOS** — les dossiers grandissent à partir de l'icône sur laquelle vous avez cliqué ; renommage en un clic avec un champ de saisie adaptatif
- ⚙️ **Réglages entièrement reconstruits** — recherche intégrée aux réglages avec navigation clavier, réinitialisation par section, sélecteur de portée Plein écran/Fenêtre et options liées regroupées en cartes
- 🧹 **Options auditées et simplifiées** — suppression des réglages inutiles, uniformisation de la dénomination Plein écran/Fenêtre, curseur numérique de graisse de police, affichage en direct de l'utilisation mémoire et raccourci de redémarrage immédiat après changement de mode de performance
- 🌍 **14 langues** — chaque nouveau réglage est livré localisé (en, zh-Hans, zh-Hant, ja, ko, fr, es, de, ru, it, cs, pt-BR, vi, hi)
- 🚢 **Distribution indépendante** — propre Bundle ID, CLI `zerolaunch`, mise à jour intégrée et scripts de publication
- 🛠️ **Vrais correctifs de bugs** — fond d'écran macOS 26 (recherche de fenêtre localisée + repli au niveau fichier), perte de focus de la feuille de réglages, zones cliquables trop petites sur les boutons destructifs, et plus encore

## 🚀 Installation

### Option 1 — Télécharger la version

1. Récupérez `ZeroLaunch<version>.zip` dans la [dernière version](https://github.com/zerojs/zero-launch/releases/latest)
2. Décompressez et glissez `ZeroLaunch.app` dans `/Applications`
3. Lancez l'application — si macOS la bloque, voir la note ci-dessous

### Option 2 — Compiler depuis les sources

Voir [Compilation depuis les sources](#compilation-depuis-les-sources) ci-dessous.

> ⚠️ **Si macOS bloque l'application, exécutez ceci dans le Terminal :**
```bash
sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app
```
**Pourquoi** : les versions de ZeroLaunch sont signées ad-hoc et ne sont pas encore notariées (pas d'abonnement Apple Developer payant), donc macOS bloque les applications non signées par défaut. Cette commande supprime le flag de quarantaine pour permettre l'exécution. **Utilisez cette commande uniquement pour des applications de confiance.** Vous pouvez aussi faire un clic droit sur l'app → **Ouvrir** → confirmer.

**État de la signature de code** : les versions sont actuellement **signées ad-hoc, non notariées**. Gatekeeper peut afficher un avertissement au premier lancement ; voir la commande ci-dessus ou utiliser le clic droit → Ouvrir. Lorsqu'un abonnement Apple Developer payant sera ajouté, les versions passeront à la signature Developer ID + notarisation. Vous compilez depuis les sources ? Voir [Configurer la signature de code locale](#configure-local-code-signing).

### Ce que ZeroLaunch apporte

- ✅ **Import en un clic depuis l'ancien Launchpad système** - lit directement la base SQLite native de Launchpad (`/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`) pour recréer parfaitement vos dossiers, positions d'apps et disposition existants
- ✅ **Expérience Launchpad classique** - fonctionne exactement comme l'interface originale tant appréciée
- ✅ **Support multilingue** - internationalisation complète en anglais, chinois simplifié, chinois traditionnel, japonais, français, espagnol, allemand, russe, et plus encore
- ✅ **Masquer les libellés d'icônes** - vue propre et minimaliste quand vous n'avez pas besoin des noms d'apps
- ✅ **Tailles d'icônes personnalisées** - ajustez les dimensions des icônes selon vos préférences
- ✅ **Gestion intelligente des dossiers** - créez et organisez des dossiers comme avant
- ✅ **Recherche floue et navigation clavier** - trouvez des apps rapidement, même avec une saisie partielle ou imparfaite
- ✅ **Support CLI / TUI** - inspectez et pilotez votre disposition depuis le terminal avec la commande `zerolaunch`
- ✅ **Hot Corner et gestes natifs** - ouvrez ZeroLaunch avec les coins, les gestes du trackpad et des options à 4 / 5 doigts
- ✅ **Glisser des apps directement vers le Dock** - disponible dans Next Engine + Core Animation
- ✅ **Dossiers Core Animation** - le contenu des dossiers prend en charge les dispositions paginées et à défilement vertical
- ✅ **Meilleurs menus contextuels** - Afficher dans le Finder, Copier le chemin de l'app, Renommer le dossier et actions de désinstallation configurées
- ✅ **Onglet de mise à jour avec release notes Markdown** - expérience de mise à jour intégrée plus riche
- ✅ **Améliorations de la sauvegarde, des manettes et du support vocal** - meilleure fiabilité et accessibilité

### Ce que macOS Tahoe a retiré

- ❌ Pas d'organisation personnalisée des applications
- ❌ Pas de dossiers créés par l'utilisateur
- ❌ Pas de personnalisation par glisser-déposer
- ❌ Pas de gestion visuelle des applications
- ❌ Regroupement catégoriel forcé

### Stockage des données

Les données de l'application sont stockées ici :

```text
~/Library/Application Support/ZeroLaunch/Data.store
```

### Intégration native avec Launchpad

ZeroLaunch peut lire directement la base Launchpad du système :

```bash
/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db
```

## Compilation depuis les sources

### Configuration requise

- macOS 26 (Tahoe) ou version ultérieure
- Processeur Apple Silicon ou Intel
- Xcode 26 (pour compiler depuis les sources)

### Compiler depuis les sources

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/zerojs/zero-launch.git
   cd zero-launch
   ```

2. **Ouvrir dans Xcode**
   ```bash
   open LaunchNext.xcodeproj
   ```

3. <a name="configure-local-code-signing"></a>**Configurer la signature de code locale**
   - Un compte Apple Developer payant n'est pas nécessaire pour compiler ZeroLaunch ou y contribuer.
   - Sélectionnez la cible **LaunchNext**, ouvrez **Signing & Capabilities**, définissez **Team** sur votre propre équipe (une Personal Team gratuite convient), ou définissez **Team** sur `None` et sélectionnez `Sign to Run Locally` comme certificat de signature.
   - Gardez Hardened Runtime activé.
   - Xcode peut marquer le fichier projet comme modifié après ces réglages locaux. N'incluez pas les modifications liées uniquement à la signature dans une pull request.

4. **Compiler et exécuter**
   - Pour lancer l'app avec `⌘+R`, sélectionnez `My Mac` comme destination d'exécution — pas `Any Mac`.
   - `Any Mac (arm64, x86_64)` est destiné aux builds et archives génériques ; il ne peut pas lancer l'app pour le débogage.
   - Appuyez sur `⌘+B` si vous voulez seulement compiler.

### Compilation en ligne de commande

**Compilation standard :**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release
```

**Binaire universel (Intel + Apple Silicon) :**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO clean build
```

**Paquet de release (zip + sommes de contrôle, signé ad-hoc) :**
```bash
./scripts/release.sh
```

## Utilisation

### Premiers pas

1. **Premier lancement** : ZeroLaunch analyse automatiquement toutes les applications installées
2. **Sélection** : cliquez pour sélectionner des apps, double-cliquez pour lancer
3. **Recherche** : saisissez du texte pour filtrer instantanément les applications
4. **Organisation** : glissez les apps pour créer des dossiers et des dispositions personnalisées
5. **Automatisation** : activez le CLI dans les Réglages si vous voulez des flux de travail en terminal

### Importer votre Launchpad

1. Ouvrez les Réglages (icône d'engrenage)
2. Cliquez sur **« Import Launchpad »**
3. Votre disposition et vos dossiers existants sont importés automatiquement

### Modes d'affichage

- **Fenêtre** : fenêtre flottante avec coins arrondis
- **Plein écran** : mode plein écran pour une visibilité maximale
- **Legacy Engine** et **Next Engine + Core Animation** sont disponibles dans les Réglages
- ZeroLaunch peut conserver des réglages séparés pour le mode plein écran et le mode fenêtre
- Masquage optionnel de la barre de menus en plein écran ; macOS masque également le Dock lorsque cette option est activée

## Fonctionnalités avancées

### Expérience de recherche et de dossiers

- **Recherche floue** : trouvez des apps avec des noms partiels, des abréviations et une saisie imparfaite
- **Délai de recherche configurable** : ajustez le délai de debounce de la recherche dans les Réglages
- **Modes de disposition des dossiers** : choisissez entre des dossiers paginés façon Launchpad et des dossiers à défilement vertical
- **Rendu des dossiers en Core Animation** : interactions plus fluides pour les grands dossiers

### Interaction intelligente avec l'arrière-plan

- Détection intelligente des clics pour éviter les fermetures accidentelles
- Gestion des gestes selon le contexte
- Protection du champ de recherche

### Optimisation des performances

- **Mise en cache des icônes** : mise en cache intelligente des images pour un défilement fluide
- **Chargement paresseux** : utilisation mémoire efficace
- **Analyse en arrière-plan** : découverte des applications sans blocage

### Automatisation et activation

- **CLI / TUI** : gérez ZeroLaunch depuis le terminal avec `zerolaunch`
- **Hot Corner** : ouvrez ZeroLaunch depuis un coin d'écran configurable
- **Gestes natifs expérimentaux** : actions de pinch et tap à 4 / 5 doigts, avec sélection d'un trackpad externe
- **Glisser vers le Dock** : glissez les apps directement dans le Dock macOS dans Next Engine + Core Animation

### Gestion des applications

- **Actions du menu contextuel** : afficher les apps dans le Finder, copier les chemins d'apps, renommer des dossiers et utiliser un outil de désinstallation configuré

### Outils de mise à jour et de sauvegarde

- **Onglet de mise à jour** : vérifiez les mises à jour et lisez les release notes Markdown dans les Réglages
- **Outils de sauvegarde** : créez et restaurez des sauvegardes en toute sécurité
- **Mise à jour des notifications** : prise en charge de l'API de notifications moderne

### Prise en charge de plusieurs écrans

- Détection automatique des écrans
- Positionnement par écran
- Flux de travail fluides sur plusieurs moniteurs

## Dépannage

### Problèmes courants

**Q : L'application ne démarre pas ?**  
R : Vérifiez macOS 26.0+ et les permissions système. Si l'app est bloquée par Gatekeeper, exécutez `sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app` ou faites un clic droit → Ouvrir.

**Q : Quel moteur utiliser ?**  
R : `Next Engine + Core Animation` est recommandé pour la meilleure expérience. `Legacy Engine` reste disponible si vous avez besoin de l'ancien chemin de compatibilité.

**Q : Pourquoi la commande CLI n'existe pas encore ?**  
R : Activez d'abord l'interface en ligne de commande dans les Réglages. ZeroLaunch peut installer et supprimer pour vous la commande gérée `zerolaunch`.

## Contribution

Nous accueillons les contributions ! Merci de :

1. Forker le dépôt
2. Créer une branche de fonctionnalité (`git checkout -b feature/amazing-feature`)
3. Commettre vos changements (`git commit -m 'Add amazing feature'`)
4. Pousser la branche (`git push origin feature/amazing-feature`)
5. Ouvrir une Pull Request

### Directives de développement

- Suivez les conventions de style Swift
- Ajoutez des commentaires utiles pour la logique complexe
- Testez sur plusieurs versions de macOS
- Maintenez la rétrocompatibilité

## L'avenir de la gestion d'applications

Alors qu'Apple s'éloigne des interfaces personnalisables, ZeroLaunch représente une volonté de rendre le contrôle et la personnalisation aux utilisateurs. J'espère toujours qu'Apple ramènera Launchpad.

**ZeroLaunch** n'est pas seulement un remplaçant de Launchpad — c'est une affirmation que le choix de l'utilisateur compte.

---

**ZeroLaunch** - Reprenez votre lanceur d'apps en main 🚀

*Conçu pour les utilisateurs macOS qui refusent de faire des compromis sur la personnalisation.*

## Outils de développement

- Claude Code
- Cursor
- OpenAI Codex CLI
- Perplexity
- Google

- Le support expérimental des gestes est construit sur [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport) et le fork de [KrishKrosh](https://github.com/KrishKrosh/OpenMultitouchSupport).❤️

![GitHub downloads](https://img.shields.io/github/downloads/zerojs/zero-launch/total)
