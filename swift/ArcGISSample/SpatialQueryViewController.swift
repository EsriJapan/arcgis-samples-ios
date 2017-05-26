//
//  SpatialQueryViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/09/25.
//  Copyright © 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS

class SpatialQueryViewController: UIViewController, AGSGeoViewTouchDelegate {
    
    
    var mapView: AGSMapView!
    var featureTable: AGSServiceFeatureTable!
    var polygonBuilder: AGSPolygonBuilder!
    var resultGraphicsOverlay: AGSGraphicsOverlay!
    var sketchEditor:AGSSketchEditor!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // 道路地図レイヤー表示用のマップを作成する
        mapView = AGSMapView(frame: view.bounds)
        view.addSubview(mapView)
        let map = AGSMap(basemapType: AGSBasemapType.streets, latitude: 35.854418, longitude: 139.915135, levelOfDetail: 14)
        mapView.map = map
        
        // マップの拡大鏡の表示を無効にする
        mapView.interactionOptions.isMagnifierEnabled = false
        

        // フィーチャ検索用のフィーチャ レイヤーを追加（流山市のオープンデータ:AED設置場所）
        let flayerUrl = URL(string: "https://services.arcgis.com/CmCcqeRAPUx17PGk/arcgis/rest/services/AED_2_201506/FeatureServer/0")
        featureTable = AGSServiceFeatureTable(url: flayerUrl!)
        
        // フィーチャ レイヤーのフィーチャのリクエスト モードを設定
        featureTable.featureRequestMode = .manualCache
        let featureLayer = AGSFeatureLayer(featureTable: featureTable)
        map.operationalLayers.add(featureLayer)
        

        // 検索結果表示用のグラフィックス オーバレイの追加
        resultGraphicsOverlay = AGSGraphicsOverlay()
        mapView.graphicsOverlays.add(resultGraphicsOverlay)
        
        
        // スケッチ エディターの作成
        self.sketchEditor = AGSSketchEditor()
        self.mapView.sketchEditor =  self.sketchEditor
        // スケッチするジオメトリをフリーハンド ポリゴンに設定
        self.sketchEditor.start(with: nil, creationMode: .freehandPolygon)
        // スケッチ エディターのジオメトリ変更時の通知を登録
        NotificationCenter.default.addObserver(self, selector: #selector(SpatialQueryViewController.respondToGeomChanged), name: NSNotification.Name.AGSSketchEditorGeometryDidChange, object: nil)

        
        // フィーチャの取得（検索）時のパラメーターを設定
        let params = AGSQueryParameters()
        // 全てのフィーチャを取得する
        params.whereClause = "1 = 1"
        // 検索結果にフィーチャの全属性（outFields の配列に "*" を指定）を含める
        self.featureTable.populateFromService(with: params, clearCache: true, outFields: ["*"]) {(result, error) -> Void in
            if let error = error {
                print("Error:\(error.localizedDescription)")
            } else {
                // フィーチャ数を表示
                print(result?.featureEnumerator().allObjects.count ?? "0")
            }
        }

        
    }
    
    
    func respondToGeomChanged() {
        
        if !self.sketchEditor.geometry!.isEmpty {
        
            // 検索結果のグラフィックを削除
            self.resultGraphicsOverlay.graphics.removeAllObjects()

        
            // スケッチ エディターで作成したポリゴンをもとに空間検索を実行
            // フィーチャ検索用のパラメータを設定
            let queryParameters = AGSQueryParameters()
            queryParameters.geometry = AGSGeometryEngine.simplifyGeometry(self.sketchEditor.geometry!)
            queryParameters.spatialRelationship = .contains
            
        
            // フィーチャの検索を実行
            featureTable.queryFeatures(with: queryParameters, fields: .loadAll, completion:{ (result, error) -> Void in
                if let error = error {
                
                    print("Error:\(error.localizedDescription)")
                
                } else {
                
                    let mySymbol = AGSSimpleMarkerSymbol(style: .circle, color: UIColor.blue, size: 10)
                    var count:Int = 0
                
                    let enumr = result?.featureEnumerator()
                    for feature in enumr! {
                    
                        // 検索結果のフィーチャにシンボルを設定してグラフィックス オーバレイに追加
                        let feature = feature as! AGSFeature
                        let attributes = feature.attributes.copy() as! NSDictionary
                        let graphic = AGSGraphic(geometry: feature.geometry, symbol: mySymbol, attributes: attributes as? [String : Any])
                        self.resultGraphicsOverlay.graphics.add(graphic)
                    
                        // フィーチャの台数フィールドの値を取得しカウント
                        count = count + (graphic.attributes["台数"] as! Int)
                    }
                
                    // 検索された全フィーチャの台数フィールドの合計値を表示
                    let alert = UIAlertController(title:"検索結果", message: String(count) + " 台の AED が見つかりました。", preferredStyle: UIAlertControllerStyle.alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction!) -> Void in
                        // スケッチ エディターで作成したポリゴンを削除
                        self.sketchEditor.clearGeometry()
                    })
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            })
        
        }
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
