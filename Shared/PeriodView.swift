//
//  PeriodView.swift
//  StundenPlan
//
//  Created by Sven Iffland on 11.11.20.
//

import SwiftUI

struct PeriodView: View {
    var period: Period
    let TF = DateFormatter()
    var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    init(_ pe: Period){
        period = pe
        TF.dateFormat = "H:mm"
        calendar.firstWeekday = 7
        self.calendar.locale = Locale(identifier: "de_DE")
    }
    
    var body: some View {
        let height = minutesBetweenDates(TF.date(from: period.startTime!)!, TF.date(from: period.endTime!)!)
        VStack{
            HStack{
                ForEach(period.subjects){ su in
                    Text(su.name ?? "")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                }
            }
            HStack{
                ForEach(period.rooms){ ro in
                    Text(ro.name ?? "")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                }
            }
            HStack{
                ForEach(period.teachers){ te in
                    Text(te.name ?? "")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                }
            }
            HStack{
                ForEach(period.classes){ kl in
                    Text(kl.name ?? "")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                }
            }
        }
        .foregroundColor(period.subjects.isEmpty ? .primaryInvert : hexStringToUIColor(hex: period.subjects[0].foreColor!))
        .multilineTextAlignment(.center)
    }
}

struct PeriodView_Previews: PreviewProvider {
    static var previews: some View {
        PeriodView(Period())
    }
}
