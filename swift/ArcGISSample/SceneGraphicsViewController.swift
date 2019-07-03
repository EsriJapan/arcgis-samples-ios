//
//  sceneGraphics.swift
//  ArcGISSample
//
//  Created by esrij on H29/02/22.
//  Copyright © 平成29年 esrij. All rights reserved.
//

import UIKit
import ArcGIS

class SceneGraphicsViewController: UIViewController {
    
    private var sceneView:AGSSceneView!
    private var drapedGraphicsOverlay = AGSGraphicsOverlay()
    private var relativeGraphicsOverlay = AGSGraphicsOverlay()
    private var absoluteGraphicsOverlay = AGSGraphicsOverlay()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // 3D 表示用の地図ビューを作成する
        self.sceneView = AGSSceneView(frame: view.bounds)
        self.view.addSubview(self.sceneView)
        
        // 地図の背景を地形図に設定する
        let scene = AGSScene(basemap: AGSBasemap.topographic())
        self.sceneView.scene = scene
        
        // ArcGIS Online の標高サービスを標高データソースに設定する
        let surface = AGSSurface()
        let elevationSource = AGSArcGISTiledElevationSource(url: URL(string: "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!)
        // 標高データソースを地図ビューに設定する
        surface.elevationSources.append(elevationSource)
        scene.baseSurface = surface
        
        // 地図を表示する視点を設定する
        let camera = AGSCamera(latitude: 35.160556, longitude: 138.677778, altitude: 10000, heading: 10, pitch: 90, roll: 0)
        self.sceneView.setViewpointCamera(camera)
        
        // グラフィック表示用のレイヤーに、グラフィックを表示する際の高さの指定方法のプロパティを設定する
        //Draped（3D 地形の地表面上に表示）、Relative（地表面からの相対値を指定して表示）、Absolute（高度を指定して表示）
        self.drapedGraphicsOverlay.sceneProperties?.surfacePlacement = .draped
        self.relativeGraphicsOverlay.sceneProperties?.surfacePlacement = .relative
        self.absoluteGraphicsOverlay.sceneProperties?.surfacePlacement = .absolute
        
        // グラフィック表示用のレイヤーを地図ビューに追加する
        self.sceneView.graphicsOverlays.addObjects(from: [self.drapedGraphicsOverlay, self.relativeGraphicsOverlay, self.absoluteGraphicsOverlay])
        
        self.addGraphics()
        
        
    }
    
    
    private func addGraphics() {
        
        // 表示する位置（経度、緯度、高さ）とシンボルを設定してグラフィックを作成し、グラフィック表示用のレイヤーに追加する
        let point = AGSPoint(x: 138.727778, y: 35.360556, z: 4000, spatialReference: AGSSpatialReference.wgs84())
        
        // 3D 地形の地表面上に表示するグラフィック
        self.drapedGraphicsOverlay.graphics.addObjects(from: [AGSGraphic(geometry: point, symbol: self.pointSymbol(), attributes: nil), AGSGraphic(geometry: point, symbol: self.textSymbol(text: "地表面"), attributes: nil)])
        
        // 地表面からの相対値を指定して表示するグラフィック
        self.relativeGraphicsOverlay.graphics.addObjects(from: [AGSGraphic(geometry: point, symbol: self.modelSymbol(), attributes: nil), AGSGraphic(geometry: point, symbol: self.textSymbol(text: "相対位置"), attributes: nil)])
        
        // 高度を指定して表示するグラフィック
        self.absoluteGraphicsOverlay.graphics.addObjects(from: [AGSGraphic(geometry: point, symbol: self.pointSymbol(), attributes: nil), AGSGraphic(geometry: point, symbol: self.textSymbol(text: "絶対位置"), attributes: nil)])
        
    }
    
    
    private func pointSymbol() -> AGSSimpleMarkerSceneSymbol {
        // マーカー シンボルを作成する
        return AGSSimpleMarkerSceneSymbol(style: .sphere, color: UIColor.red, height: 200, width: 200, depth: 200, anchorPosition: .center)
    }
    
    private func textSymbol(text: String) -> AGSTextSymbol {
        // 表示するテキストを指定してテキスト シンボルを作成する
        let textSym = AGSTextSymbol(text: text, color: UIColor.black, size: 20, horizontalAlignment: .left, verticalAlignment: .middle)
        textSym.offsetX = 100
        textSym.fontFamily = "Hiragino Kaku Gothic ProN W6"
        return textSym
    }
    
    private func modelSymbol() -> AGSModelSceneSymbol {
        // 3D モデル ファイルのファイル名と拡張子を指定して 3D モデル シンボルを作成する
        return AGSModelSceneSymbol(name: "Bristol", extension: "3ds", scale: 100)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
