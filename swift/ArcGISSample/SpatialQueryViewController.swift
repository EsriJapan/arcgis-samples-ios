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
        
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(self.agsMapView)
        self.agsMapView.layerDelegate = self
        self.agsMapView.touchDelegate = self
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        self.agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //フィーチャ検索用のフィーチャレイヤーの追加（流山市のオープンデータ:AED設置場所）        
        let flayerUrl = NSURL(string: "https://services.arcgis.com/CmCcqeRAPUx17PGk/arcgis/rest/services/AED_2_201506/FeatureServer/0")
        let agsFeatureLayer = AGSFeatureLayer(URL: flayerUrl, mode: .OnDemand)
        agsFeatureLayer.outFields = ["*"];
        
        //グラフィックスレイヤーの追加
        self.agsGraphicsLayer = AGSGraphicsLayer()
        self.agsMapView.addMapLayer(self.agsGraphicsLayer, withName:"Graphics Layer")
        
        let envelope = AGSEnvelope.envelopeWithXmin(139.891126, ymin:35.831845, xmax:139.9517425, ymax:35.9132698000001, spatialReference:AGSSpatialReference(WKID: 104111)) as! AGSEnvelope
        self.agsMapView.zoomToEnvelope(envelope, animated: true)
        
        //検索するレイヤーのURLを指定してフィーチャ検索用タスク（AGSQueryTask）を作成
        self.agsQueryTask = AGSQueryTask(URL: flayerUrl)
        self.agsQueryTask.delegate = self
        
    }
    
    
    func mapView(mapView: AGSMapView!, didTapAndHoldAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, graphics: [NSObject : AnyObject]!) {
        
        print("Tap")
        
        //マップ上をホールド時に、フリーハンド用のポリゴンを新規に作成する
        self.agsGraphicsLayer.removeAllGraphics()
        self.agsPolygon = AGSMutablePolygon(spatialReference: self.agsMapView.spatialReference)
        
        //ホールドした地点（ポイント）をポリゴンの頂点に追加する
        self.agsPolygon.addRingToPolygon()
        self.agsPolygon.addPointToRing(mappoint)
        
    }
    
    func mapView(mapView: AGSMapView!, didMoveTapAndHoldAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, graphics: [NSObject : AnyObject]!) {
        
        print("Move")
        
        //マップ上をホールド中に指を動かしたら、動かした地点をポリゴンの頂点として追加する
        self.agsPolygon.addPointToRing(mappoint)
        
        //ポリゴンからグラフィックを作成し、グラフィックス レイヤーに追加
        //指を動かしたらグラフィックを再作成する
        self.agsGraphicsLayer.removeAllGraphics()
        let myPolygonSymbol = AGSSimpleFillSymbol()
        myPolygonSymbol.color = UIColor.orangeColor().colorWithAlphaComponent(0.5)
        myPolygonSymbol.outline.color = UIColor.clearColor()
        let polygonGraphic = AGSGraphic(geometry: self.agsPolygon, symbol: myPolygonSymbol, attributes: nil)
        self.agsGraphicsLayer.addGraphic(polygonGraphic)
        
    }
    
    func mapView(mapView: AGSMapView!, didEndTapAndHoldAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, graphics: [NSObject : AnyObject]!) {
        
        print("End")
        
        //マップ上から指を離したら、作成したポリゴンをもとに空間検索を実行
        //フィーチャ検索用のパラメータを設定
        let agsQuery = AGSQuery()
        agsQuery.outFields = ["*"]
        agsQuery.returnGeometry = true
        agsQuery.outSpatialReference = self.agsMapView.spatialReference
        //フリーハンドポリゴン内に含まれるフィーチャを検索
        let agsGeomEngine = AGSGeometryEngine.defaultGeometryEngine()
        agsQuery.geometry = agsGeomEngine.simplifyGeometry(self.agsPolygon)
        agsQuery.spatialRelationship = AGSSpatialRelationship.Contains
        
        //フィーチャの検索を実行
        self.agsQueryTask.executeWithQuery(agsQuery)
        
    }
    
    
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {
        
        let mySymbol = AGSSimpleMarkerSymbol(color: UIColor.whiteColor())
        var count = 0
        
        for var i=0; i < featureSet.features.count ; ++i {
            
            //検索結果のフィーチャにシンボルを設定してグラフィックスレイヤーに追加
            let graphic = featureSet.features[i] as! AGSGraphic
            graphic.symbol = mySymbol
            self.agsGraphicsLayer.addGraphic(graphic)
            count = count + graphic.attributeAsIntegerForKey("台数", exists: nil)
            
        }
        
        let alert = UIAlertController(title:"検索結果", message: String(count) + " 台が見つかりました。", preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)

        
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailWithError error: NSError!) {
        
        print("Error:\(error)")
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}