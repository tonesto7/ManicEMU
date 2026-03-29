//
//  GamesNavigationView.swift
//  ManicEmu
//
//  Created by Max on 2025/1/25.
//  Copyright © 2025 Manic EMU. All rights reserved.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit

class GamesNavigationView: UIView {
    private var iCloudSyncStatusWidthConstraint: Constraint?

    private var appTitle: UIImageView = {
        let view = UIImageView(image: UIImage(.dm, light: R.image.app_title_light()!, dark: R.image.app_title()!))
        return view
    }()
    
    var controllerButton: SymbolButton = {
        let view = SymbolButton(image: R.image.customArcadeStickConsoleFill()?.applySymbolConfig(), enableGlass: true)
        view.enableRoundCorner = true
        view.backgroundColor = Constants.Color.BackgroundPrimary
        return view
    }()
    
    var historyButton: SymbolButton = {
        let view = SymbolButton(image: R.image.customFlagPatternCheckered()?.applySymbolConfig(), enableGlass: true)
        view.enableRoundCorner = true
        view.backgroundColor = Constants.Color.BackgroundPrimary
        return view
    }()
    
    let iCloudSyncStatusView: ICloudSyncStatusView = {
        let view = ICloudSyncStatusView()
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews([controllerButton, appTitle, iCloudSyncStatusView, historyButton])
        appTitle.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        controllerButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Constants.Size.ContentSpaceMax)
            make.centerY.equalToSuperview()
            make.size.equalTo(Constants.Size.IconSizeMax)
        }
        
        historyButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Constants.Size.ContentSpaceMax)
            make.centerY.equalToSuperview()
            make.size.equalTo(Constants.Size.IconSizeMax)
        }
        
        iCloudSyncStatusView.snp.makeConstraints { make in
            make.trailing.equalTo(historyButton.snp.leading).offset(-Constants.Size.ContentSpaceTiny)
            make.centerY.equalToSuperview()
            make.height.equalTo(Constants.Size.IconSizeMax.height)
            self.iCloudSyncStatusWidthConstraint = make.width.equalTo(UIDevice.isPhone ? 36 : 96).constraint
        }
    }

    func updateICloudSyncStatusWidth(hasActiveTasks: Bool) {
        let width: CGFloat
        if UIDevice.isPhone {
            width = hasActiveTasks ? 66 : 36
        } else {
            width = hasActiveTasks ? 110 : 96
        }
        iCloudSyncStatusWidthConstraint?.update(offset: width)
        layoutIfNeeded()
    }
    
    // MARK: - Sync Animation
    
    func startSyncAnimation() {
        guard iCloudSyncStatusView.layer.animation(forKey: "syncPulse") == nil else { return }
        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue = 1.0
        pulse.toValue = 0.5
        pulse.duration = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        iCloudSyncStatusView.layer.add(pulse, forKey: "syncPulse")
    }
    
    func stopSyncAnimation() {
        iCloudSyncStatusView.layer.removeAnimation(forKey: "syncPulse")
        iCloudSyncStatusView.layer.opacity = 1.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
