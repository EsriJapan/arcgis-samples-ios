//
//  SpatialQueryViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/09/25.
//  Copyright © 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS

class SpatialQueryViewController: UIViewController, AGSQueryTaskDelegate, AGSMapViewLayerDelegate, AGSMapViewTouchDelegate {
    
    
    var agsMapView: AGSMapView!
    var agsQueryTask: AGSQueryTask!
    
    var agsPolygon: AGSMutablePolygon!
    var agsGraphicsLayer: AGSGraphicsLayer!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        agsMapView.layerDelegate = self
        agsMapView.touchDelegate = self
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //フィーチャ検索用のフィーチャレイヤーの追加（流山市のオープンデータ:AED設置場所）        
        let flayerUrl = URL(string: "https://services.arcgis.com/CmCcqeRAPUx17PGk/arcgis/rest/services/AED_2_201506/FeatureServer/0")
        let agsFeatureLayer = AGSFeatureLayer(url: flayerUrl, mode: .onDemand)
        agsFeatureLayer?.outFields = ["*"]
        agsMapView.addMapLayer(agsFeatureLayer, withName:"Feature Layer")

        
        //グラフィックスレイヤーの追加
        agsGraphicsLayer = AGSGraphicsLayer()
        agsMapView.addMapLayer(agsGraphicsLayer, withName:"Graphics Layer")
        
        let envelope = AGSEnvelope.envelope(withXmin: 139.891126, ymin:35.831845, xmax:139.9517425, ymax:35.9132698000001, spatialReference:AGSSpatialReference(wkid: 104111)) as! AGSEnvelope
        agsMapView.zoom(to: envelope, animated: true)
        
        //検索するレイヤーのURLを指定してフィーチャ検索用タスク（AGSQueryTask）を作成
        agsQueryTask = AGSQueryTask(url: flayerUrl)
        agsQueryTask.requestCachePolicy = .reloadIgnoringLocalCacheData
        agsQueryTask.delegate = self
        
    }
    
    
    func mapView(_ mapView: AGSMapView!, didTapAndHoldAt screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [AnyHashable : Any]!) {
        
        print("Tap")
        
        //マップ上をホールドしながら指を動かして検索範囲を描画する
        //マップ上をホールド時に、フリーハンド用のポリゴンを新規に作成する
        agsGraphicsLayer.removeAllGraphics()
        agsPolygon = AGSMutablePolygon(spatialReference: agsMapView.spatialReference)
        
        //ホールドした地点（ポイント）をポリゴンの頂点に追加する
        agsPolygon.addRingToPolygon()
        agsPolygon.addPoint(toRing: mappoint)
        
    }
    
    func mapView(_ mapView: AGSMapView!, didMoveTapAndHoldAt screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [AnyHashable : Any]!) {
        
        print("Move")
        
        //マップ上をホールド中に指を動かしたら、動かした地点をポリゴンの頂点として追加する
        agsPolygon.addPoint(toRing: mappoint)
        
        //ポリゴンからグラフィックを作成し、グラフィックス レイヤーに追加
        //指を動かしたらグラフィックを再作成する
        agsGraphicsLayer.removeAllGraphics()
        let myPolygonSymbol = AGSSimpleFillSymbol()
        myPolygonSymbol.color = UIColor.orange.withAlphaComponent(0.5)
        myPolygonSymbol.outline.color = UIColor.clear
        let polygonGraphic = AGSGraphic(geometry: agsPolygon, symbol: myPolygonSymbol, attributes: nil)
        agsGraphicsLayer.addGraphic(polygonGraphic)
        
    }
    
    func mapView(_ mapView: AGSMapView!, didEndTapAndHoldAt screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [AnyHashable : Any]!) {
        
        print("End")
        
        //マップ上から指を離したら、作成したポリゴンをもとに空間検索を実行
        //フィーチャ検索用のパラメータを設定
        let agsQuery = AGSQuery()
        agsQuery.outFields = ["*"]
        agsQuery.returnGeometry = true
        agsQuery.outSpatialReference = agsMapView.spatialReference
        //フリーハンドポリゴン内に含まれるフィーチャを検索
        let agsGeomEngine = AGSGeometryEngine.default()
        agsQuery.geometry = agsGeomEngine?.simplifyGeometry(agsPolygon)
        agsQuery.spatialRelationship = AGSSpatialRelationship.contains
        
        //フィーチャの検索を実行
        agsQueryTask.execute(with: agsQuery)
        
    }
    
    
    
    func queryTask(_ queryTask: AGSQueryTask!, operation op: Operation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {
        
        let mySymbol = AGSSimpleMarkerSymbol(color: UIColor.white)
        var count = 0
        
        for i in 0 ..< featureSet.features.count  {
            //検索結果のフィーチャにシンボルを設定してグラフィックスレイヤーに追加
            let graphic = featureSet.features[i] as! AGSGraphic
            graphic.symbol = mySymbol
            agsGraphicsLayer.addGraphic(graphic)
            count = count + graphic.attributeAsInteger(forKey: "台数", exists: nil)
            
        }
        
        let alert = UIAlertController(title:"検索結果", message: String(count) + " 台の AED が見つかりました。", preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)

        
    }
    
    func queryTask(_ queryTask: AGSQueryTask!, operation op: Operation!, didFailWithError error: Error!) {
        
        print("Error:\(error.localizedDescription)")
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
