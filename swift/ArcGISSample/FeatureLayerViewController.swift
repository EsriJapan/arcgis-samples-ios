//
//  2DLayerViewController.swift
//  ArcGISSample
//
//  Created by esrij on H29/02/22.
//  Copyright © 平成29年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class FeatureLayerViewController: UIViewController{
    
    var sceneView: AGSSceneView!
    
    
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
        surface.elevationExaggeration = 1.0
        scene.baseSurface = surface
        
        // 地図を表示する視点を設定する
        let camera = AGSCamera(latitude: 42.314235, longitude: 140.994363, altitude: 150, heading: 250, pitch: 90, roll: 300)
        self.sceneView.setViewpointCamera(camera)
        
        
        // 室蘭市のオープンデータで公開されている土砂災害特別警戒区域（急傾斜地）を表示する
        // http://library-muroran.opendata.arcgis.com/datasets/afbeb0a89551498eb9442b9f9f9143e6_0
        // データソース（フィーチャ サービス）の URL を指定して、主題表示用のフィーチャ レイヤーを作成する
        let url = URL(string: "https://services.arcgis.com/Jv1EECU3IM4ZRUev/arcgis/rest/services/Muroran_Doshasaigai4/FeatureServer/0")
        let featureTable = AGSServiceFeatureTable(url: url!)
        let featureLayer = AGSFeatureLayer(featureTable: featureTable)
        featureLayer.opacity = 0.5
        
        // フィーチャ レイヤーのレンダラーを設定する
        let symbol = AGSSimpleFillSymbol(style: .solid, color: UIColor.red, outline: nil)
        let renderer = AGSSimpleRenderer(symbol: symbol)
        featureLayer.renderer = renderer
        
        // 作成したフィーチャ レイヤーを地図ビューに追加する
        self.sceneView.scene?.operationalLayers.add(featureLayer)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
