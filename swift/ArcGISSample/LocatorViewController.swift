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
        
        agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        agsMapView.touchDelegate = self
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        let envelope = AGSEnvelope.envelope(withXmin: 1.5557970122810215E7, ymin:4258398.013496462, xmax:1.5558175713936899E7, ymax:4258509.895960432, spatialReference:AGSSpatialReference(wkid: 102100)) as! AGSEnvelope
        agsMapView.zoom(to: envelope, animated: true)
        
        //住所検索を行うジオコードサービスのURLを設定
        let geocodeUrl = URL(string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/")

        //ジオコードサービスのURLを指定して住所検索を行うタスク（AGSLocator）を作成
        agsLocator = AGSLocator(url: geocodeUrl)
        
        //AGSLocatorのデリゲートを設定
        agsLocator.delegate = self
        
    }
    
    
    //マップ上でタップされたときに実行される
    func mapView(_ mapView: AGSMapView!, didClickAt screen: CGPoint, mapPoint mappoint: AGSPoint!, graphics: [AnyHashable: Any]!) {
        
        agsMapView.callout.isHidden = true
        agsPoint = mappoint

        //住所を検索する位置をパラメータに指定してタスクを実行
        agsLocator.address(forLocation: agsPoint, maxSearchDistance: 100)
    
    }
    
    
    //住所検索の処理が完了したら実行される
    func locator(_ locator: AGSLocator!, operation op: Operation!, didFindAddressForLocation candidate: AGSAddressCandidate!) {
        
        //検索結果から住所の文字列を取得する
        let strAddress = candidate.address["Address"] as! String
        
        //画面に表示するポップアップのタイトルを設定
        agsMapView.callout.title = "住所"
        
        //ポップアップの本文に住所を設定
        agsMapView.callout.detail = strAddress
        
        //最初にマップ上でタップした位置にポップアップを表示
        agsMapView.callout.show(at: agsPoint, screenOffset: CGPoint.zero, animated: true)
        
    }
    
    
    func locator(_ locator: AGSLocator!, operation op: Operation!, didFailAddressForLocation error: Error!) {
        print("Error:\(error.localizedDescription)")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
