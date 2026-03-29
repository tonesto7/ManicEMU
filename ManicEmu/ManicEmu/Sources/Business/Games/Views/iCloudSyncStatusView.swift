//
//  iCloudSyncStatusView.swift
//  ManicEmu
//
//  Copyright © 2025 Manic EMU. All rights reserved.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit

class ICloudSyncStatusView: RoundAndBorderView {
    private let cloudIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        let symbol: SFSymbol
        if #available(iOS 17.0, *) {
            symbol = .arrowTriangle2CirclepathIcloudFill
        } else {
            symbol = .cloudFill
        }
        view.image = UIImage(symbol: symbol,
                             font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                             color: Constants.Color.LabelPrimary)
        return view
    }()

    // iPhone: single percentage
    private let singlePercentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .semibold)
        label.textColor = Constants.Color.Blue
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.text = "0%"
        return label
    }()

    // iPad: up/down percentages
    private let upLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .semibold)
        label.textColor = Constants.Color.Blue
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.text = "↑ 0%"
        return label
    }()

    private let downLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .semibold)
        label.textColor = Constants.Color.Green
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.textAlignment = .right
        label.text = "↓ 0%"
        return label
    }()

    init() {
        super.init(
            roundCorner: .allCorners,
            radius: 18,
            borderColor: Constants.Color.Border,
            borderWidth: 1
        )
        backgroundColor = Constants.Color.BackgroundPrimary
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        addSubviews([cloudIcon, singlePercentLabel, upLabel, downLabel])

        cloudIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Constants.Size.ContentSpaceTiny)
            make.centerY.equalToSuperview()
            make.size.equalTo(14)
        }

        singlePercentLabel.snp.makeConstraints { make in
            make.leading.equalTo(cloudIcon.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-Constants.Size.ContentSpaceTiny)
            make.centerY.equalToSuperview()
        }

        upLabel.snp.makeConstraints { make in
            make.leading.equalTo(cloudIcon.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }

        downLabel.snp.makeConstraints { make in
            make.leading.equalTo(upLabel.snp.trailing).offset(6)
            make.trailing.equalToSuperview().offset(-Constants.Size.ContentSpaceTiny)
            make.centerY.equalToSuperview()
        }

        updateLayoutForDevice()
    }

    func update(with files: [SyncManager.SyncFileInfo]) {
        let hasActive = !files.isEmpty
        let overall = overallAverageProgress(files: files)

        singlePercentLabel.text = String(format: "%.0f%%", overall)
        upLabel.text = String(format: "↑ %.0f%%", averageProgress(for: .upload, files: files))
        downLabel.text = String(format: "↓ %.0f%%", averageProgress(for: .download, files: files))

        if UIDevice.isPhone {
            // iPhone: icon only when idle, icon + single % when syncing
            singlePercentLabel.isHidden = !hasActive
        }
    }

    private func updateLayoutForDevice() {
        let isPhone = UIDevice.isPhone
        singlePercentLabel.isHidden = !isPhone
        upLabel.isHidden = isPhone
        downLabel.isHidden = isPhone
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
