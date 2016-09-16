//
//  CoordinateConversionViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class CoordinateConversionViewController: UIViewController, AGSMapViewTouchDelegate {
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        agsMapView.touchDelegate = self

    }
    
    
    func mapView(_ mapView: AGSMapView!, didClickAt screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [AnyHashable : Any]) {
        
        //マップ上でタップした場所からポイントを作成
        let myPoint = mappoint
        
        //座標の表示形式の変更
        let decimalDegrees: String = myPoint!.decimalDegreesString(withNumDigits: 10)
        let decimalMinutes: String = myPoint!.degreesDecimalMinutesString(withNumDigits: 10)
        let decimalMinutesSeconds: String = myPoint!.degreesMinutesSecondsString(withNumDigits: 10)
        let GARS: String = myPoint!.garsString()
        let GEOREF: String = myPoint!.georefString(withNumDigits: 10, rounding: true)
        let MGRS: String = myPoint!.mgrsString(withNumDigits: 10, rounding:true, addSpaces:true)
        let USNG: String = myPoint!.usngString(withNumDigits: 10, rounding:true, addSpaces:true)
        let UTM: String = myPoint!.utmString(with: .northSouthIndicators, addSpaces:true)

        let str = "decimalDegrees:\(decimalDegrees)\ndecimalMinutes:\(decimalMinutes)\ndecimalMinutesSeconds:\(decimalMinutesSeconds)\nGARS:\(GARS)\nGEOREF:\(GEOREF)\nMGRS:\(MGRS)\nUSNG:\(USNG)\nUTM:\(UTM)"
        
        let alert = UIAlertController(title:"座標", message: str, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
