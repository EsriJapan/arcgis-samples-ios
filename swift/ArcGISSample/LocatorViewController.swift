//
//  LocatorViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class LocatorViewController: UIViewController, AGSLocatorDelegate, AGSMapViewTouchDelegate {
    
    var agsMapView: AGSMapView!
    var agsLocator: AGSLocator!
    var agsPoint: AGSPoint!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(self.agsMapView)
        self.agsMapView.touchDelegate = self;
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        self.agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        let envelope = AGSEnvelope.envelopeWithXmin(1.5557970122810215E7, ymin:4258398.013496462, xmax:1.5558175713936899E7, ymax:4258509.895960432, spatialReference:AGSSpatialReference(WKID: 102100)) as! AGSEnvelope
        self.agsMapView.zoomToEnvelope(envelope, animated: true)
        
        //住所検索を行うジオコードサービスのURLを設定
        let geocodeUrl = NSURL(string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/")

        //ジオコードサービスのURLを指定して住所検索を行うタスク（AGSLocator）を作成
        self.agsLocator = AGSLocator(URL: geocodeUrl)
        
        //AGSLocatorのデリゲートを設定
        self.agsLocator.delegate = self
        
    }
    
    
    //マップ上でタップされたときに実行される
    func mapView(mapView: AGSMapView!, didClickAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, graphics: [NSObject : AnyObject]!) {
        
        self.agsMapView.callout.hidden = true
        self.agsPoint = mappoint

        //住所を検索する位置をパラメータに指定してタスクを実行
        self.agsLocator.addressForLocation(self.agsPoint, maxSearchDistance: 100)
    
    }
    
    
    //住所検索の処理が完了したら実行される
    func locator(locator: AGSLocator!, operation op: NSOperation!, didFindAddressForLocation candidate: AGSAddressCandidate!) {
        
        //検索結果から住所の文字列を取得する
        let strAddress = candidate.address["Address"] as! String
        
        //画面に表示するポップアップのタイトルを設定
        self.agsMapView.callout.title = "住所"
        
        //ポップアップの本文に住所を設定
        self.agsMapView.callout.detail = strAddress
        
        //最初にマップ上でタップした位置にポップアップを表示
        self.agsMapView.callout .showCalloutAt(self.agsPoint, screenOffset: CGPointZero, animated: true)
        
    }
    
    
    func locator(locator: AGSLocator!, operation op: NSOperation!, didFailAddressForLocation error: NSError!) {
        print("Error:\(error)")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
