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
    var featureLayer: AGSFeatureLayer!
    var sketchEditor:AGSSketchEditor!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // 道路地図レイヤー表示用のマップを作成する
        self.mapView = AGSMapView(frame: view.bounds)
        view.addSubview(self.mapView)
        let map = AGSMap(basemapType: AGSBasemapType.streets, latitude: 35.854418, longitude: 139.915135, levelOfDetail: 14)
        self.mapView.map = map
        
        // マップの拡大鏡の表示を無効にする
        self.mapView.interactionOptions.isMagnifierEnabled = false
        

        // フィーチャ検索用のフィーチャ レイヤーを追加（流山市のオープンデータ:AED設置場所）
        let flayerUrl = URL(string: "https://services.arcgis.com/CmCcqeRAPUx17PGk/arcgis/rest/services/AED_2_201506/FeatureServer/0")
        self.featureTable = AGSServiceFeatureTable(url: flayerUrl!)
        self.featureLayer = AGSFeatureLayer(featureTable: featureTable)
        map.operationalLayers.add(self.featureLayer!)

        // スケッチ エディターの作成
        self.sketchEditor = AGSSketchEditor()
        self.mapView.sketchEditor =  self.sketchEditor
        // スケッチするジオメトリをフリーハンド ポリゴンに設定
        self.sketchEditor.start(with: nil, creationMode: .freehandPolygon)
        // スケッチ エディターのジオメトリ変更時の通知を登録
        NotificationCenter.default.addObserver(self, selector: #selector(SpatialQueryViewController.respondToGeomChanged), name: NSNotification.Name.AGSSketchEditorGeometryDidChange, object: nil)
        
    }
    
    
    @objc func respondToGeomChanged() {
        
        // フリーハンド ポリゴン作成時
        if (self.sketchEditor!.geometry != nil) && !self.sketchEditor.geometry!.isEmpty {
        
            // フィーチャの選択状態をクリア
            self.featureLayer.clearSelection()

            // スケッチ エディターで作成したポリゴンをもとに空間検索を実行
            // フィーチャ検索用のパラメータを設定（ポリゴン内のフィーチャを検索）
            let queryParameters = AGSQueryParameters()
            queryParameters.geometry = AGSGeometryEngine.simplifyGeometry(self.sketchEditor.geometry!)
            queryParameters.spatialRelationship = .contains
            
            // フィーチャの検索を実行
            self.featureTable.queryFeatures(with: queryParameters, completion:{ (result, error) -> Void in
                if let error = error {
                
                    print("Error:\(error.localizedDescription)")
                
                } else {
                
                    // 検索結果のフィーチャを選択（ハイライト表示）
                    self.featureLayer.select((result?.featureEnumerator().allObjects)!)
                    
                    // 検索されたフィーチャの個数を表示
                    let count = result?.featureEnumerator().allObjects.count.description                    
                    let alert = UIAlertController(title:"検索結果", message: count! + "箇所に AED があります。", preferredStyle: UIAlertController.Style.alert)
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
