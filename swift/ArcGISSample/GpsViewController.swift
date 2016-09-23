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
        
        agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        agsMapView.layerDelegate = self
        
        
        modeText = UIBarButtonItem(title: "Off", style: .plain, target: self, action: #selector(GpsViewController.changeMode))
        dataText = UIBarButtonItem(title: "GPS", style: .plain, target: self, action: #selector(GpsViewController.changeData))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let buttons = ([modeText, flexibleItem, dataText])
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height - 44, width: view.frame.size.width, height: 44))
        
        toolbar.setItems(buttons as? [UIBarButtonItem], animated: true)
        view .addSubview(toolbar)
        
    }
    
    
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        
        //マップが読み込まれたら位置情報の取得を開始
        agsMapView.locationDisplay.startDataSource()
        
    }
    
    
    func changeMode(_ sender: UIBarButtonItem) {
        
        if agsMapView.locationDisplay.autoPanMode == .off {
            
            //位置情報の表示モードをAutoPanModeDefaultに変更
            agsMapView.locationDisplay.autoPanMode = .default
            modeText.title = "Default"
            
        } else if agsMapView.locationDisplay.autoPanMode == .default {
            
            //位置情報の表示モードをAutoPanModeNavigationに変更
            agsMapView.locationDisplay.autoPanMode = .navigation
            modeText.title = "Navigation"
            
        } else if agsMapView.locationDisplay.autoPanMode == .navigation {
            
            //位置情報の表示モードをAutoPanModeCompassNavigationに変更
            agsMapView.locationDisplay.autoPanMode = .compassNavigation
            modeText.title = "CompassNavigation"
            
        } else if agsMapView.locationDisplay.autoPanMode == .compassNavigation {
            
            //位置情報の表示モードをAutoPanModeOffに変更
            agsMapView.locationDisplay.autoPanMode = .off
            modeText.title = "Off"
            
        }
        
    }
    
    func changeData(_ sender: UIBarButtonItem) {
        
        
        if useGPX == true {
            
            useGPX = false
            dataText.title = "GPS"
            //端末の位置情報サービスをもとにデバイスの位置情報をシミュレート
            agsMapView.locationDisplay.dataSource = AGSCLLocationManagerLocationDisplayDataSource()
            agsMapView.locationDisplay.startDataSource()
            
        } else {
            
            useGPX = true
            dataText.title = "GPX"
            //gpxファイルのGPSログをもとにデバイスの位置情報をシミュレート
            let gpxPath = Bundle.main.path(forResource: "tokyo_yokohama", ofType: "gpx")
            let gpxLDS = AGSGPXLocationDisplayDataSource(path: gpxPath)
            agsMapView.locationDisplay.dataSource = gpxLDS
            agsMapView.locationDisplay.startDataSource()
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


    
