//
//  DashboardMobile.swift
//  StundenPlan (iOS)
//
//  Created by Sven Iffland on 30.09.20.
//

import SwiftUI

struct DashboardMobile: View {
    @State private var selection: Int = 1
    private let df = DateFormatter()
    init() {
        df.dateFormat = "H:mm"
    }
    var body: some View {
        ZStack{
            Group{
                switch selection{
                case 0:
                    Color.primaryInvert
                        .transition(.opacity)
                        .edgesIgnoringSafeArea(.all)
                        .zIndex(1)
                case 1:
                    TimetableViewModule().build()
                        .zIndex(0)
                        .transition(.opacity)
                    CardView()
                        .transition(.move(edge: .bottom))
                        .zIndex(1)

                case 2:
                    Settingsview()
                        .transition(.opacity)
                        .edgesIgnoringSafeArea(.all)
                        .zIndex(1)
                default:
                    EmptyView()
                }
            }
            .zIndex(0)
            CustomSlider(selection: $selection)
                .zIndex(2)
        }
    }
}

struct DashboardMobile_Previews: PreviewProvider {
    static var previews: some View {
        DashboardMobile()
    }
}

