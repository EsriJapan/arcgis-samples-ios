//
//  SceneViewController.swift
//  ArcGISSample
//
//  Created by esrij on H29/02/16.
//  Copyright © 平成29年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class ElevationViewController: UIViewController{
    
    var sceneView: AGSSceneView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // 3D 表示用の地図ビューを作成する
        self.sceneView = AGSSceneView(frame: view.bounds)
        self.view.addSubview(self.sceneView)
        
        // 地図の背景を地形図に設定する
        let scene = AGSScene(basemapType: AGSBasemapType.topographic)
        self.sceneView.scene = scene
        
        // ArcGIS Online の標高サービスを標高データソースに設定する
        let surface = AGSSurface()
        let elevationSource = AGSArcGISTiledElevationSource(url: URL(string: "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!)
        
        // 標高データソースを地図ビューに設定する
        surface.elevationSources.append(elevationSource)
        scene.baseSurface = surface
        // 地図を表示する視点を設定する
        let camera = AGSCamera(latitude: 35.160556, longitude: 138.677778, altitude: 17000, heading: 10, pitch: 50, roll: 300)
        self.sceneView.setViewpointCamera(camera)
        
        // スライダーの作成
        let slider = UISlider(frame: CGRect(x: 0, y: 100, width: view.frame.size.width, height: 50))
        slider.minimumValue = 0.0
        slider.maximumValue = 10.0
        slider.addTarget(self, action: #selector(ElevationViewController.sliderEvent(sender:)), for: .valueChanged)
        view.addSubview(slider)
        
    }
    
    @objc func sliderEvent(sender: UISlider) {
        // 実際の標高値を誇張表現する際の係数を指定
        self.sceneView.scene?.baseSurface?.elevationExaggeration = sender.value
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
