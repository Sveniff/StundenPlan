//
//  UIextensions.swift
//  StundenPlan
//
//  Created by Sven Iffland on 06.10.20.
//

import Foundation
import SwiftUI
import Combine
import CoreData
//MARK: UI extensions and functions
extension Color {
    static let primaryInvert = Color("Invert")
    static let gradient_top = Color("Gradient-top")
    static let gradient_bottom = Color("Gradient-bottom")
    static let OHGWhite = Color("OHGWhite")
    static let OHGYellow = Color("OHGYellow")
    static let OHGOrange = Color("OHGOrange")
    static let OHGRed = Color("OHGRed")
}

func minutesBetweenDates(_ oldDate: Date, _ newDate: Date) -> CGFloat {

    //get both times sinces refrenced date and divide by 60 to get minutes
    let newDateMinutes = newDate.timeIntervalSinceReferenceDate/60
    let oldDateMinutes = oldDate.timeIntervalSinceReferenceDate/60

    //then return the difference
    return CGFloat(newDateMinutes - oldDateMinutes)
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
struct TextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .frame(width: 250, height: 40, alignment: .center)
            .font(.system(size: 16, weight: .regular, design: .default))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke())
    }
}

extension View{
    func loginTextField() -> some View{
        self.modifier(TextFieldModifier())
    }
}

//func shortenTimetable(periods: [Period]) -> [Period]{
//    for i in 1...periods.count-1{
//        if periods[i].subjects.first.id == periods[i-1].subjects.first.id{
//            var newPeriod = periods[i]
//
//        }
//    }
//}
