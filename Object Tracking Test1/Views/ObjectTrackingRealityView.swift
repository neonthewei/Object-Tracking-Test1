/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The view shown inside the immersive space.
*/

import RealityKit
import ARKit
import SwiftUI

@MainActor
struct ObjectTrackingRealityView: View {
    
    var appState: AppState
    
    @State private var portalScale: CGFloat = 1.0
    
    var root = Entity()
    
    @State private var objectVisualizations: [UUID: ObjectAnchorVisualization] = [:]
    
    @State private var attachmentEntity3: Entity? // 保存 h3 实体的引用


    var body: some View {
        
        RealityView { content, attachments in
            content.add(root)
        
            Task {
                let objectTracking = await appState.startTracking()
                guard let objectTracking else {
                    return
                }
                
                // Wait for object anchor updates and maintain a dictionary of visualizations
                // that are attached to those anchors.
                for await anchorUpdate in objectTracking.anchorUpdates {
                    let anchor = anchorUpdate.anchor
                    let id = anchor.id
                    
                    switch anchorUpdate.event {
                    case .added:
                        // Create a new visualization for the reference object that ARKit just detected.
                        // The app displays the USDZ file that the reference object was trained on as
                        // a wireframe on top of the real-world object, if the .referenceobject file contains
                        // that USDZ file. If the original USDZ isn't available, the app displays a bounding box instead.
                        let model = appState.referenceObjectLoader.usdzsPerReferenceObjectID[anchor.referenceObject.id]
                        let visualization = ObjectAnchorVisualization(for: anchor, withModel: model)
                        self.objectVisualizations[id] = visualization
                        root.addChild(visualization.entity)
                        
                        // 获取并附加自定义标签
                        if let attachmentEntity = attachments.entity(for: "h1") {
                            visualization.entity.addChild(attachmentEntity)
                            attachmentEntity.position = [0, 0.02, -0.1]
                            attachmentEntity.transform.rotation = simd_quatf(angle: .pi / 2, axis: [-1, 0.1, 0])
                            attachmentEntity.components.set(HoverEffectComponent())
                           }
                        
                        if let attachmentEntity2 = attachments.entity(for: "h2") {
                            visualization.entity.addChild(attachmentEntity2)
                            attachmentEntity2.position = [0.2, 0, 0]
                            }
                        
                        if let entity = attachments.entity(for: "h3") {
                                                   visualization.entity.addChild(entity)
                                                   entity.position = [0, 0, 0]
                                                   self.attachmentEntity3 = entity // 保存引用
                                                   updateScale() // 初始缩放
                                               }
                        
                        
                    case .updated:
                        objectVisualizations[id]?.update(with: anchor)
                    case .removed:
                        objectVisualizations[id]?.entity.removeFromParent()
                        objectVisualizations.removeValue(forKey: id)
                    }
                }
            }
        } 
        attachments: {
            Attachment(id: "h1") {
                UIView(portalScale: $portalScale)
            }
            Attachment(id: "h2") {
//                BlendShapeView()
            }
            Attachment(id: "h3") {
                PortalView()
            }
        }
        .onAppear() {
            print("Entering immersive space.")
            appState.isImmersiveSpaceOpened = true
        }
        .onDisappear() {
            print("Leaving immersive space.")
            
            for (_, visualization) in objectVisualizations {
                root.removeChild(visualization.entity)
            }
            objectVisualizations.removeAll()
            
            appState.didLeaveImmersiveSpace()
        }
        .onChange(of: portalScale) {
                 DispatchQueue.main.async {
                     print("Portal Scale changed to: \(portalScale)") // Debugging
                     updateScale()
                 }
             }
    }
    
    private func updateScale() {
            if let entity = attachmentEntity3 {
                let scaleVector = SIMD3<Float>(repeating: Float(portalScale))
                entity.transform.scale = scaleVector
                print("Updated scale to \(scaleVector)") // Debugging output
            }
        }
    
}

