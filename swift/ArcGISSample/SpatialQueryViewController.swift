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
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        // 道路地図レイヤー表示用のマップを作成する
        mapView = AGSMapView(frame: view.bounds)
        view.addSubview(mapView)
        let map = AGSMap(basemapType: AGSBasemapType.streets, latitude: 35.854418, longitude: 139.915135, levelOfDetail: 18)
        mapView.map = map
        
        // マップをホールド時に拡大鏡の表示を無効にする
        mapView.interactionOptions.isMagnifierEnabled = false
        
        // マップ画面のタッチ操作のデリゲートを設定する
        mapView.touchDelegate = self

        
        // フィーチャ検索用のフィーチャ レイヤーを追加（流山市のオープンデータ:AED設置場所）
        let flayerUrl = URL(string: "https://services.arcgis.com/CmCcqeRAPUx17PGk/arcgis/rest/services/AED_2_201506/FeatureServer/0")
        featureTable = AGSServiceFeatureTable(url: flayerUrl!)
        
        // フィーチャ レイヤーのフィーチャのリクエスト モードを手動に設定
        featureTable.featureRequestMode = .manualCache
        let featureLayer = AGSFeatureLayer(featureTable: featureTable)
        map.operationalLayers.add(featureLayer)
        
        
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
        

        // 検索結果表示用のグラフィックス オーバレイの追加
        resultGraphicsOverlay = AGSGraphicsOverlay()
        mapView.graphicsOverlays.add(resultGraphicsOverlay)
        
        
    }
    
    
    
    func geoView(_ geoView: AGSGeoView, didLongPressAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        
        print("Tap")
        
        // マップ上をホールドしながら指を動かして検索範囲を描画する
        // マップ上をホールド時に、フリーハンド用のポリゴンを新規に作成する
        resultGraphicsOverlay.graphics.removeAllObjects()
        polygonBuilder = AGSPolygonBuilder(spatialReference: mapView.spatialReference)
        
        // ホールドした地点（ポイント）をポリゴンの頂点に追加する
        polygonBuilder.add(mapPoint)
        
        
    }
    
    
    func geoView(_ geoView: AGSGeoView, didMoveLongPressToScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        
        print("Move")
        
        // マップ上をホールド中に指を動かしたら、動かした地点をポリゴンの頂点として追加する
        polygonBuilder.add(mapPoint)
        
        // ポリゴンからグラフィックを作成し、グラフィックス オーバレイに追加
        // 指を動かしたらグラフィックを再作成する
        resultGraphicsOverlay.graphics.removeAllObjects()
        let myPolygonSymbol = AGSSimpleFillSymbol()
        myPolygonSymbol.color = UIColor.orange.withAlphaComponent(0.5)
        myPolygonSymbol.outline?.color = UIColor.clear
        let polygonGraphic = AGSGraphic(geometry: polygonBuilder.toGeometry(), symbol: myPolygonSymbol, attributes: nil)
        resultGraphicsOverlay.graphics.add(polygonGraphic)
        
    }
    
    
    func geoView(_ geoView: AGSGeoView, didEndLongPressAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {

        
        print("End")
        
        // マップ上から指を離したら、作成したポリゴンをもとに空間検索を実行
        // フィーチャ検索用のパラメータを設定
        let queryParameters = AGSQueryParameters()
        queryParameters.geometry = AGSGeometryEngine.simplifyGeometry(polygonBuilder.toGeometry())
        queryParameters.spatialRelationship = .contains
        
        // フィーチャの検索を実行
        featureTable.queryFeatures(with: queryParameters, completion:{ (result, error) -> Void in
            if let error = error {
                
                print("Error:\(error.localizedDescription)")
                
            } else {
                
                let mySymbol = AGSSimpleMarkerSymbol(style: .circle, color: UIColor.white, size: 10)
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
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
                
                
            }
        })

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
