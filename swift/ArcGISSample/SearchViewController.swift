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
    var agsGraphicsLayer: AGSGraphicsLayer!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //フィーチャ検索用のフィーチャレイヤーの表示
        let flayerUrl = URL(string: "https://services3.arcgis.com/iH4Iz7CEdh5xTJYb/arcgis/rest/services/Nagareyama_shi_Shisetsu_All/FeatureServer/0")
        let agsFeatureLayer = AGSFeatureLayer(url: flayerUrl, mode: .onDemand)
        agsFeatureLayer?.outFields = ["*"];
        agsMapView.addMapLayer(agsFeatureLayer, withName:"Feature Layer")
        
        //検索結果を表示するグラフィックスレイヤーを表示
        agsGraphicsLayer = AGSGraphicsLayer()
        agsMapView.addMapLayer(agsGraphicsLayer, withName:"Graphics Layer")

        let envelope = AGSEnvelope.envelope(withXmin: 139.891126, ymin:35.831845, xmax:139.9517425, ymax:35.9132698000001, spatialReference:AGSSpatialReference(wkid: 104111)) as! AGSEnvelope
        agsMapView.zoom(to: envelope, animated: true)
        
        
        //検索するレイヤーのURLを指定してフィーチャ検索用タスク（AGSQueryTask）を作成
        agsQueryTask = AGSQueryTask(url: flayerUrl)
        agsQueryTask.delegate = self
        
        
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.size.height + navigationController!.navigationBar.frame.size.height, width: view.frame.size.width, height: 50))
        searchBar.delegate = self
        searchBar.text = "子育て施設"
        view.addSubview(searchBar)
        
        
    }
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //フィーチャ検索用のパラメータを設定
        let agsQuery = AGSQuery()
        agsQuery.outFields = ["*"]
        agsQuery.returnGeometry = true
        agsQuery.outSpatialReference = agsMapView.spatialReference
        let searchText: String = searchBar.text!
        //大分類フィールドの値が「子育て施設」のフィーチャを検索
        agsQuery.whereClause = "大分類 = \'\(searchText)\'"

        
        //検索結果をソートするフィールドの指定
        let order: [Any] = ["所在地"]
        agsQuery.orderByFields = order
        
        //フィーチャ検索を実行
        agsQueryTask.execute(with: agsQuery)
        
        view.endEditing(true)
        
    }
    
    
    func queryTask(_ queryTask: AGSQueryTask!, operation op: Operation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {

        agsGraphicsLayer.removeAllGraphics()
        
        let mySymbol = AGSSimpleMarkerSymbol(color: UIColor.white)
        
        for i in 0 ..< featureSet.features.count  {
            
            //検索結果のフィーチャにシンボルを設定してグラフィックスレイヤーに追加
            let graphic = featureSet.features[i] as! AGSGraphic
            graphic.symbol = mySymbol
            agsGraphicsLayer.addGraphic(graphic)
            agsGraphicsLayer.setSelected(true, for: graphic)
            let attr = graphic.attribute(forKey: "所在地") as! String
            print("graphic:\(attr)")
            
        }
        
    }
    
    func queryTask(_ queryTask: AGSQueryTask!, operation op: Operation!, didFailWithError error: Error!) {
        
        print("Error:\(error.localizedDescription)")

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
