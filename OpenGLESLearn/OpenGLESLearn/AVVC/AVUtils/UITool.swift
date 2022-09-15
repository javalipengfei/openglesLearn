//
//  UITool.swift
//  OpenGLESLearn
//
//  Created by lipengfei17 on 2022/9/15.
//

import UIKit

let SCREENHEIGHT = UIScreen.main.bounds.height
let SCREENWIDTH = UIScreen.main.bounds.width

let STATUSBARHEIGHT = UIApplication.shared.statusBarFrame.size.height
let BAR_HEIGHT:CGFloat = 44
var SafeAreaBottomHeight:CGFloat = STATUSBARHEIGHT>20 ? 34 : 0
var safeAreaTopHeight: CGFloat = STATUSBARHEIGHT > 20 ? 44 : 0
