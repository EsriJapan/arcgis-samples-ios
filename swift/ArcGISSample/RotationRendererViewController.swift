//
//  RotationRendererViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class RotationRendererViewController: UIViewController, AGSWebMapDelegate {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //シンボル表示用のフィーチャレイヤーの表示
        let flayerUrl = URL(string: "https://tmservices1.esri.com/arcgis/rest/services/LiveFeeds/NOAA_METAR_current_wind_speed_direction/MapServer/0")
        let flayer = AGSFeatureLayer(url: flayerUrl, mode: .onDemand)
        flayer?.outFields = ["WIND_DIRECT"]
        agsMapView.addMapLayer(flayer, withName:"Feature Layer")

        //画像ファイルを指定してシンボルとレンダラーを作成
        let image = UIImage(named: "ArcGIS.bundle/LocationDisplayCourse@2x.png")
        let pointSymbol = AGSPictureMarkerSymbol(image: image)
        let renderer = AGSSimpleRenderer(symbol: pointSymbol)

        //レンダラーの回転角度の値をフィーチャレイヤーの"WIND_DIRECT"フィールドから取得
        renderer?.rotationType = .geographic
        renderer?.rotationExpression = "[WIND_DIRECT]"
        
        //レンダラーをフィーチャレイヤーに適用
        flayer?.renderer = renderer
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
