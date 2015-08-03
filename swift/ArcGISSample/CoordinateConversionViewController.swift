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
        
        let agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        agsMapView.touchDelegate = self;

    }
    
    
    func mapView(mapView: AGSMapView!, didClickAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [NSObject : AnyObject]!) {
        
        //マップ上でタップした場所からポイントを作成
        let myPoint = mappoint
        
        let decimalDegrees = myPoint.decimalDegreesStringWithNumDigits(10)
        let decimalMinutes = myPoint.degreesDecimalMinutesStringWithNumDigits(10)
        let decimalMinutesSeconds = myPoint.degreesMinutesSecondsStringWithNumDigits(10)
        let GARS = myPoint.GARSString()
        let GEOREF = myPoint.GEOREFStringWithNumDigits(10, rounding: true)
        let MGRS = myPoint.MGRSStringWithNumDigits(10, rounding:true, addSpaces:true)
        let USNG = myPoint.USNGStringWithNumDigits(10, rounding:true, addSpaces:true)
        let UTM = myPoint.UTMStringWithConversionMode(.NorthSouthIndicators, addSpaces:true)
        
        let str = "decimalDegrees:" + decimalDegrees + "\ndecimalMinutes:" + decimalMinutes + "\ndecimalMinutesSeconds:" + decimalMinutesSeconds + "\nGARS:" + GARS + "\nGEOREF:"  + GEOREF + "\nMGRS:" + MGRS + "\nUSNG:" + USNG + "\nUTM:" + UTM
        
        let alert = UIAlertController(title:"座標", message: str, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}