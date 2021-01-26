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
                        .zIndex(0)
                case 1:
                    ZStack{
                        TimetableView()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
                            .fixedSize()
                            .zIndex(0)
                        CardView()
                            .zIndex(2)
                            .transition(.move(edge: .bottom))
                    }
                case 2:
                    Settingsview()
                        .transition(.opacity)
                        .edgesIgnoringSafeArea(.all)
                        .zIndex(0)
                default:
                    EmptyView()
                }
            }
            .zIndex(0)
            CustomSlider(selection: $selection)
                .zIndex(1)
        }
    }
}

struct DashboardMobile_Previews: PreviewProvider {
    static var previews: some View {
        DashboardMobile()
    }
}

