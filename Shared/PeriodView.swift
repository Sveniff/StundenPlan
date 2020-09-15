//
//  PeriodView.swift
//  StundenPlan
//
//  Created by Sven Iffland on 14.09.20.
//

import SwiftUI

struct PeriodView: View {
    @StateObject var period: Period
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25.0).foregroundColor(colFromStr(period.subjects[0].backColor ?? "000000"))
        }
    }
}

struct PeriodView_Previews: PreviewProvider {
    static var previews: some View {
        PeriodView(period: Period())
    }
}
