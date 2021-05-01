//
//  CustomSlider.swift
//  StundenPlan
//
//  Created by Sven Iffland on 13.01.21.
//

import SwiftUI

struct CustomSlider: View {
    @State private var sliderOffset:CGFloat = 0.0
    @Binding var selection: Int
    var body: some View {
        VStack{
            Spacer().frame(height:UIScreen.main.bounds.height*0.85)
            HStack{
                Spacer().frame(width:UIScreen.main.bounds.width*0.03)
                RoundedRectangle(cornerRadius: 10)
                    .frame(height:60)
                    .padding(10)
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
                                    .frame(width: UIScreen.main.bounds.width/20)
                                if selection == 1 || selection == 2{
                                    Spacer()
                                }
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.gray.opacity(0.5))
                                    .frame(width: UIScreen.main.bounds.width*0.24, height: UIScreen.main.bounds.height/20)
                                    .zIndex(0)
                                    .animation(
                                        .spring(response: 0.4, dampingFraction: 1, blendDuration: 1)
                                    )
                                    .offset(x: sliderOffset)
                                if selection == 0 || selection == 1{
                                    Spacer()
                                }
                                Spacer()
                                    .frame(width: UIScreen.main.bounds.width/20)
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
                Spacer().frame(width:UIScreen.main.bounds.width*0.03)
            }
        }
    }
}

struct CustomSlider_Previews: PreviewProvider {
    static var previews: some View {
        CustomSlider(selection: .constant(0))
    }
}
