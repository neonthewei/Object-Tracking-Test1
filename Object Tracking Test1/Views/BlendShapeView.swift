//
//  BlendShapeView.swift
//  Object Tracking Test1
//
//  Created by mac on 2024/8/29.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct BlendShapeView: View {
    
    var body: some View {
        RealityView { content in
            
            // 加载并设置 HeroPlant 模型
            if let heroPlantEntity = createHeroPlantEntity() {
                // 设置 BlendShapeWeightsComponent（如果需要）
                HeroPlantComponent.setupBlendShapeWeightsComponent(for: heroPlantEntity)
                
                // 假设我们想要将第一个 blendShape 的权重设置为 [1]
                let newWeights: [Float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
                HeroPlantComponent.updateBlendShapeWeights(for: heroPlantEntity, blendWeightsIndex: 0, newWeights: newWeights)
                
                // 添加 HeroPlantEntity 到 RealityView 的内容中
                content.add(heroPlantEntity)
                
            }
        }
    }
    
    // 加载模型并设置 BlendShapeWeightsComponent 的示例
    func createHeroPlantEntity() -> Entity? {
        do {
            // 加载3D模型
            let modelEntity = try ModelEntity.load(named: "cube_distort", in: realityKitContentBundle)
            let entity = Entity()
            entity.addChild(modelEntity)
            print("Model loaded successfully")
            return entity
        } catch {
            print("Failed to load model: \(error)")
            return nil
        }
    }

    
    struct HeroPlantComponent: Component, Codable {
        
        // 设置 BlendShapeWeightsComponent
        static func setupBlendShapeWeightsComponent(for entity: Entity) {
            guard let modelComponentEntity = findModelComponentEntity(entity: entity),
                  let modelComponent = modelComponentEntity.components[ModelComponent.self]
            else {
                print("ModelComponent not found")
                return
            }
            
            let blendShapeWeightsMapping = BlendShapeWeightsMapping(meshResource: modelComponent.mesh)
                        
            // 创建并设置 BlendShapeWeightsComponent
            entity.components.set(BlendShapeWeightsComponent(weightsMapping: blendShapeWeightsMapping))
        }
        
        
        
        
        
        // 更新 BlendShapeWeightsComponent 的权重
        static func updateBlendShapeWeights(for entity: Entity, blendWeightsIndex: Int, newWeights: [Float]) {
            guard var originalComponent = entity.components[BlendShapeWeightsComponent.self] else {
                print("BlendShapeWeightsComponent not found")
                return
            }
            
            print("\(originalComponent.weightSet[blendWeightsIndex])")
            print("Weights before update: \(originalComponent.weightSet[blendWeightsIndex].weights)")

            // 更新指定索引的权重
            for weightIndex in 0..<newWeights.count {
                originalComponent.weightSet[blendWeightsIndex].weights[weightIndex] = newWeights[weightIndex]
            }
            
            // 将修改后的组件重新设置回实体的组件集合
            entity.components.set(originalComponent)
            
            print("\(originalComponent.weightSet[blendWeightsIndex])")
            print("Weights after update: \(originalComponent.weightSet[blendWeightsIndex].weights)")
        }
        
        
        
        
        
        // Helper function to find the entity with a ModelComponent
        static func findModelComponentEntity(entity: Entity) -> Entity? {
            if entity.components.has(ModelComponent.self) {
                return entity
            }
            for child in entity.children {
                if let foundEntity = findModelComponentEntity(entity: child) {
                    return foundEntity
                }
            }
            return nil
        }
    }
   
}
