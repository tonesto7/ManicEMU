//
//  iCloudSyncStatusView.swift
//  ManicEmu
//
//  Copyright © 2025 Manic EMU. All rights reserved.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit

class ICloudSyncStatusView: SymbolButton {
    private var syncSymbol: SFSymbol {
        if #available(iOS 17.0, *) {
            return .arrowTriangle2CirclepathIcloudFill
        }
        return .cloudFill
    }

    init() {
        super.init(
            image: UIImage(symbol: .cloudFill,
                           font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                           color: Constants.Color.LabelPrimary),
            title: "",
            titleFont: UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .semibold),
            titleColor: Constants.Color.Blue,
            horizontalContian: true,
            titlePosition: .right,
            imageAndTitlePadding: 4,
            enableGlass: true
        )
        enableRoundCorner = true
        backgroundColor = Constants.Color.BackgroundPrimary
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with files: [SyncManager.SyncFileInfo]) {
        let isIdle = files.isEmpty
        if isIdle {
            imageView.image = UIImage(
                symbol: .checkmarkIcloudFill,
                font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                color: Constants.Color.Green
            )
            titleLabel.text = ""
            return
        }

        imageView.image = UIImage(
            symbol: syncSymbol,
            font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            color: Constants.Color.LabelPrimary
        )

        if UIDevice.isPhone {
            titleLabel.textColor = Constants.Color.Blue
            titleLabel.text = String(format: "%.0f%%", overallAverageProgress(files: files))
        } else {
            let uploadFiles = files.filter { $0.direction == .upload }
            let downloadFiles = files.filter { $0.direction == .download }
            var parts: [String] = []
            if !uploadFiles.isEmpty {
                let up = averageProgress(for: .upload, files: files)
                parts.append(String(format: "↑%.0f%%", up))
            }
            if !downloadFiles.isEmpty {
                let down = averageProgress(for: .download, files: files)
                parts.append(String(format: "↓%.0f%%", down))
            }
            titleLabel.textColor = Constants.Color.LabelPrimary
            titleLabel.text = parts.joined(separator: " ")
        }
    }

    private func overallAverageProgress(files: [SyncManager.SyncFileInfo]) -> Double {
        guard !files.isEmpty else { return 0 }
        let sum = files.reduce(0.0) { partialResult, file in
            partialResult + file.percentComplete
        }
        return sum / Double(files.count)
    }

    private func averageProgress(for direction: SyncManager.SyncFileInfo.Direction,
                                 files: [SyncManager.SyncFileInfo]) -> Double {
        let matched = files.filter { $0.direction == direction }
        guard !matched.isEmpty else { return 0 }
        let sum = matched.reduce(0.0) { partialResult, file in
            partialResult + file.percentComplete
        }
        return sum / Double(matched.count)
    }
}
