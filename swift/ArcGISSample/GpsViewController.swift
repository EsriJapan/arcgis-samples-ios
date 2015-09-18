//
//  GpsViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class GpsViewController: UIViewController, AGSMapViewLayerDelegate {
    
    var agsMapView: AGSMapView!
    var modeText: UIBarButtonItem!
    var dataText: UIBarButtonItem!
    var useGPX: Bool! = false

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(self.agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        self.agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        self.agsMapView.layerDelegate = self
        
        
        self.modeText = UIBarButtonItem(title: "Off", style: .Plain, target: self, action: "changeMode:")
        self.dataText = UIBarButtonItem(title: "GPS", style: .Plain, target: self, action: "changeData:")
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let buttons = ([self.modeText, flexibleItem, self.dataText])
        let toolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44))
        
        toolbar.setItems(buttons as? [UIBarButtonItem], animated: true)
        self.view .addSubview(toolbar)
        
    }
    
    
    func mapViewDidLoad(mapView: AGSMapView!) {
        
        //マップが読み込まれたら位置情報の取得を開始
        self.agsMapView.locationDisplay.startDataSource()
        
    }
    
    
    func changeMode(sender: UIBarButtonItem) {
        
        if self.agsMapView.locationDisplay.autoPanMode == .Off {
            
            //位置情報の表示モードをAutoPanModeDefaultに変更
            self.agsMapView.locationDisplay.autoPanMode = .Default
            self.modeText.title = "Default"
            
        } else if self.agsMapView.locationDisplay.autoPanMode == .Default {
            
            //位置情報の表示モードをAutoPanModeNavigationに変更
            self.agsMapView.locationDisplay.autoPanMode = .Navigation
            self.modeText.title = "Navigation"
            
        } else if self.agsMapView.locationDisplay.autoPanMode == .Navigation {
            
            //位置情報の表示モードをAutoPanModeCompassNavigationに変更
            self.agsMapView.locationDisplay.autoPanMode = .CompassNavigation
            self.modeText.title = "CompassNavigation"
            
        } else if self.agsMapView.locationDisplay.autoPanMode == .CompassNavigation {
            
            //位置情報の表示モードをAutoPanModeOffに変更
            self.agsMapView.locationDisplay.autoPanMode = .Off
            self.modeText.title = "Off"
            
        }
        
    }
    
    func changeData(sender: UIBarButtonItem) {
        
        
        if self.useGPX == true {
            
            self.useGPX = false
            self.dataText.title = "GPS"
            //端末の位置情報サービスをもとにデバイスの位置情報をシミュレート
            self.agsMapView.locationDisplay.dataSource = AGSCLLocationManagerLocationDisplayDataSource()
            self.agsMapView.locationDisplay.startDataSource()
            
        } else {
            
            self.useGPX = true
            self.dataText.title = "GPX"
            //gpxファイルのGPSログをもとにデバイスの位置情報をシミュレート
            let gpxPath = NSBundle.mainBundle().pathForResource("tokyo_yokohama", ofType: "gpx")
            let gpxLDS = AGSGPXLocationDisplayDataSource(path: gpxPath)
            self.agsMapView.locationDisplay.dataSource = gpxLDS
            self.agsMapView.locationDisplay.startDataSource()
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


    