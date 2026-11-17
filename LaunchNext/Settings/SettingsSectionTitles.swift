import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    var titlesSection: some View {
        LazyVStack(alignment: .leading, spacing: 16){
            HStack {
                Button {
                    presentCustomTitlePicker()
                } label: {
                    Label(appStore.localized(.customTitleAddFromFolder), systemImage: "plus")
                }
                Spacer()
            }

            Text(appStore.localized(.customTitleHint))
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            HStack(){
                Text(appStore.localized(.customTitleOnly))
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Toggle("", isOn: $showOnlyEditedTittleApps)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .disabled(appStore.customTitles.isEmpty)
                    .onChange(of: appStore.customTitles.isEmpty, initial: true) { _, isEmply in
                        if isEmply {
                            showOnlyEditedTittleApps = false
                        }
                    }
            }

            if hasAllAppEntries{
                TextField("", text: $allAppsSearch, prompt: Text(appStore.localized(.renameSearchPlaceholder)))
                    .textFieldStyle(.roundedBorder)
                    .padding(3)
                
                if hasAllAppEntriesSearchResult{
                    let visibleEntries: [AppEntry] = showOnlyEditedTittleApps
                        ? cachedAllAppEntries
                        : Array(cachedAllAppEntries.prefix(allAppsVisibleLimit))
                    LazyVStack(spacing: 12) {
                        ForEach(visibleEntries){ entry in
                            customTitleRow(for: entry)
                        }
                        if !showOnlyEditedTittleApps && cachedAllAppEntries.count > allAppsVisibleLimit {
                            Button(appStore.localized(.loadMore)) {
                                allAppsVisibleLimit = min(allAppsVisibleLimit + listPageSize,
                                                          cachedAllAppEntries.count)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                } else {
                    Text(appStore.localized(.customTitleNoResults))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
                }
            }
        }
        .onAppear(perform: updateCachedAllAppEntries)
        .onChange(of: allAppsSearch, initial: false) { _, _ in
            allAppsVisibleLimit = listPageSize
            scheduleAllAppsSearchUpdate()
        }
        .onChange(of: showOnlyEditedTittleApps, initial: false) { _, _ in
            allAppsVisibleLimit = listPageSize
            updateCachedAllAppEntries()
        }
        .onChange(of: appStore.customTitles, initial: false, updateCachedAllAppEntries)
        .onChange(of: appStore.apps, initial: false, updateCachedAllAppEntries)
        .onChange(of: appStore.folders, initial: false, updateCachedAllAppEntries)
        .onChange(of: appStore.hiddenAppPaths, initial: false, updateCachedAllAppEntries)
    }
    
    var customTitleEntries: [AppEntry] {
        appStore.customTitles
            .map { (path, _) in
                let info = appStore.appInfoForCustomTitle(path: path)
                let defaultName = appStore.defaultDisplayName(for: path)
                return AppEntry(id: path, appInfo: info, defaultName: defaultName)
            }
            .sorted { lhs, rhs in
                lhs.appInfo.name.localizedCaseInsensitiveCompare(rhs.appInfo.name) == .orderedAscending
            }
    }
    
    var allAppEntries: [AppEntry] {
        var allEntries: [AppEntry] = []
        allEntries.append(contentsOf: notHiddenAppEntries)
        allEntries.append(contentsOf: hiddenAppEntries)
        allEntries.sort { lhs, rhs in
            lhs.appInfo.name.localizedCaseInsensitiveCompare(rhs.appInfo.name) == .orderedAscending
        }
        return allEntries
    }
    
    func updateCachedAllAppEntries() {
        cachedAllAppEntries.removeAll()
        
        if (showOnlyEditedTittleApps){
            hasAllAppEntries = !customTitleEntries.isEmpty
            let filteredCustomTitleEntries = filter(customTitleEntries, by: allAppsSearch)
            hasAllAppEntriesSearchResult = !filteredCustomTitleEntries.isEmpty
            cachedAllAppEntries.append(contentsOf: filteredCustomTitleEntries)
        } else {
            hasAllAppEntries = !allAppEntries.isEmpty
            let filteredAllAppEntries = filter(allAppEntries, by: allAppsSearch)
            hasAllAppEntriesSearchResult = !filteredAllAppEntries.isEmpty
            cachedAllAppEntries.append(contentsOf: filteredAllAppEntries)
        }
    }

    func scheduleAllAppsSearchUpdate() {
        allAppsSearchDebounceID += 1
        let token = allAppsSearchDebounceID
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if allAppsSearchDebounceID == token {
                updateCachedAllAppEntries()
            }
        }
    }

    @ViewBuilder
    func customTitleRow(for entry: AppEntry) -> some View {
        let isEditing = editingEntries.contains(entry.id)
        let currentDraft = editingDrafts[entry.id] ?? appStore.customTitles[entry.id] ?? entry.appInfo.name
        let trimmedDraft = currentDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalValue = appStore.customTitles[entry.id] ?? entry.defaultName
        let draftBinding = Binding(
            get: { editingDrafts[entry.id] ?? appStore.customTitles[entry.id] ?? entry.appInfo.name },
            set: { editingDrafts[entry.id] = $0 }
        )

        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                Image(nsImage: IconStore.shared.icon(for: entry.appInfo))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.appInfo.name)
                        .font(.callout.weight(.semibold))
                    Text(String(format: appStore.localized(.customTitleDefaultFormat), entry.defaultName))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 10) {
                    if isEditing {
                        Button(appStore.localized(.customTitleSave)) {
                            saveCustomTitle(entry)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(trimmedDraft.isEmpty || trimmedDraft == originalValue)
                        Button(appStore.localized(.customTitleCancel)) {
                            cancelEditing(entry)
                        }
                        .buttonStyle(.bordered)

                        if !(appStore.customTitles[entry.id]?.isEmpty ?? true) {
                            Button(role: .destructive) {
                                removeCustomTitle(entry)
                            } label: {
                                Text(appStore.localized(.customTitleReset))
                            }
                            .buttonStyle(.bordered)
                        }

                    } else {
                        Button(appStore.localized(.customTitleEdit)) {
                            beginEditing(entry)
                        }
                        .buttonStyle(.bordered)

                        if !(appStore.customTitles[entry.id]?.isEmpty ?? true) {
                            Button(role: .destructive) {
                                removeCustomTitle(entry)
                            } label: {
                                Text(appStore.localized(.customTitleReset))
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }

            if isEditing {
                TextField("", text: draftBinding, prompt: Text(appStore.localized(.customTitlePlaceholder)))
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding(14)
        .liquidGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func presentCustomTitlePicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.applicationBundle]
        panel.title = appStore.localized(.customTitleAddButton)
        panel.message = appStore.localized(.customTitlePickerMessage)
        panel.prompt = appStore.localized(.chooseButton)

        if panel.runModal() == .OK, let url = panel.url, let info = appStore.ensureCustomTitleEntry(for: url) {
            let path = info.url.path
            editingEntries.insert(path)
            editingDrafts[path] = appStore.customTitles[path] ?? info.name
            if !showOnlyEditedTittleApps {
                showOnlyEditedTittleApps = true
                allAppsSearch = ""
            }
        }
    }

    func presentAppIconPicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.icns, .png, .jpeg, .tiff]
        panel.prompt = appStore.localized(.customIconChoose)
        panel.title = appStore.localized(.customIconTitle)

        if panel.runModal() == .OK, let url = panel.url {
            if !appStore.setCustomAppIcon(from: url) {
                iconImportError = appStore.localized(.customIconError)
            }
        }
    }

    func presentAppSourcePicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.prompt = appStore.localized(.chooseButton)

        if panel.runModal() == .OK {
            var addedAny = false
            for url in panel.urls {
                if appStore.addCustomAppSource(path: url.path) {
                    addedAny = true
                }
            }
            if !addedAny && !panel.urls.isEmpty {
                NSSound.beep()
            }
        }
    }

    func pathExists(_ path: String) -> Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue
    }

    func displayName(for path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let name = url.lastPathComponent
        return name.isEmpty ? path : name
    }

    @ViewBuilder
    func appSourceRow(icon: String, path: String, isAvailable: Bool, @ViewBuilder accessory: () -> some View) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(displayName(for: path))
                        .font(.body)
                    if !isAvailable {
                        Text(appStore.localized(.scanSourcesMissingBadge))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.orange.opacity(0.18)))
                    }
                }
                Text(path)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)
            accessory()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.secondary.opacity(0.08))
        )
    }

