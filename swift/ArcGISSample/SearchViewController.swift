//
//  SearchViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//


import UIKit
import ArcGIS

class SearchViewController: UIViewController, UISearchBarDelegate, AGSQueryTaskDelegate {
    
    
    var agsMapView: AGSMapView!
    var agsQueryTask: AGSQueryTask!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(self.agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        self.agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //フィーチャ検索用のフィーチャレイヤーの表示
        let flayerUrl = NSURL(string: "http://services3.arcgis.com/iH4Iz7CEdh5xTJYb/arcgis/rest/services/Nagareyama_shi_Shisetsu_All/FeatureServer/0")
        let agsFeatureLayer = AGSFeatureLayer(URL: flayerUrl, mode: .OnDemand)
        agsFeatureLayer.outFields = ["*"];
        self.agsMapView.addMapLayer(agsFeatureLayer, withName:"Feature Layer")

        let envelope = AGSEnvelope.envelopeWithXmin(139.891126, ymin:35.831845, xmax:139.9517425, ymax:35.9132698000001, spatialReference:AGSSpatialReference(WKID: 104111)) as! AGSEnvelope
        self.agsMapView.zoomToEnvelope(envelope, animated: true)
        
        
        //検索するレイヤーのURLを指定してフィーチャ検索用タスク（AGSQueryTask）を作成
        self.agsQueryTask = AGSQueryTask(URL: flayerUrl)
        self.agsQueryTask.delegate = self;
        
        
        let searchBar = UISearchBar(frame: CGRectMake(0, UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height, self.view.frame.size.width, 50))
        searchBar.delegate = self
        searchBar.text = "子育て施設"
        self.view.addSubview(searchBar)
        
        
    }
    

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        //フィーチャ検索用のパラメータを設定
        let agsQuery = AGSQuery()
        agsQuery.outFields = ["*"]
        agsQuery.returnGeometry = true
        agsQuery.outSpatialReference = self.agsMapView.spatialReference
        agsQuery.whereClause = "大分類 = '\(searchBar.text)'"
        
        //検索結果をソートするフィールドの指定
        let order = NSMutableArray(array: ["所在地"])
        agsQuery.orderByFields = order as [AnyObject]
        
        //フィーチャ検索を実行
        self.agsQueryTask.executeWithQuery(agsQuery)
        
        self.view.endEditing(true)
        
    }
    
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {

        //検索結果を表示するグラフィックスレイヤーを表示
        let agsGraphicsLayer = AGSGraphicsLayer()
        agsMapView.addMapLayer(agsGraphicsLayer, withName:"Graphics Layer")
        
        let mySymbol = AGSSimpleMarkerSymbol(color: UIColor.whiteColor())
        
        for var i=0; i < featureSet.features.count ; ++i {
            
            //検索結果のフィーチャにシンボルを設定してグラフィックスレイヤーに追加
            let graphic = featureSet.features[i] as! AGSGraphic
            graphic.symbol = mySymbol
            agsGraphicsLayer.addGraphic(graphic)
            agsGraphicsLayer.setSelected(true, forGraphic: graphic)
            let attr = graphic.attributeForKey("所在地") as! String
            println("graphic:\(attr)")
            
        }
        
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailWithError error: NSError!) {
        
        println("Error:\(error)")

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}