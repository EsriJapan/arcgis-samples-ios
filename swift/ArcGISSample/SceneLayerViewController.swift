//
//  MapAnimationViewController.swift
//  ArcGISSample
//
//  Created by esrij on H29/02/17.
//  Copyright © 平成29年 esrij. All rights reserved.
//

import UIKit
import ArcGIS
import CoreMotion


class SceneLayerViewController: UIViewController{
    
    
    private var sceneView:AGSSceneView!
    private var sceneLayer: AGSArcGISSceneLayer!
    
    var motionManager: CMMotionManager!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        
        // 3D 表示用の地図ビューを作成する
        self.sceneView = AGSSceneView(frame: view.bounds)
        self.view.addSubview(self.sceneView)
        
        
        // 地図の背景を衛星画像に設定する
        let scene = AGSScene(basemapType: AGSBasemapType.imagery)
        self.sceneView.scene = scene
        
        // ArcGIS Online の標高サービスを標高データソースに設定する
        let surface = AGSSurface()
        let elevationSource = AGSArcGISTiledElevationSource(url: URL(string: "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!)
        
        // 標高データソースを地図ビューに設定する
        surface.elevationSources.append(elevationSource)
        scene.baseSurface = surface
        
        
        // Web サービス（シーン サービス）の URL を指定して 3D モデル表示用のシーン レイヤーを作成する
        let sceneLayer1 = AGSArcGISSceneLayer(url: URL(string: "https://scenesampleserverdev.arcgis.com/arcgis/rest/services/Hosted/DevB_BuildingShell_Textured/SceneServer/layers/0")!)
        let sceneLayer2 = AGSArcGISSceneLayer(url: URL(string: "https://scenesampleserverdev.arcgis.com/arcgis/rest/services/Hosted/DevB_Trees/SceneServer/layers/0")!)
        let sceneLayer3 = AGSArcGISSceneLayer(url: URL(string: "https://scenesampleserverdev.arcgis.com/arcgis/rest/services/Hosted/DevA_BuildingShell_Textured/SceneServer/layers/0")!)
        let sceneLayer4 = AGSArcGISSceneLayer(url: URL(string: "https://scenesampleserverdev.arcgis.com/arcgis/rest/services/Hosted/Existing_BuildingShell/SceneServer/layers/0")!)
        
        
        // 作成したシーン レイヤーを地図ビューに追加する
        scene.operationalLayers.addObjects(from: [sceneLayer1, sceneLayer2, sceneLayer3, sceneLayer4])

        // 地図を表示する視点を設定する
        let camera = AGSCamera(latitude: 45.534228971124, longitude: -122.683544417081, altitude: 18.2814124021679, heading: 180, pitch: 100.3416162570851, roll: 0)
        self.sceneView.setViewpointCamera(camera)

        
        // CMMotionManager を作成する
        self.motionManager = CMMotionManager()
        self.motionManager.deviceMotionUpdateInterval = 0.1
        
        // UISegmentedControl を作成する
        let segmentedControl = UISegmentedControl(items: ["ジャイロ無効","ジャイロ有効"])
        segmentedControl.frame = CGRect(x: 10, y: view.frame.size.height - 50, width: 200, height: 30)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor.white
        segmentedControl.tintColor = UIColor.gray
        
        // セグメント切り替え時のイベントを追加する
        segmentedControl.addTarget(self, action: #selector(SceneLayerViewController.motionChanged(segment:)), for: UIControlEvents.valueChanged)
        self.view.addSubview(segmentedControl)

        
    }
    
    func motionChanged(segment: UISegmentedControl){
        
        // 「ジャイロ有効」が選択されたら、デバイスのモーション データの取得を開始する
        switch segment.selectedSegmentIndex {
        case 0:
            motionManager.stopDeviceMotionUpdates()
        case 1:
            self.startMotion()
        default: break
        }
        
    }
    
    func startMotion() {
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {(motionData, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            guard let data = motionData else {
                return
            }
            
            print(data.rotationRate.x)
            print(data.rotationRate.y)
            print(data.rotationRate.z)
            
            // デバイスの回転率を取得して、位置は固定した状態で視点を変更する
            // x方向の回転で視点を左右に振る
            let heading = -(data.rotationRate.x * 10)
            // y方向の回転で視点を上下に傾ける
            let pitch = data.rotationRate.y * 10
            let newCamera = self.sceneView.currentViewpointCamera().rotateAroundTargetPoint(self.sceneView.currentViewpointCamera().location, deltaHeading: heading, deltaPitch: pitch, deltaRoll: 0)
            self.sceneView.setViewpointCamera(newCamera)
            
        })
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