//    private struct CustomTitleEntry: Identifiable {
//        let id: String
//        let appInfo: AppInfo
//        let defaultName: String
//    }

    func beginEditing(_ entry: AppEntry) {
        editingEntries.insert(entry.id)
        editingDrafts[entry.id] = appStore.customTitles[entry.id] ?? entry.appInfo.name
    }

    func cancelEditing(_ entry: AppEntry) {
        editingEntries.remove(entry.id)
        editingDrafts.removeValue(forKey: entry.id)
    }

    func saveCustomTitle(_ entry: AppEntry) {
        let draft = (editingDrafts[entry.id] ?? appStore.customTitles[entry.id] ?? entry.appInfo.name)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !draft.isEmpty else { return }
        let original = appStore.customTitles[entry.id] ?? entry.defaultName
        if draft == original {
            editingEntries.remove(entry.id)
            editingDrafts.removeValue(forKey: entry.id)
            return
        }
        appStore.setCustomTitle(draft, for: entry.appInfo)
        editingEntries.remove(entry.id)
        editingDrafts.removeValue(forKey: entry.id)
    }

    func removeCustomTitle(_ entry: AppEntry) {
        appStore.clearCustomTitle(for: entry.appInfo)
        editingEntries.remove(entry.id)
        editingDrafts.removeValue(forKey: entry.id)
    }

    static let modifierOnlyKeyCodes: Set<UInt16> = [55, 54, 58, 61, 56, 60, 59, 62, 57]

}
