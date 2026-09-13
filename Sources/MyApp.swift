// Copyright (C) 2025 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import Foundation
import QtBridge
import TsubameCore

@main
struct MyApp: QApp {
    let qmlFileName: String = "main"
    var initialProperties: [String : QtBridge.QObjectBuildable] = [
        "myModel" : MyModel()
    ]
}
