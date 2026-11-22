import SwiftUI

/// 一条设置搜索结果。
/// 命中粒度是「入口 › 子页 › 具体设置项」，点击后跳到对应子页。
struct SettingsSearchHit: Identifiable {
    let id: String
    let entry: SettingsView.SettingsEntry
    let subpage: SettingsView.SettingsSection
    let entryTitle: String
    let subpageTitle: String
    let matchedText: String?
    let rank: Int

    var detailText: String {
        if let matchedText {
            return "\(subpageTitle) › \(matchedText)"
        }
        return subpageTitle
    }
}

extension SettingsView {
    /// 搜索范围：入口名、子页名、每个子页在 `SettingsSection.meta.keywords` 里登记的设置项标题。
    /// 排序：入口命中 > 子页命中 > 设置项命中，同级按文案排序，最多 30 条。
    func makeSettingsSearchHits(for rawQuery: String) -> [SettingsSearchHit] {
        let query = foldForSearch(rawQuery)
        guard !query.isEmpty else { return [] }

        var hits: [SettingsSearchHit] = []
        var seen = Set<String>()

        func append(entry: SettingsEntry, subpage: SettingsSection, matched: String?, rank: Int) {
            let id = "\(entry.id)|\(subpage.id)|\(matched ?? "")"
            guard seen.insert(id).inserted else { return }
            hits.append(
                SettingsSearchHit(
                    id: id,
                    entry: entry,
                    subpage: subpage,
                    entryTitle: appStore.localized(entry.localizationKey),
                    subpageTitle: appStore.localized(subpage.localizationKey),
                    matchedText: matched,
                    rank: rank
                )
            )
        }

        // 只搜实际展示的入口：`.updates` 被隐藏时不应该搜得到（点进去也没有侧栏选中态）。
        for entry in SettingsEntry.visibleCases {
            if foldForSearch(appStore.localized(entry.localizationKey)).contains(query) {
                append(entry: entry, subpage: entry.subpages[0], matched: nil, rank: 0)
            }

            for subpage in entry.subpages {
                if foldForSearch(appStore.localized(subpage.localizationKey)).contains(query) {
                    append(entry: entry, subpage: subpage, matched: nil, rank: 1)
                }

                for keyword in subpage.searchKeywords {
                    let text = appStore.localized(keyword)
                    if foldForSearch(text).contains(query) {
                        append(entry: entry, subpage: subpage, matched: text, rank: 2)
                    }
                }
            }
        }

        let sorted = hits.sorted { lhs, rhs in
            if lhs.rank != rhs.rank { return lhs.rank < rhs.rank }
            return lhs.detailText.localizedStandardCompare(rhs.detailText) == .orderedAscending
        }
        return Array(sorted.prefix(30))
    }
}

/// 大小写与变音符号不敏感，便于德语 / 法语 / 越南语输入。
func foldForSearch(_ text: String) -> String {
    text
        .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        .trimmingCharacters(in: .whitespacesAndNewlines)
}
