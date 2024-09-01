//
//  VirtualHandView.swift
//  Object Tracking Test1
//
//  Created by mac on 2024/8/29.
//

import GestureKit
import RealityKit
import SwiftUI

struct ContentViewer {

  let virtualHands: VirtualHands
  
  init() {
    let handsConfiguration = VirtualHandsConfiguration(left: HandConfiguration(color: .blue, usdz: HandConfiguration.defaultModel(chirality: .left)),
    right: HandConfiguration(color: .red, usdz: HandConfiguration.defaultModel(chirality: .right)),
    handRenderOptions: [.model, .joints, .bones])
    virtualHands = VirtualHands(configuration: handsConfiguration)
  }

}

extension ContentViewer: View {

  var body: some View {
    realityView
  }

  private var realityView: some View {
    RealityView { content in
    
      let roott = Entity()
      content.add(roott)
    
      do {
        let (left, right) = try virtualHands.createVirtualHands()
        
        roott.addChild(left)
        roott.addChild(right)
      } catch {
        print("Failed to add virtual hands to simulation: \(error.localizedDescription)")
      }

    }
    .task {
      await virtualHands.startSession()
    }
    .task {
      await virtualHands.startHandTracking()
    }
    .task {
      await virtualHands.handleSessionEvents()
    }
  }

}
