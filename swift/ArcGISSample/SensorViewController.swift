//
//  SensorViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS

class SensorViewController: UIViewController, CLLocationManagerDelegate {
    
    
    var agsMapView: AGSMapView!
    var locationManager:CLLocationManager!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //グラフィックスレイヤーの追加
        let agsGraphicsLayer = AGSGraphicsLayer()
        agsMapView.addMapLayer(agsGraphicsLayer, withName:"Graphics Layer")
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations.last
        
        //CLLocationManagerで取得した現在位置からポイントを作成
        let agsGeomEngine = AGSGeometryEngine.default()
        let agsPoint = AGSPoint(x: location!.coordinate.longitude, y: location!.coordinate.latitude, spatialReference: AGSSpatialReference(wkid:4326))
        let agsProjectedPoint = agsGeomEngine?.projectGeometry(agsPoint, to: AGSSpatialReference(wkid:102100)) as! AGSPoint

        //ポイントをグラフィックスレイヤーに追加
        let graphicsLayer = agsMapView.mapLayer(forName: "Graphics Layer") as! AGSGraphicsLayer
        let markerSymbol = AGSSimpleMarkerSymbol(color: UIColor .blue)
        let graphic = AGSGraphic.graphic(with: agsProjectedPoint, symbol: markerSymbol, attributes: nil) as! AGSGraphic
        graphicsLayer.removeAllGraphics()
        graphicsLayer.addGraphic(graphic)
        agsMapView.zoom(toScale: 100000, withCenter: agsProjectedPoint, animated: true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        if (newHeading.headingAccuracy > 0){
            
            //CLLocationManagerで取得した方位に応じてマップを回転
            agsMapView.setRotationAngle(newHeading.magneticHeading, animated: true)
            
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
