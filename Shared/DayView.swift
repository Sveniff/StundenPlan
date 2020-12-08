//
//  periodView.swift
//  StundenPlan
//
//  Created by Sven Iffland on 13.11.20.
//

import SwiftUI

struct DayView: View {
    var periods: [Period]
    let TF = DateFormatter()
    var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    init(_ pe: [Period]){
        periods = pe
        TF.dateFormat = "H:mm"
        calendar.firstWeekday = 7
        self.calendar.locale = Locale(identifier: "de_DE")
    }
    
    var body: some View {
        ForEach(periods.filter({$0.code != "cancelled"})){ period in
            PeriodView(period)
        }
    }
}

struct periodView_Previews: PreviewProvider {
    static var previews: some View {
        DayView([])
    }
}
