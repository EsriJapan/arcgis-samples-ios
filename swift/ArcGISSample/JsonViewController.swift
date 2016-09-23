//
//  JsonViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class JsonViewController: UIViewController, AGSLayerCalloutDelegate {
    
    var agsMapView: AGSMapView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //グラフィックスレイヤーの追加
        let graphicsLayer:AGSGraphicsLayer = AGSGraphicsLayer()
        agsMapView.addMapLayer(graphicsLayer, withName:"Graphics Layer")
        
        //ファイルの保存場所の設定
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let filePath = (path[0] as String).appending("/offlineFeature")
        
        
        //新規フィーチャーを作成
        let point = AGSPoint(x: 15554789.5566484, y: 4254781.24130285, spatialReference:AGSSpatialReference(wkid: 102100))
        let markerSymbol = AGSSimpleMarkerSymbol(color: UIColor.blue)
        let attribute: [String: Any] = ["att": "東京ミッドタウン"]
        let graphic = AGSGraphic(geometry: point, symbol: markerSymbol, attributes: attribute)
        agsMapView.zoom(toScale: 100000, withCenter: point, animated: true)
        
        
        //フィーチャーをJSONにエンコード
        let features = [graphic!]
        let agsFeatureSet = AGSFeatureSet(features: features)
        let json: [AnyHashable: Any] = agsFeatureSet!.encodeToJSON()
        let jsonString = (json as NSDictionary).ags_JSONRepresentation()
        
        //JSONの文字列をファイルに保存
        let bSuccess:Bool
        do {
            try jsonString?.write(toFile: filePath, atomically: true, encoding: String.Encoding.unicode)
            bSuccess = true
        } catch _ {
            bSuccess = false
        }
        
        if bSuccess == true {
            print("保存場所:\(filePath), JSON:\(jsonString)")
        }
        
        //JSONの文字列からフィーチャを新規作成
        let fSetString = try? String(contentsOfFile: filePath, encoding: String.Encoding.unicode)

        
        let fSetDictionary = fSetString!.ags_JSONValue() as! [AnyHashable : Any]
        let offlineFset = AGSFeatureSet(json: fSetDictionary)
        
        //フィーチャをグラフィックスレイヤーに追加
        graphicsLayer.addGraphics(offlineFset?.features)
        graphicsLayer.calloutDelegate = self
 
    
    }
    
    
    func callout(_ callout: AGSCallout!, willShowFor feature: AGSFeature!, layer: AGSLayer!, mapPoint: AGSPoint!) -> Bool {
        
        //フィーチャをタップすると属性を表示
        agsMapView.callout.title = "属性"
        agsMapView.callout.detail = feature.attribute(forKey: "att") as! String
        
        return true
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


