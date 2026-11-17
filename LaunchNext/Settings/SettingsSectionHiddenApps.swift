import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    var hiddenAppsSection: some View {
        return LazyVStack(alignment: .leading, spacing: 16) {
            HStack {
                Button {
                    presentHiddenAppPicker()
                } label: {
                    Label(appStore.localized(.hiddenAppsAddButton), systemImage: "eye.slash")
                }
                Spacer()
            }

            DisclosureGroup(isExpanded: $showHiddenApps) {
                LazyVStack(alignment: .leading, spacing: 16){
                    if hasHiddenAppEntries {
                        Text(appStore.localized(.hiddenAppsHint))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        
                        TextField("", text: $hiddenSearch, prompt: Text(appStore.localized(.hiddenAppsSearchPlaceholder)))
                            .textFieldStyle(.roundedBorder)
                            .padding(3)
                        
                        if hasHiddenAppEntriesSearchResult {
                            LazyVStack(spacing: 12) {
                                ForEach(cachedHiddenAppEntries.prefix(hiddenVisibleLimit)) { entry in
                                    hiddenAppRow(for: entry)
                                }
                                if cachedHiddenAppEntries.count > hiddenVisibleLimit {
                                    Button(appStore.localized(.loadMore)) {
                                        hiddenVisibleLimit = min(hiddenVisibleLimit + listPageSize,
                                                                 cachedHiddenAppEntries.count)
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
                    } else {
                        hiddenAppsEmptyState
                    }
                }
            } label: {
                Label(appStore.localized(.settingsSectionHiddenApps), systemImage: "eye.slash")
                    .font(.headline)
            }
                
            DisclosureGroup(isExpanded: $showNotHiddenApps) {
                LazyVStack(alignment: .leading, spacing: 16){
                    if hasNotHiddenAppEntries{
                        Spacer()
                        Text(appStore.localized(.notHiddenAppsHint))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        
                        TextField("", text: $notHiddenSearch, prompt: Text(appStore.localized(.notHiddenAppsSearchPlaceholder)))
                            .textFieldStyle(.roundedBorder)
                            .padding(3)
                        
                        if hasNotHiddenAppEntriesSearchResult{
                            LazyVStack(spacing: 12) {
                                ForEach(cachedNotHiddenAppEntries.prefix(notHiddenVisibleLimit)) { entry in
                                    notHiddenAppRow(for: entry)
                                }
                                if cachedNotHiddenAppEntries.count > notHiddenVisibleLimit {
                                    Button(appStore.localized(.loadMore)) {
                                        notHiddenVisibleLimit = min(notHiddenVisibleLimit + listPageSize,
                                                                    cachedNotHiddenAppEntries.count)
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
            } label: {
                Label(appStore.localized(.notHiddenAppsTitle), systemImage: "eye")
                    .font(.headline)
            }
                
        }
        .onAppear(perform: updateCachedHiddenAndNotHiddenAppEntries)
        .onChange(of: hiddenSearch, initial: false) { _, _ in
            hiddenVisibleLimit = listPageSize
            scheduleHiddenSearchUpdate()
        }
        .onChange(of: notHiddenSearch, initial: false) { _, _ in
            notHiddenVisibleLimit = listPageSize
            if showNotHiddenApps {
                scheduleNotHiddenSearchUpdate()
            }
        }
        .onChange(of: showNotHiddenApps, initial: false) { _, isExpanded in
            if isExpanded {
                notHiddenVisibleLimit = listPageSize
                updateCachedNotHiddenAppEntries()
            }
        }
        .onChange(of: appStore.apps, initial: false, updateCachedHiddenAndNotHiddenAppEntries)
        .onChange(of: appStore.folders, initial: false, updateCachedHiddenAndNotHiddenAppEntries)
        .onChange(of: appStore.hiddenAppPaths, initial: false, updateCachedHiddenAndNotHiddenAppEntries)
    }

    var hiddenAppEntries: [AppEntry] {
        appStore.hiddenAppPaths
            .map { path in
                let info = appStore.appInfoForCustomTitle(path: path)
                let defaultName = appStore.defaultDisplayName(for: path)
                return AppEntry(id: path, appInfo: info, defaultName: defaultName)
            }
            .sorted { lhs, rhs in
                lhs.appInfo.name.localizedCaseInsensitiveCompare(rhs.appInfo.name) == .orderedAscending
            }
    }
    
    var notHiddenAppEntries: [AppEntry] {
        visibleNonHiddenApps
            .map { info in
                let path = info.url.path
                let defaultName = appStore.defaultDisplayName(for: path)
                return AppEntry(id: path, appInfo: info, defaultName: defaultName)
            }
            .sorted { lhs, rhs in
                lhs.appInfo.name.localizedCaseInsensitiveCompare(rhs.appInfo.name) == .orderedAscending
            }
    }

    var visibleNonHiddenApps: [AppInfo] {
        var dedupedByPath: [String: AppInfo] = [:]
        for app in appStore.apps {
            dedupedByPath[standardizePath(app.url.path)] = app
        }
        for folder in appStore.folders {
            for app in folder.apps {
                let key = standardizePath(app.url.path)
                if dedupedByPath[key] == nil {
                    dedupedByPath[key] = app
                }
            }
        }
        return Array(dedupedByPath.values)
    }
    
    func matches(_ entry: AppEntry, query: String) -> Bool {
        let options: String.CompareOptions = [
            .caseInsensitive,
            .diacriticInsensitive,
            .widthInsensitive
        ]
            
        return entry.appInfo.name.range(of: query, options: options) != nil
            || entry.defaultName.range(of: query, options: options) != nil
            || entry.id.range(of: query, options: options) != nil
    }
    
    func filter(_ base: [AppEntry], by rawQuery: String) -> [AppEntry] {
        let query = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return base }
        return base.filter { entry in
            matches(entry, query: query)
        }
    }

    var hiddenAppsEmptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(appStore.localized(.hiddenAppsEmptyTitle))
                .font(.headline)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    func hiddenAppRow(for entry: AppEntry) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(nsImage: IconStore.shared.icon(for: entry.appInfo))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.appInfo.name)
                    .font(.callout.weight(.semibold))
                Text(entry.defaultName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entry.id)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                appStore.unhideApp(path: entry.id)
            } label: {
                Text(appStore.localized(.hiddenAppsRemoveButton))
            }
            .buttonStyle(.bordered)
        }
        .padding(14)
        .liquidGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func notHiddenAppRow(for entry: AppEntry) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(nsImage: IconStore.shared.icon(for: entry.appInfo))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.appInfo.name)
                    .font(.callout.weight(.semibold))
                Text(entry.defaultName)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Text(entry.id)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                appStore.hideApp(atPath: entry.id)
            } label: {
                Text(appStore.localized(.hiddenAppsAddButton))
            }
            .buttonStyle(.bordered)
        }
        .padding(14)
        .liquidGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    struct AppEntry: Identifiable {
        let id: String
        let appInfo: AppInfo
        let defaultName: String
    }
    
    func updateCachedHiddenAppEntries() {
        cachedHiddenAppEntries.removeAll()
        hasHiddenAppEntries = !hiddenAppEntries.isEmpty
        let filteredHiddenAppEntries = filter(hiddenAppEntries, by: hiddenSearch)
        hasHiddenAppEntriesSearchResult = !filteredHiddenAppEntries.isEmpty
        cachedHiddenAppEntries.append(contentsOf: filteredHiddenAppEntries)
    }
    
    func updateCachedNotHiddenAppEntries() {
        guard showNotHiddenApps else {
            cachedNotHiddenAppEntries.removeAll()
            hasNotHiddenAppEntries = false
            hasNotHiddenAppEntriesSearchResult = false
            return
        }

        cachedNotHiddenAppEntries.removeAll()
        hasNotHiddenAppEntries = !notHiddenAppEntries.isEmpty
        let filteredNotHiddenAppEntries = filter(notHiddenAppEntries, by: notHiddenSearch)
        hasNotHiddenAppEntriesSearchResult = !filteredNotHiddenAppEntries.isEmpty
        cachedNotHiddenAppEntries.append(contentsOf: filteredNotHiddenAppEntries)
    }
    
    func updateCachedHiddenAndNotHiddenAppEntries() {
        updateCachedHiddenAppEntries()
        updateCachedNotHiddenAppEntries()
    }

    func scheduleHiddenSearchUpdate() {
        hiddenSearchDebounceID += 1
        let token = hiddenSearchDebounceID
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if hiddenSearchDebounceID == token {
                updateCachedHiddenAppEntries()
            }
        }
    }

    func scheduleNotHiddenSearchUpdate() {
        notHiddenSearchDebounceID += 1
        let token = notHiddenSearchDebounceID
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if notHiddenSearchDebounceID == token {
                updateCachedNotHiddenAppEntries()
            }
        }
    }

    func presentHiddenAppPicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.applicationBundle]
        panel.prompt = appStore.localized(.hiddenAppsAddButton)
        panel.title = appStore.localized(.hiddenAppsAddButton)

        if panel.runModal() == .OK {
            if !appStore.hideApps(at: panel.urls) {
                NSSound.beep()
            }
        }
    }

}
