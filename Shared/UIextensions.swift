//
//  UIextensions.swift
//  StundenPlan
//
//  Created by Sven Iffland on 06.10.20.
//

import Foundation
import SwiftUI

extension Color {
    static let primaryInvert = Color("Invert")
    static let gradient_top = Color("Gradient-top")
    static let gradient_bottom = Color("Gradient-bottom")
}

func hexStringToUIColor (hex:String) -> Color {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return Color.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return Color(
        red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: Double(rgbValue & 0x0000FF) / 255.0
    )
}
