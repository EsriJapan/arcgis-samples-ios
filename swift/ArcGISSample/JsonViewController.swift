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
        
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(self.agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        self.agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //グラフィックスレイヤーの追加
        let graphicsLayer:AGSGraphicsLayer = AGSGraphicsLayer()
        self.agsMapView.addMapLayer(graphicsLayer, withName:"Graphics Layer")
        
        
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true);
        let filePath = (path[0] as NSString).stringByAppendingPathComponent("offlineFeature")
        
        
        //新規フィーチャーを作成
        let point = AGSPoint(x: 15554789.5566484, y: 4254781.24130285, spatialReference:AGSSpatialReference(WKID: 102100))
        let markerSymbol = AGSSimpleMarkerSymbol(color: UIColor.blueColor())
        let graphic = AGSGraphic(geometry: point, symbol: markerSymbol, attributes: NSDictionary(object: "東京ミッドタウン", forKey: "att") as [NSObject : AnyObject])
        self.agsMapView.zoomToScale(100000, withCenterPoint: point, animated: true)
        
        //フィーチャーをJSONにエンコード
        let agsFeatureSet = AGSFeatureSet(features:(NSArray(array: [graphic])) as [AnyObject])
        let json = agsFeatureSet.encodeToJSON() as NSDictionary
        let jsonString = json.ags_JSONRepresentation()
        
        //JSONの文字列をファイルに保存
        let bSuccess:Bool
        do {
            try jsonString.writeToFile(filePath, atomically: true, encoding: NSUnicodeStringEncoding)
            bSuccess = true
        } catch _ {
            bSuccess = false
        }
        
        if bSuccess == true {
            print("保存場所:\(filePath), JSON:\(jsonString)")
        }
        
        //JSONの文字列からフィーチャを新規作成
        let fSetString = try? NSString(contentsOfFile: filePath, encoding: NSUnicodeStringEncoding)
        let fSetDictionary:AnyObject! = fSetString!.ags_JSONValue()
        let offlineFset = AGSFeatureSet(JSON: fSetDictionary as! [NSObject : AnyObject])
        
        //フィーチャをグラフィックスレイヤーに追加
        graphicsLayer.addGraphics(offlineFset.features)
        graphicsLayer.calloutDelegate = self
    
    }
    
    
    func callout(callout: AGSCallout!, willShowForFeature feature: AGSFeature!, layer: AGSLayer!, mapPoint: AGSPoint!) -> Bool {
        
        //フィーチャをタップすると属性を表示
        self.agsMapView.callout.title = "属性"
        self.agsMapView.callout.detail = feature.attributeForKey("att") as! String
        
        return true
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


