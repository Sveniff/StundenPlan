//
//  CardView.swift
//  StundenPlan
//
//  Created by Sven Iffland on 13.01.21.
//

import SwiftUI

struct CardView: View {
    @State private var scrollOffset: CGFloat = 1
    @State private var offset: CGFloat = 1.1
    var body: some View {
        VStack{
            Spacer()
                .frame(height:UIScreen.main.bounds.height*offset)
            VStack{
                Spacer()
                    .frame(height: UIScreen.main.bounds.height*0.02)
                RoundedRectangle(cornerRadius: 60).frame(width: UIScreen.main.bounds.width*0.15, height: 5, alignment: .center)
                    .padding(.bottom)
                    .foregroundColor(Color.secondary)
                    .shadow(radius: 5)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.03)
                RoundedRectangle(cornerRadius:20)
                    .foregroundColor(.white)
                    .opacity(0.2)
                    .padding(.horizontal, UIScreen.main.bounds.width/20)
                    .shadow(radius: -1)
                    .overlay(ScrollView{

                    })
            }
            .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.height*0.5)
            .background(
                LinearGradient(gradient: Gradient(colors: [.gradient_top, .gradient_bottom]), startPoint: .top, endPoint: .bottom)
                            .mask(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 10))
            .gesture(
                DragGesture()
                    .onEnded({
                        value in
                        if value.translation.height > 60{
                            offset = 1.1
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                        else if value.translation.height < -60{
                            offset = 0.5
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        }
                        scrollOffset = 0
                    })
                    .onChanged({
                        value in
                        scrollOffset = ((offset == 1 ? -1 : 1) * value.translation.height) < 0 ? scrollOffset : value.translation.height
                    })
            )
            .offset(y: scrollOffset)
            .animation(.spring(response: 0.2, dampingFraction: 1, blendDuration: 0.4))
        }
        .shadow(radius: 10)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView()
    }
}
