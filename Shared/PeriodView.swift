//
//  PeriodView.swift
//  StundenPlan
//
//  Created by Sven Iffland on 27.01.21.
//

import SwiftUI

struct PeriodView: View {
    @EnvironmentObject var user: UserData
    var period: Period
    var space: CGFloat
    let TF = DateFormatter()
    var body: some View {
        let height = minutesBetweenDates(TF.date(from: period.startTime!)!, TF.date(from: period.endTime!)!) * CGFloat(user.scale)
        VStack{
            ZStack{
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(period.subjects.isEmpty ? .primary : hexStringToUIColor(hex: period.subjects[0].backColor!))
                    .zIndex(0)
                VStack{
                    HStack{
                        ForEach(period.subjects){ su in
                            Text(su.name ?? "")
                                .font(.system(size: 10 * CGFloat(user.scale), weight: .semibold, design: .rounded))
                        }
                    }
                    HStack{
                        ForEach(period.rooms){ ro in
                            Text(ro.name ?? "")
                                .font(.system(size: 8.5 * CGFloat(user.scale), weight: .semibold, design: .rounded))
                        }
                    }
                    HStack{
                        ForEach(period.teachers){ te in
                            Text(te.name ?? "")
                                .font(.system(size: 8.5 * CGFloat(user.scale), weight: .semibold, design: .rounded))
                        }
                    }
                    HStack{
                        ForEach(period.classes){ kl in
                            Text(kl.name ?? "")
                                .font(.system(size: 8.5 * CGFloat(user.scale), weight: .semibold, design: .rounded))
                        }
                    }
                }
                .foregroundColor(period.subjects.isEmpty ? .primaryInvert : hexStringToUIColor(hex: period.subjects[0].foreColor!))
                .multilineTextAlignment(.center)
                .zIndex(1)
            }
            .frame(width: UIScreen.main.bounds.width*0.145, height: CGFloat(height))
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width*0.15, height: height + abs(space) + 1)
    }
    
    init(_ pe: Period, _ s: CGFloat){
        TF.dateFormat = "H:mm"
        period = pe
        space = s
    }
}

struct PeriodView_Previews: PreviewProvider {
    static var previews: some View {
        PeriodView(Period(), 5)
            .previewLayout(.fixed(width: 100, height: 100))
    }
}
