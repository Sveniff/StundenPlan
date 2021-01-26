//
//  CardView.swift
//  StundenPlan
//
//  Created by Sven Iffland on 13.01.21.
//

import SwiftUI

struct CardView: View {
    @State private var scrollOffset: CGFloat = 0.0
    @State private var offset: CGFloat = 1.7
    var body: some View {
        HStack{
            Spacer()
                .frame(width: UIScreen.main.bounds.width*0.01)
            VStack{
                Spacer()
                    .frame(height:UIScreen.main.bounds.height*offset)
                LinearGradient(gradient: Gradient(colors: [.gradient_top, .gradient_bottom]), startPoint: .top, endPoint: .bottom)
//                    .opacity(0.8)
                    .mask(RoundedRectangle(cornerRadius: 10).offset(x: 0, y: 0))
                    .frame(height: UIScreen.main.bounds.height*1)
                    .shadow(radius: 10)
                    .overlay(
                        VStack{
                        //MARK:Scrollable View
                            
                            RoundedRectangle(cornerRadius: 60).frame(width: UIScreen.main.bounds.width*0.1, height: 5, alignment: .center)
                                .padding()
                                .foregroundColor(Color.secondary)
                                .shadow(radius: 5)
                                .frame(width: UIScreen.main.bounds.width, height: 50)
                            Spacer()
                                .frame(height: 20)
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
            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            Spacer()
                .frame(width: UIScreen.main.bounds.width*0.01)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView()
    }
}
