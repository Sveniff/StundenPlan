//
//  GridViewElement.swift
//  StundenPlan
//
//  Created by Sven Iffland on 27.01.21.
//

import SwiftUI

struct GridViewElement: View {
    @EnvironmentObject var user: UserData
    var grid: GridElement
    var space: CGFloat
    let TF = DateFormatter()
    var body: some View {
        let height = minutesBetweenDates(TF.date(from: grid.startTime!)!, TF.date(from: grid.endTime!)!) * CGFloat(user.scale)
        VStack{
            ZStack{
                Rectangle()
                    .foregroundColor(Color.secondary.opacity(0.1))
                    .zIndex(0)
                VStack{
                    Text(grid.startTime ?? "")
                    Text(grid.name ?? "")
                        .font(.system(size: 15 * CGFloat(user.scale), weight: .regular, design: .rounded))
                    Text(grid.endTime ?? "")
                }
                .zIndex(1)
            }
            .frame(width: UIScreen.main.bounds.width*0.05, height: CGFloat(height))
            Spacer()
        }
        .frame(width:UIScreen.main.bounds.width*0.05 ,height: height + abs(space) + 1)
    }
    init(_ gd: GridElement, _ s: CGFloat) {
        grid = gd
        TF.dateFormat = "H:mm"
        space = s
    }
}

struct GridViewElement_Previews: PreviewProvider {
    static var previews: some View {
        GridViewElement(GridElement(), 5)
    }
}
