//
//  ICloudSyncPopoverViewController.swift
//  ManicEmu
//
//  Copyright © 2026 Manic EMU. All rights reserved.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit

class ICloudSyncPopoverViewController: UIViewController {
    private let dimmingView = UIView()

    private let cardView: RoundAndBorderView = {
        let view = RoundAndBorderView(
            roundCorner: .allCorners,
            radius: Constants.Size.CornerRadiusMax,
            borderColor: Constants.Color.Border,
            borderWidth: Constants.Size.BorderLineHeight
        )
        view.backgroundColor = Constants.Color.BackgroundPrimary
        return view
    }()

    private let headerIconView: UIImageView = {
        let imageView = UIImageView()
        if #available(iOS 17.0, *) {
            imageView.image = UIImage(symbol: .arrowTriangle2CirclepathIcloudFill,
                                      font: Constants.Font.body(size: .l, weight: .semibold),
                                      color: Constants.Color.Blue)
        } else {
            imageView.image = UIImage(symbol: .cloudFill,
                                      font: Constants.Font.body(size: .l, weight: .semibold),
                                      color: Constants.Color.Blue)
        }
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.iCloudTitle()
        label.font = Constants.Font.body(size: .l, weight: .bold)
        label.textColor = Constants.Color.LabelPrimary
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Font.body(size: .s, weight: .semibold)
        label.textColor = Constants.Color.LabelSecondary
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        return label
    }()

    private let upPercentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
        label.textColor = Constants.Color.Blue
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.text = "↑ 0%"
        return label
    }()

    private let downPercentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
        label.textColor = Constants.Color.Green
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.text = "↓ 0%"
        return label
    }()

    private let upSizeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Font.caption(size: .m)
        label.textColor = Constants.Color.LabelSecondary
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.text = "↑ 0 B"
        return label
    }()

    private let downSizeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Font.caption(size: .m)
        label.textColor = Constants.Color.LabelSecondary
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.text = "↓ 0 B"
        return label
    }()

    private let directionMetricsRow: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fill
        row.spacing = Constants.Size.ContentSpaceTiny
        return row
    }()

    private let directionMetricsSpacer = UIView()

    private let currentFileTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Current File"
        label.font = Constants.Font.body(size: .s, weight: .semibold)
        label.textColor = Constants.Color.LabelSecondary
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    private let currentFileSizeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Font.caption(size: .m)
        label.textColor = Constants.Color.LabelSecondary
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.text = "-"
        return label
    }()

    private let currentFileNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .semibold)
        label.textColor = Constants.Color.LabelPrimary
        label.lineBreakMode = .byTruncatingMiddle
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        return label
    }()

    private let progressBar: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.trackTintColor = Constants.Color.BackgroundSecondary
        view.progressTintColor = Constants.Color.Blue
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        return view
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .medium)
        label.textColor = Constants.Color.LabelSecondary
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        return label
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Font.caption(size: .m)
        label.textColor = Constants.Color.LabelSecondary
        label.numberOfLines = 2
        label.textAlignment = .left
        label.text = "Live iCloud sync status for uploads and downloads in your library."
        return label
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Font.body(size: .s, weight: .semibold)
        label.textColor = Constants.Color.Green
        label.textAlignment = .left
        label.text = R.string.localizable.iCloudSynced()
        return label
    }()

    private var topConstraint: Constraint?
    private var cardWidthConstraint: Constraint?
    private var cardCenterXConstraint: Constraint?

    private var files: [SyncManager.SyncFileInfo]
    private var syncState: SyncManager.SyncState
    private let topInsetFromHeader: CGFloat
    private let anchorRectInWindow: CGRect
    private var currentDisplayFileURL: URL?
    private var liveUpdateTimer: Timer?
    private let minimumPhoneWidth: CGFloat = 320

    init(files: [SyncManager.SyncFileInfo], syncState: SyncManager.SyncState, topInsetFromHeader: CGFloat, anchorRectInWindow: CGRect) {
        self.files = files
        self.syncState = syncState
        self.topInsetFromHeader = topInsetFromHeader
        self.anchorRectInWindow = anchorRectInWindow
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupViews()
        setupDismissGesture()
        updateContent(with: files, syncState: syncState)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTopInset()
        updateCardWidth()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLiveUpdates()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLiveUpdates()
    }

    deinit {
        stopLiveUpdates()
    }

    func updateContent(with files: [SyncManager.SyncFileInfo], syncState: SyncManager.SyncState) {
        self.files = files
        self.syncState = syncState

        upPercentLabel.text = String(format: "↑ %.0f%%", averageProgress(for: .upload, files: files))
        downPercentLabel.text = String(format: "↓ %.0f%%", averageProgress(for: .download, files: files))
        upSizeLabel.text = humanReadableSize(for: files.filter { $0.direction == .upload })
        downSizeLabel.text = humanReadableSize(for: files.filter { $0.direction == .download })

        let uploadFiles = files.filter { $0.direction == .upload }
        let downloadFiles = files.filter { $0.direction == .download }
        let hasUploadValues = !uploadFiles.isEmpty
        let hasDownloadValues = !downloadFiles.isEmpty

        // Download: size left of percentage. Upload: size right of percentage.
        downSizeLabel.isHidden = !hasDownloadValues
        downPercentLabel.isHidden = !hasDownloadValues
        upPercentLabel.isHidden = !hasUploadValues
        upSizeLabel.isHidden = !hasUploadValues
        directionMetricsSpacer.isHidden = !(hasUploadValues && hasDownloadValues)
        directionMetricsRow.isHidden = !(hasUploadValues || hasDownloadValues)

        subtitleLabel.text = syncState == .syncing ? R.string.localizable.iCloudSyncing() : R.string.localizable.iCloudSynced()

        if let current = selectCurrentDisplayFile(from: files) {
            currentFileTitleLabel.isHidden = false
            currentFileSizeLabel.isHidden = false
            currentFileNameLabel.isHidden = false
            progressBar.isHidden = false
            progressLabel.isHidden = false
            emptyStateLabel.isHidden = true
            subtitleLabel.isHidden = false

            currentFileNameLabel.text = current.fileName
            currentFileSizeLabel.text = humanReadableSize(for: current.url)
            progressLabel.text = String(format: "%.0f%%", current.percentComplete)
            progressBar.progressTintColor = current.direction == .upload ? Constants.Color.Blue : Constants.Color.Green
            progressBar.setProgress(Float(current.percentComplete / 100.0), animated: true)
        } else {
            currentDisplayFileURL = nil
            currentFileTitleLabel.isHidden = true
            currentFileSizeLabel.isHidden = true
            currentFileNameLabel.isHidden = true
            progressBar.isHidden = true
            progressLabel.isHidden = true
            emptyStateLabel.isHidden = false
            // Avoid duplicate "Synced" status text.
            subtitleLabel.isHidden = true
            progressLabel.text = "0%"
            progressBar.setProgress(0, animated: false)
        }
        updateCardWidth()
    }

    private func setupViews() {
        dimmingView.backgroundColor = .clear

        view.addSubviews([dimmingView, cardView])

        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let horizontalInset: CGFloat = UIDevice.isPhone ? Constants.Size.ContentSpaceTiny : Constants.Size.ContentSpaceMid

        cardView.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide).offset(horizontalInset)
            make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-horizontalInset)
            self.cardCenterXConstraint = make.centerX.equalToSuperview().constraint
            self.topConstraint = make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(topInsetFromHeader).constraint
            self.cardWidthConstraint = make.width.equalTo(minimumPhoneWidth).constraint
        }

        let headerStack = UIStackView(arrangedSubviews: [headerIconView, titleLabel])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = Constants.Size.ContentSpaceTiny

        headerIconView.snp.makeConstraints { make in
            make.size.equalTo(22)
        }

        directionMetricsRow.addArrangedSubview(downSizeLabel)
        directionMetricsRow.addArrangedSubview(downPercentLabel)
        directionMetricsRow.addArrangedSubview(directionMetricsSpacer)
        directionMetricsRow.addArrangedSubview(upPercentLabel)
        directionMetricsRow.addArrangedSubview(upSizeLabel)

        let currentFileMetaRow = UIStackView(arrangedSubviews: [currentFileTitleLabel, currentFileSizeLabel])
        currentFileMetaRow.axis = .horizontal
        currentFileMetaRow.alignment = .fill
        currentFileMetaRow.distribution = .fill
        currentFileMetaRow.spacing = Constants.Size.ContentSpaceTiny

        let progressRow = UIStackView(arrangedSubviews: [progressBar, progressLabel])
        progressRow.axis = .horizontal
        progressRow.alignment = .center
        progressRow.spacing = Constants.Size.ContentSpaceTiny

        progressLabel.snp.makeConstraints { make in
            make.width.equalTo(44)
        }

        let stack = UIStackView(arrangedSubviews: [
            headerStack,
            subtitleLabel,
            directionMetricsRow,
            emptyStateLabel,
            currentFileMetaRow,
            currentFileNameLabel,
            progressRow,
            infoLabel
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = Constants.Size.ContentSpaceTiny

        cardView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Constants.Size.ContentSpaceMid)
        }

        directionMetricsRow.snp.makeConstraints { make in
            make.height.equalTo(18)
        }

        progressBar.snp.makeConstraints { make in
            make.height.equalTo(5)
        }
    }

    private func setupDismissGesture() {
        dimmingView.addTapGesture { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }

    private func updateTopInset() {
        let anchorRect = view.convert(anchorRectInWindow, from: nil)
        let top = max(topInsetFromHeader, anchorRect.maxY + Constants.Size.ContentSpaceTiny)
        topConstraint?.update(offset: top)
    }

    private func updateCardWidth() {
        let horizontalInset: CGFloat = UIDevice.isPhone ? Constants.Size.ContentSpaceTiny : Constants.Size.ContentSpaceMid
        let maxWidth = max(0, view.safeAreaLayoutGuide.layoutFrame.width - horizontalInset * 2)
        guard maxWidth > 0 else { return }

        let minWidth = min(minimumPhoneWidth, maxWidth)

        let fileNameText = currentFileNameLabel.text ?? ""
        let fileNameWidth = (fileNameText as NSString).size(withAttributes: [.font: currentFileNameLabel.font as Any]).width

        // Width grows with filename content, with extra room for paddings and meta rows.
        let desiredWidthFromFileName = fileNameWidth + (Constants.Size.ContentSpaceMid * 4) + 80
        let targetWidth = min(max(max(minWidth, 360), desiredWidthFromFileName), maxWidth)

        cardWidthConstraint?.update(offset: targetWidth)

        let anchorRect = view.convert(anchorRectInWindow, from: nil)
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        let minCenterX = safeFrame.minX + horizontalInset + targetWidth / 2
        let maxCenterX = safeFrame.maxX - horizontalInset - targetWidth / 2
        let clampedCenterX = min(max(anchorRect.midX, minCenterX), maxCenterX)
        cardCenterXConstraint?.update(offset: clampedCenterX - view.bounds.midX)
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

    private func selectCurrentDisplayFile(from files: [SyncManager.SyncFileInfo]) -> SyncManager.SyncFileInfo? {
        let activeFiles = files.filter { $0.percentComplete < 100.0 }

        if let currentURL = currentDisplayFileURL,
           let current = files.first(where: { $0.url == currentURL }) {
            // If this file is done and others are still active, switch to an active file.
            if current.percentComplete >= 100.0, let replacement = activeFiles.first(where: { $0.url != currentURL }) {
                currentDisplayFileURL = replacement.url
                return replacement
            }
            return current
        }

        // Pick a stable candidate: prefer active files, then highest progress.
        let candidate = (activeFiles.isEmpty ? files : activeFiles).max { lhs, rhs in
            lhs.percentComplete < rhs.percentComplete
        }
        currentDisplayFileURL = candidate?.url
        return candidate
    }

    private func humanReadableSize(for files: [SyncManager.SyncFileInfo]) -> String {
        let total = files.reduce(UInt64(0)) { partialResult, file in
            partialResult + fileSize(for: file.url)
        }
        return FileType.humanReadableFileSize(total, decimalPlaces: 1) ?? "0 B"
    }

    private func humanReadableSize(for url: URL) -> String {
        let size = fileSize(for: url)
        return FileType.humanReadableFileSize(size, decimalPlaces: 1) ?? "-"
    }

    private func fileSize(for url: URL) -> UInt64 {
        if let value = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize {
            return UInt64(value)
        }
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let value = attributes[.size] as? NSNumber {
            return value.uint64Value
        }
        return 0
    }

    private func startLiveUpdates() {
        stopLiveUpdates()
        liveUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateContent(with: SyncManager.shared.syncingFiles, syncState: SyncManager.shared.syncState)
        }
        if let liveUpdateTimer {
            RunLoop.main.add(liveUpdateTimer, forMode: .common)
        }
    }

    private func stopLiveUpdates() {
        liveUpdateTimer?.invalidate()
        liveUpdateTimer = nil
    }
}
