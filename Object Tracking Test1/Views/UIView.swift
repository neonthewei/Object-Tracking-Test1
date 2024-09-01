//
//  UIView.swift
//  Object Tracking Test1
//
//  Created by mac on 2024/8/29.
//

import SwiftUI
import RealityKit
import RealityKitContent


struct UIView: View {
    
    @Binding var portalScale: CGFloat
    @State private var isScaledUp = false
    @State private var timer: Timer?

    
    var body: some View {
        
        HStack{
            
//            Image("PS5Photo.jpg")
//                .resizable().aspectRatio(contentMode: .fit)
//                .clipShape(Circle())
//                .padding()
//                .frame(width: 20)
            
                Text("🤩PS5 Controller")
                    .font(.caption)
                    .padding()
            
            Button(action: {
                            if isScaledUp {
                                startScaleAnimation(from: 10, to: 1)

                            } else {
                                startScaleAnimation(from: 1, to: 10)
                            }
                            isScaledUp.toggle()
                        }) {
                            Text("Switch")
                        }
                        .font(.caption)
        }
        .padding(10)
        .glassBackgroundEffect()
    }
    
    private func startScaleAnimation(from: CGFloat, to: CGFloat) {
           timer?.invalidate() // 取消之前的动画
           let duration = 1.0 // 动画持续时间
           let steps = 50 // 动画帧数
           let stepDuration = duration / Double(steps)
           let delta = (to - from) / CGFloat(steps)
           
           var currentStep = 0
           
           timer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { _ in
               if currentStep < steps {
                   portalScale += delta
                   currentStep += 1
               } else {
                   portalScale = to
                   timer?.invalidate() // 动画结束后取消计时器
               }
           }
       }
}
