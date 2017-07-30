//
//  VectorLayerViewController.swift
//  ArcGISSample
//
//  Created by esrij on H29/02/22.
//  Copyright © 平成29年 esrij. All rights reserved.
//

import UIKit
import ArcGIS

class ExtrusionRendererViewController: UIViewController{
    
    var sceneView: AGSSceneView!
    var featureTable: AGSServiceFeatureTable!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // 3D 表示用の地図ビューを作成する
        self.sceneView = AGSSceneView(frame: view.bounds)
        self.view.addSubview(self.sceneView)
        
        // 地図の背景を地形図に設定する
        let scene = AGSScene(basemapType: AGSBasemapType.topographic)
        self.sceneView.scene = scene
        
        // 地図を表示する視点を設定する
        let camera = AGSCamera(latitude: 25.745912, longitude: 134.226785, altitude: 1000000, heading: 10, pitch: 45, roll: 300)
        self.sceneView.setViewpointCamera(camera)
        
        
        // ArcGIS Online で公開されている日本の都道府県のデータを表示する
        // http://www.arcgis.com/home/item.html?id=bf1517e6867c416d817a46d0b444dc5f
        // データソース（フィーチャ サービス）の URL を指定して、主題表示用のフィーチャ レイヤーを作成する        
        let urlString = "https://services.arcgis.com/wlVTGRSYTzAbjjiC/arcgis/rest/services/単純化都道府県/FeatureServer/0";
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        self.featureTable = AGSServiceFeatureTable(url: URL(string: encodedUrlString!)!)
        self.featureTable.featureRequestMode = .manualCache
        
        // グラフィック表示用のレイヤーを地図ビューに追加する
        let graphicsOverlay = AGSGraphicsOverlay()
        self.sceneView.graphicsOverlays.add(graphicsOverlay)
        
        // フィーチャ レイヤーから手動でデータ（フィーチャ）を取得し、グラフィック表示用のレイヤーに追加する
        // フィーチャの取得（検索）時のパラメーターを設定
        let params = AGSQueryParameters()
            
        // 全てのフィーチャを取得する
        params.whereClause = "1 = 1"
        
        // フィーチャの属性も取得する（outFields の配列に "*" を指定すると全ての属性を取得する）
        self.featureTable.populateFromService(with: params, clearCache: true, outFields: ["*"]) {(result, error) -> Void in
            if let error = error {
                print("Error:\(error.localizedDescription)")
            } else {
                
                // フィーチャの取得に成功
                let enumr = result?.featureEnumerator()
                for feature in enumr! {
                    
                    // 取得された各フィーチャをグラフィック表示用のレイヤーに追加する
                    let myFeature = feature as! AGSFeature
                    let attributes = myFeature.attributes.copy() as! NSDictionary
                    let geometry = AGSGeometryEngine.simplifyGeometry(myFeature.geometry!)
                    let graphic = AGSGraphic(geometry: geometry, symbol: nil, attributes: attributes as? [String : Any])
                    graphicsOverlay.graphics.add(graphic)
                    
                }
                
                // 全てのフィーチャにランダムなシンボルを設定して表示する
                // フィーチャの属性に応じてシンボルを個別に設定する個別値レンダラーを作成する
                let myRenderer = AGSUniqueValueRenderer()
                // レンダラーに使用する属性フィールドの名前を指定する（FID フィールドには各フィーチャにユニークな値が格納されている）
                myRenderer.fieldNames = ["FID"]
                myRenderer.uniqueValues = []
                
                for i in 0 ..< enumr!.allObjects.count {
                    
                    // FID の値ごとにランダム色でシンボルを作成してレンダラーに設定する
                    let red:CGFloat = CGFloat(drand48())
                    let green:CGFloat = CGFloat(drand48())
                    let blue:CGFloat = CGFloat(drand48())
                    let randomColor = UIColor(red: red, green: green, blue: blue, alpha: 0.8)
                    let lineSymbol = AGSSimpleLineSymbol(style: .solid, color: UIColor.black, width: 0.5)
                    let fillSymbol = AGSSimpleFillSymbol(style: .solid, color: randomColor, outline: lineSymbol)
                    let value = AGSUniqueValue(description: "", label: "", symbol: fillSymbol, values: [i + 1])
                    myRenderer.uniqueValues.append(value)

                }
                
                
                // 指定した高さの値で各フィーチャの形状を立ち上げるようにレンダラーを設定する
                myRenderer.sceneProperties?.extrusionMode = .absoluteHeight
                // 高さの値が格納されているフィーチャの属性フィールドを設定する（"SUM_P_NUM" フィールドには各県の人口数が格納されている）
                myRenderer.sceneProperties?.extrusionExpression = "[SUM_P_NUM]/50"
                // グラフィック表示用のレイヤーに作成したレンダラーを設定する
                graphicsOverlay.renderer = myRenderer
                
            }

            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
