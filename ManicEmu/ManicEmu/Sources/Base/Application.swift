//
//  Application.swift
//  ManicEmu
//
//  Created by Daiuno on 2025/5/13.
//  Copyright © 2025 Manic EMU. All rights reserved.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit
import ManicEmuCore

private extension UIApplication {
    @objc(handleKeyUIEvent:)
    @NSManaged func handleKeyboardKey(for event: UIEvent)
}

class ManicApplication: UIApplication {
    // 上次键盘事件的时间戳，用于避免重复处理
    private static var lastKeyboardEventTimestamp: TimeInterval = 0
    
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        if PlayViewController.isGaming, PlayViewController.currentGameType == .dos {
            LibretroCore.sharedInstance().send(event)
        }
    }
    
    // 处理键盘事件 - 对应Objective-C中的handleKeyUIEvent方法
    // DOS游戏通过此方法处理键盘输入（keyboardEvent:已包含去重和key-repeat过滤）
    // DeltaCore游戏通过ControllerView处理键盘输入
    override func handleKeyboardKey(for event: UIEvent) {
        // DOS游戏：通过keyboardEvent:处理，该方法已包含完整的去重逻辑
        if PlayViewController.isGaming, PlayViewController.currentGameType == .dos {
            LibretroCore.sharedInstance().keyboardEvent(event)
            return
        }
        
        super.handleKeyboardKey(for: event)
        
        if #available(iOS 26.0, *) {
            guard let firstResponder = UIResponder.firstResponder as? ControllerView else { return }
            // 检查是否是重复的时间戳，避免重复处理
            if ManicApplication.lastKeyboardEventTimestamp == event.timestamp {
                return
            }
            
            ManicApplication.lastKeyboardEventTimestamp = event.timestamp
            
            firstResponder.handleKeyboardKey(for: event)
        }
    }
    
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        // DOS游戏的键盘输入已通过handleKeyboardKey -> keyboardEvent:处理
        // 不再通过pressesBegan发送，避免重复
        super.pressesBegan(presses, with: event)
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        // DOS游戏的键盘输入已通过handleKeyboardKey -> keyboardEvent:处理
        // 不再通过pressesEnded发送，避免重复
        super.pressesEnded(presses, with: event)
    }
    
}
