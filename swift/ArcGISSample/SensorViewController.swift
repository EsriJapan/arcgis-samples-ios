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
        
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(self.agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        self.agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //グラフィックスレイヤーの追加
        let agsGraphicsLayer = AGSGraphicsLayer()
        agsMapView.addMapLayer(agsGraphicsLayer, withName:"Graphics Layer")
        
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        
        
    }
    
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations.last
        
        //CLLocationManagerで取得した現在位置からポイントを作成
        let agsGeomEngine = AGSGeometryEngine.defaultGeometryEngine()
        let agsPoint = AGSPoint(x: location!.coordinate.longitude, y: location!.coordinate.latitude, spatialReference: AGSSpatialReference(WKID:4326))
        let agsProjectedPoint = agsGeomEngine.projectGeometry(agsPoint, toSpatialReference: AGSSpatialReference(WKID:102100)) as! AGSPoint

        //ポイントをグラフィックスレイヤーに追加
        let graphicsLayer = self.agsMapView.mapLayerForName("Graphics Layer") as! AGSGraphicsLayer
        let markerSymbol = AGSSimpleMarkerSymbol(color: UIColor .blueColor())
        let graphic = AGSGraphic.graphicWithGeometry(agsProjectedPoint, symbol: markerSymbol, attributes: nil) as! AGSGraphic
        graphicsLayer.removeAllGraphics()
        graphicsLayer.addGraphic(graphic)
        self.agsMapView.zoomToScale(100000, withCenterPoint: agsProjectedPoint, animated: true)
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        if (newHeading.headingAccuracy > 0){
            
            //CLLocationManagerで取得した方位に応じてマップを回転
            self.agsMapView.setRotationAngle(newHeading.magneticHeading, animated: true)
            
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}