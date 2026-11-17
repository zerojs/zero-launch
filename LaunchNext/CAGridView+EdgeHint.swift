import AppKit

extension CAGridView {
    /// 最后一列图标右缘 → 网格右缘 之间的空白带宽度。
    ///
    /// 列宽是均分出来的（`cellWidth = (availableWidth - 总列间距) / columns`），
    /// 图标在单元格里居中，所以最外侧那条空白带只有半个单元格减去半个图标，
    /// 实测 7 列 / 72pt 图标下约 60pt。提示条必须落在这条带子里才不会压住图标。
    func trailingEdgeMargin() -> CGFloat {
        guard bounds.width > 0, columns > 0 else { return 0 }

        let availableWidth = bounds.width - contentInsets.left - contentInsets.right
        guard availableWidth > 0 else { return 0 }

        let cellWidth = (availableWidth - columnSpacing * CGFloat(columns - 1)) / CGFloat(columns)
        let strideX = cellWidth + columnSpacing
        let lastCellOriginX = contentInsets.left + CGFloat(columns - 1) * strideX
        let iconRightEdge = lastCellOriginX + (cellWidth + iconSize) / 2

        return max(0, bounds.width - iconRightEdge)
    }

    /// 同步边缘翻页提示条。
    /// - Parameter side: -1 左边缘 / 1 右边缘 / 0 收起
    func updateEdgeHint(side: Int) {
        guard side != 0, bounds.width > 0, bounds.height > 0 else {
            edgeHintController.hide()
            return
        }

        // 网格左右已经各让出 `CAGridView.edgeGutterWidth`(40pt),空白带因此变宽,
        // 这里取「空白带 - 16pt」作为条宽,让条子与最后一列图标之间留出明显空隙,
        // 视觉上它就是贴在屏幕边上的独立导轨;上下限 44~100pt。
        let margin = trailingEdgeMargin()
        edgeHintController.width = max(44, min(100, margin - 16))

        edgeHintController.update(side: side, in: bounds, host: layer)
    }
}
