//
//  DashboardMobile.swift
//  StundenPlan (iOS)
//
//  Created by Sven Iffland on 30.09.20.
//

import SwiftUI

struct DashboardMobile: View {
    @State var selection: Int = 1
    @State var scrollOffset: CGFloat = 0.0
    @State var offset: CGFloat = 0.15
    @State var sliderOffset:CGFloat = 0.0
    var body: some View {
        ZStack{
            if selection == 0{
                Color.primaryInvert
                    .transition(.opacity)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(0)
            }
            if selection == 1{
                VStack{
                    TimetableView()
                }
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
                    .fixedSize()
                    .zIndex(0)
                VStack{
                    Spacer()
                        .frame(height:UIScreen.main.bounds.height*offset)
                    
                    LinearGradient(gradient: Gradient(colors: [.gradient_top, .gradient_bottom]), startPoint: .top, endPoint: .bottom)
                        .mask(RoundedRectangle(cornerRadius: 47).offset(x: 0, y: 0))
                        .frame(height: UIScreen.main.bounds.height*1)
                        .background(Color(red: 0.18, green: 0.15, blue: 0.55).frame(height: UIScreen.main.bounds.height).offset(y: UIScreen.main.bounds.height))
                        .shadow(radius: 10)
                        .overlay(
                            VStack{
                            //MARK:Scrollable View
                                RoundedRectangle(cornerRadius: 60).frame(width: UIScreen.main.bounds.width*0.1, height: 5, alignment: .center)
                                    .padding()
                                    .foregroundColor(Color.secondary)
                                    .shadow(radius: 5)
                                    .frame(width: UIScreen.main.bounds.width, height: 75)
                                VStack{
                                    Spacer()
                                        .frame(height: 10)
                                    HStack{
                                        RoundedRectangle(cornerRadius: 37.0)
                                            .foregroundColor(.primaryInvert)
                                            .opacity(0.7)
                                            .frame(height:250)
                                        RoundedRectangle(cornerRadius: 37.0)
                                            .foregroundColor(.primaryInvert)
                                            .opacity(0.7)
                                            .frame(height:250)
                                    }
                                    .padding(.horizontal)
                                    RoundedRectangle(cornerRadius: 37.0)
                                        .foregroundColor(.primaryInvert)
                                        .opacity(0.7)
                                        .frame(height:200)
                                        .padding(.horizontal)
                                    Spacer()
                                }
                            })
                        .gesture(
                            DragGesture()
                                .onEnded({
                                    value in
                                    if value.translation.height > 60{
                                        offset = 1.7
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                                    else if value.translation.height < -60{
                                        offset = 0.1
                                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                    }
                                    scrollOffset = 0
                                })
                                .onChanged({
                                    value in
                                    scrollOffset = value.translation.height
                                })
                        )
                        .offset(y: scrollOffset)
                        .animation(.spring(response: 0.2, dampingFraction: 1, blendDuration: 0.4))
                }
                .zIndex(2)
                .transition(.move(edge: .bottom))
            }
            if selection == 2{
                Color.primaryInvert
                    .transition(.opacity)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(0)
            }
            VStack{
                Spacer().frame(height:UIScreen.main.bounds.height*0.9)
                RoundedRectangle(cornerRadius: 50)
                    .frame(height:60)
                    .padding()
                    .foregroundColor(.primaryInvert)
                    .shadow(radius: 10)
                    .overlay(
                        ZStack{
                            HStack{
                                Spacer()
                                    .frame(width: UIScreen.main.bounds.width/24, alignment: .center)
                                Button(action: {withAnimation{selection = 0}}) {
                                    Image(systemName: "newspaper")
                                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                                        .foregroundColor(selection != 0 ? .gray : .primary)
                                }
                                .frame(width: UIScreen.main.bounds.width/4, alignment: .center)
                                Spacer()
                                Button(action: {withAnimation{selection = 1}}) {
                                    Image(systemName: "rectangle.split.3x3")
                                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                                        .foregroundColor(selection != 1 ? .gray : .primary)
                                }
                                .frame(width: UIScreen.main.bounds.width/4, alignment: .center)
                                Spacer()
                                Button(action: {withAnimation{selection = 2}}) {
                                    Image(systemName: "gear")
                                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                                        .foregroundColor(selection != 2 ? .gray: .primary)
                                }
                                .frame(width: UIScreen.main.bounds.width/4, alignment: .center)
                                Spacer()
                                    .frame(width: UIScreen.main.bounds.width/24, alignment: .center)
                            }
                            .zIndex(1)
                            HStack{
                                Spacer()
                                    .frame(width: UIScreen.main.bounds.width/48)
                                if selection == 1 || selection == 2{
                                    Spacer()
                                }
                                RoundedRectangle(cornerRadius: 50)
                                    .foregroundColor(Color.gray.opacity(0.5))
                                    .frame(width: UIScreen.main.bounds.width*0.28, height: UIScreen.main.bounds.height/20)
                                    .zIndex(0)
                                    .animation(
                                        .spring(response: 0.4, dampingFraction: 1, blendDuration: 1)
                                    )
                                    .offset(x: sliderOffset)
                                if selection == 0 || selection == 1{
                                    Spacer()
                                }
                                Spacer()
                                    .frame(width: UIScreen.main.bounds.width/48)
                            }
                            .gesture(DragGesture()
                                .onEnded({
                                    value in
                                    if value.translation.width > 0 && selection != 2{
                                        selection += 1
                                    }
                                    else if value.translation.width < 0 && selection != 0{
                                        selection -= 1
                                    }
                                    sliderOffset = 0
                                })
                                .onChanged({
                                    value in
                                    sliderOffset = value.translation.width/10
                                })
                            )
                        }
                    )
            }
            .zIndex(2)
        }
    }
}

struct DashboardMobile_Previews: PreviewProvider {
    static var previews: some View {
        DashboardMobile()
    }
}

