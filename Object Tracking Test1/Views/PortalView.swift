//
//  PortalView.swift
//  ObjectTracking
//
//  Created by mac on 2024/8/27.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI
import RealityKit

struct PortalView : View {
    
    
    var body: some View {
        RealityView { content in
            let world = makeWorld()
            let portal = await makePortal(world: world)

            content.add(world)
            content.add(portal)
        }
    }
}

@MainActor public func makeWorld() -> Entity {
    let world = Entity()
    world.components[WorldComponent.self] = .init()

    let environment = try! EnvironmentResource.load(named: "SolarSystem")
    world.components[ImageBasedLightComponent.self] = .init(source: .single(environment),
                                                            intensityExponent: 1)
    world.components[ImageBasedLightReceiverComponent.self] = .init(imageBasedLight: world)

    let earth = try! Entity.load(named: "360")
//    let moon = try! Entity.load(named: "Moon")
//    let sky = try! Entity.load(named: "Scene")
    world.addChild(earth)
//    world.addChild(moon)
//    world.addChild(sky)

    return world
}

@MainActor public func makePortal(world: Entity) async -> Entity {
    let portal = Entity()
    let portalMeshEntity = try! await ModelEntity(named: "PS5")
    
    // 获取加载模型的 mesh
    if let modelComponent = portalMeshEntity.components[ModelComponent.self] {
        portal.components[ModelComponent.self] = ModelComponent(mesh: modelComponent.mesh,
                                                                materials: [PortalMaterial()])
    } else {
        print("Error: PS5 model does not have a ModelComponent.")
    }
    
    portal.components[PortalComponent.self] = .init(target: world)

    return portal
}
