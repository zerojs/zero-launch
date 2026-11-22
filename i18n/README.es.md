# ZeroLaunch

**Idiomas**: [English](../README.md) | [简体中文](README.zh.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [Tiếng Việt](README.vi.md) | [Italiano](README.it.md) | [Čeština](README.cs.md)

## 📥 Descargar

**[Descargar aquí](https://github.com/zerojs/zero-launch/releases/latest)** - Obtén la última versión

🌐 **Sitio web**: [www.zerojs.cn](https://www.zerojs.cn/)  
📚 **Documentación**: [www.zerojs.cn](https://www.zerojs.cn/)

⭐ ¡Considera dar una estrella a [ZeroLaunch](https://github.com/zerojs/zero-launch) y especialmente al proyecto original [LaunchNow](https://github.com/ggkevinnnn/LaunchNow)!

| | |
|:---:|:---:|
| ![](../public/banner.webp) | ![](../public/setting1.webp) |
| ![](../public/setting2.webp) | ![](../public/setting3.webp) |

macOS Tahoe eliminó el Launchpad, y la nueva interfaz es difícil de usar, no aprovecha completamente tu GPU. Apple, al menos da a los usuarios una opción para volver atrás. Mientras tanto, aquí está ZeroLaunch.

*Construido sobre [LaunchNext](https://github.com/RoversX/LaunchNext) de RoversX — ¡muchísimas gracias al proyecto original!❤️ LaunchNext está a su vez basado en [LaunchNow](https://github.com/ggkevinnnn/LaunchNow) de ggkevinnnn.*

*LaunchNow ha elegido la licencia GPL 3. LaunchNext y ZeroLaunch siguen los mismos términos de licencia.*

## ✨ Aspectos destacados de ZeroLaunch

ZeroLaunch se desarrolla activamente sobre la base de LaunchNext. Esto es lo que **añade este fork** respecto al proyecto original:

- ⚡ **Rediseño del rendimiento a nivel de motor** — la comparación diferencial del árbol de capas vuelve a dibujar solo los iconos que cambiaron en lugar de reconstruir más de 500 capas; el desplazamiento entre páginas se siente idéntico en pantallas de 60 Hz y 120 Hz; caché de iconos sensible a la escala con un límite; persistencia incremental (un arrastre = una escritura en disco)
- 🗑️ **Modo de desinstalación por pulsación larga** — modo « tambaleo » estilo iOS con un flujo seguro a la Papelera y respaldos de permisos en varios niveles (incluso las apps de la App Store propiedad de root se pueden enviar a la Papelera)
- 📁 **Carpetas que se abren al pasar el cursor** — mantén una app sobre una carpeta y se expande automáticamente tras un momento; suelta dentro para colocar la app exactamente donde quieras
- 🧲 **Cambio de página por el borde con indicadores visuales** — arrastra apps al borde de la pantalla para cambiar de página con una barra de indicación visual; las páginas vacías se reciclan para que nunca se acumule el desorden
- 🎬 **Animaciones simétricas de apertura/cierre** — el panel se acerca al centro al abrirse y se expande hacia afuera al cerrarse, con una duración configurable
- 🗂️ **Expansión de carpetas estilo LaunchOS** — las carpetas crecen desde el icono en el que hiciste clic; renombrado con un clic mediante un campo de entrada adaptable
- ⚙️ **Ajustes completamente reconstruidos** — búsqueda dentro de los ajustes con navegación por teclado, restablecimiento por sección, conmutador de ámbito Pantalla completa/Ventana y opciones relacionadas agrupadas en tarjetas
- 🧹 **Opciones auditadas y depuradas** — se eliminaron ajustes obsoletos, se unificó la denominación Pantalla completa/Ventana, deslizador numérico de peso de fuente, lectura en vivo del uso de memoria y atajo de reinicio inmediato tras cambiar el modo de rendimiento
- 🌍 **14 idiomas** — cada nuevo ajuste se entrega localizado (en, zh-Hans, zh-Hant, ja, ko, fr, es, de, ru, it, cs, pt-BR, vi, hi)
- 🚢 **Distribución independiente** — propio Bundle ID, CLI `zerolaunch`, actualizador integrado y scripts de lanzamiento
- 🛠️ **Correcciones de errores reales** — fondo de pantalla de macOS 26 (búsqueda de ventana localizada + respaldo a nivel de archivo), pérdida de foco de la hoja de ajustes, áreas de clic demasiado pequeñas en botones destructivos y más

## 🚀 Instalación

### Opción 1 — Descargar la versión

1. Descarga `ZeroLaunch<versión>.zip` de la [última versión](https://github.com/zerojs/zero-launch/releases/latest)
2. Descomprime y arrastra `ZeroLaunch.app` a `/Applications`
3. Ábrela — si macOS la bloquea, consulta la nota siguiente

### Opción 2 — Compilar desde el código fuente

Consulta [Compilación desde el código fuente](#compilación-desde-el-código-fuente) más abajo.

> ⚠️ **Si macOS bloquea la aplicación, ejecuta esto en Terminal:**
```bash
sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app
```
**Por qué**: las versiones de ZeroLaunch están firmadas ad-hoc y aún no notarizadas (no hay suscripción de pago a Apple Developer), por lo que macOS bloquea las apps sin firmar por defecto. Este comando elimina la bandera de cuarentena para permitir su ejecución. **Usa este comando solo en aplicaciones de confianza.** También puedes hacer clic derecho → **Abrir** → confirmar.

**Estado de la firma de código**: las versiones están actualmente **firmadas ad-hoc, sin notarizar**. Gatekeeper puede advertir en el primer inicio; consulta el comando anterior o usa clic derecho → Abrir. Cuando se añada una suscripción de pago a Apple Developer, las versiones pasarán a la firma Developer ID + notarización. ¿Compilas desde el código fuente? Consulta [Configurar la firma de código local](#configure-local-code-signing).

### Lo que ofrece ZeroLaunch

- ✅ **Importación con un clic desde el Launchpad del sistema antiguo** - lee directamente la base de datos SQLite nativa de Launchpad (`/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`) para recrear a la perfección tus carpetas, posiciones de apps y diseño existentes
- ✅ **Experiencia clásica de Launchpad** - funciona exactamente como la querida interfaz original
- ✅ **Soporte multilingüe** - internacionalización completa en inglés, chino simplificado, chino tradicional, japonés, francés, español, alemán, ruso y más
- ✅ **Ocultar etiquetas de iconos** - vista limpia y minimalista cuando no necesitas los nombres de las apps
- ✅ **Tamaños de iconos personalizados** - ajusta las dimensiones de los iconos a tus preferencias
- ✅ **Gestión inteligente de carpetas** - crea y organiza carpetas como siempre
- ✅ **Búsqueda difusa y navegación por teclado** - encuentra apps rápidamente, incluso con entradas parciales o imperfectas
- ✅ **Soporte CLI / TUI** - inspecciona y opera tu diseño desde la terminal con el comando `zerolaunch`
- ✅ **Hot Corner y gestos nativos** - abre ZeroLaunch con esquinas, gestos del trackpad y opciones de 4 / 5 dedos
- ✅ **Arrastra apps directamente al Dock** - disponible en Next Engine + Core Animation
- ✅ **Carpetas Core Animation** - el contenido de las carpetas admite diseños paginados y de desplazamiento vertical
- ✅ **Mejores menús contextuales** - Mostrar en Finder, Copiar ruta de la app, Renombrar carpeta y acciones de desinstalación configuradas
- ✅ **Pestaña de actualizaciones con notas en Markdown** - experiencia de actualización integrada más rica
- ✅ **Mejoras en copia de seguridad, controladores y voz** - mayor fiabilidad y accesibilidad

### Lo que macOS Tahoe nos quitó

- ❌ Sin organización personalizada de aplicaciones
- ❌ Sin carpetas creadas por el usuario
- ❌ Sin personalización por arrastrar y soltar
- ❌ Sin gestión visual de aplicaciones
- ❌ Agrupación categórica forzada

### Almacenamiento de datos

Los datos de la aplicación se almacenan en:

```text
~/Library/Application Support/ZeroLaunch/Data.store
```

### Integración nativa con Launchpad

ZeroLaunch puede leer directamente la base de datos del sistema Launchpad:

```bash
/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db
```

## Compilación desde el código fuente

### Requisitos

- macOS 26 (Tahoe) o posterior
- Procesador Apple Silicon o Intel
- Xcode 26 (para compilar desde el código fuente)

### Compilar desde el código fuente

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/zerojs/zero-launch.git
   cd zero-launch
   ```

2. **Abrir en Xcode**
   ```bash
   open LaunchNext.xcodeproj
   ```

3. <a name="configure-local-code-signing"></a>**Configurar la firma de código local**
   - No se necesita una suscripción de pago a Apple Developer para compilar ZeroLaunch ni para contribuir.
   - Selecciona el **destino LaunchNext**, abre **Signing & Capabilities**, ajusta **Team** a tu propio equipo (un Personal Team gratuito sirve), o ajusta **Team** a `None` y selecciona `Sign to Run Locally` como certificado de firma.
   - Mantén Hardened Runtime activado.
   - Xcode puede marcar el archivo del proyecto como modificado tras cambiar estos ajustes locales. No incluyas cambios relativos solo a la firma en un pull request.

4. **Compilar y ejecutar**
   - Para lanzar la app con `⌘+R`, selecciona `My Mac` como destino de ejecución, no `Any Mac`.
   - `Any Mac (arm64, x86_64)` está pensado para compilaciones y archivos genéricos; no puede iniciar la app para depuración.
   - Pulsa `⌘+B` si solo quieres compilar.

### Compilación por línea de comandos

**Compilación normal:**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release
```

**Binario universal (Intel + Apple Silicon):**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO clean build
```

**Paquete de lanzamiento (zip + sumas de verificación, firmado ad-hoc):**
```bash
./scripts/release.sh
```

## Uso

### Primeros pasos

1. **Primer inicio**: ZeroLaunch analiza automáticamente todas las aplicaciones instaladas
2. **Seleccionar**: haz clic para seleccionar apps, doble clic para abrirlas
3. **Buscar**: escribe para filtrar aplicaciones al instante
4. **Organizar**: arrastra apps para crear carpetas y diseños personalizados
5. **Automatizar**: activa la CLI en Ajustes si quieres flujos de trabajo desde la terminal

### Importar tu Launchpad

1. Abre Ajustes (icono de engranaje)
2. Haz clic en **« Import Launchpad »**
3. Tu diseño y tus carpetas existentes se importan automáticamente

### Modos de visualización

- **Ventana**: ventana flotante con esquinas redondeadas
- **Pantalla completa**: modo a pantalla completa para máxima visibilidad
- **Legacy Engine** y **Next Engine + Core Animation** están disponibles en Ajustes
- ZeroLaunch puede guardar ajustes separados para los modos pantalla completa y ventana
- Opcionalmente se puede ocultar la barra de menús en pantalla completa; macOS también oculta el Dock cuando esta opción está activada

## Funciones avanzadas

### Experiencia de búsqueda y carpetas

- **Búsqueda difusa**: encuentra apps con nombres parciales, abreviaturas y entradas imperfectas
- **Retardo de búsqueda configurable**: ajusta el tiempo de debounce de la búsqueda en Ajustes
- **Modos de diseño de carpetas**: elige entre carpetas paginadas estilo Launchpad y carpetas de desplazamiento vertical
- **Renderizado de carpetas con Core Animation**: interacción más fluida con carpetas grandes

### Interacción inteligente con el fondo

- Detección inteligente de clics que evita cierres accidentales
- Gestión de gestos según el contexto
- Protección del campo de búsqueda

### Optimización del rendimiento

- **Caché de iconos**: caché inteligente de imágenes para un desplazamiento fluido
- **Carga diferida**: uso eficiente de la memoria
- **Escaneo en segundo plano**: detección de aplicaciones sin bloqueos

### Automatización y activación

- **CLI / TUI**: gestiona ZeroLaunch desde la terminal con `zerolaunch`
- **Hot Corner**: abre ZeroLaunch desde una esquina configurable de la pantalla
- **Gestos nativos experimentales**: acciones de pinch y tap con 4 / 5 dedos, incluida la selección de trackpads externos
- **Arrastrar al Dock**: arrastra apps directamente al Dock de macOS en Next Engine + Core Animation

### Gestión de aplicaciones

- **Acciones del menú contextual**: mostrar apps en Finder, copiar rutas de apps, renombrar carpetas y usar una herramienta de desinstalación configurada

### Herramientas de actualización y copia de seguridad

- **Pestaña de actualizaciones**: comprueba actualizaciones y lee notas en Markdown dentro de Ajustes
- **Herramientas de copia de seguridad**: crea y restaura copias de forma más segura
- **Actualización de notificaciones**: compatibilidad con la API moderna de notificaciones

### Compatibilidad con varios monitores

- Detección automática de pantallas
- Posicionamiento por pantalla
- Flujos de trabajo fluidos entre monitores

## Solución de problemas

### Problemas comunes

**Q: ¿La app no se inicia?**  
A: Confirma que usas macOS 26.0+ y revisa los permisos del sistema. Si Gatekeeper bloquea la app, ejecuta `sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app` o haz clic derecho → Abrir.

**Q: ¿Qué motor debo usar?**  
A: `Next Engine + Core Animation` es el recomendado para la mejor experiencia. `Legacy Engine` sigue disponible si necesitas la ruta de compatibilidad antigua.

**Q: ¿Por qué aún no existe el comando CLI?**  
A: Primero activa la interfaz de línea de comandos en Ajustes. ZeroLaunch puede instalar y eliminar por ti el comando gestionado `zerolaunch`.

## Contribución

¡Las contribuciones son bienvenidas! Por favor:

1. Haz un fork del repositorio
2. Crea una rama de funcionalidad (`git checkout -b feature/amazing-feature`)
3. Haz commit de tus cambios (`git commit -m 'Add amazing feature'`)
4. Sube la rama (`git push origin feature/amazing-feature`)
5. Abre un Pull Request

### Directrices de desarrollo

- Sigue las convenciones de estilo de Swift
- Añade comentarios útiles para la lógica compleja
- Prueba en varias versiones de macOS
- Mantén la retrocompatibilidad

## El futuro de la gestión de apps

A medida que Apple se aleja de las interfaces personalizables, ZeroLaunch representa un impulso hacia el control del usuario y la personalización. Sigo esperando que Apple recupere Launchpad.

**ZeroLaunch** no es solo un reemplazo de Launchpad: es una declaración de que la elección del usuario importa.

---

**ZeroLaunch** - Recupera el control de tu lanzador de apps 🚀

*Hecho para usuarios de macOS que no quieren renunciar a la personalización.*

## Herramientas de desarrollo

- Claude Code
- Cursor
- OpenAI Codex CLI
- Perplexity
- Google

- El soporte experimental de gestos está construido sobre [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport) y el fork de [KrishKrosh](https://github.com/KrishKrosh/OpenMultitouchSupport).❤️

![GitHub downloads](https://img.shields.io/github/downloads/zerojs/zero-launch/total)
