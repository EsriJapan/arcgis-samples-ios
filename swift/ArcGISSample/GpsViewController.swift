//
//  GpsViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class GpsViewController: UIViewController {
    
    var mapView: AGSMapView!
    var modeText: UIBarButtonItem!
    var dataText: UIBarButtonItem!
    var useGPX: Bool! = false

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        // 道路地図レイヤー表示用のマップを作成する
        mapView = AGSMapView(frame: view.bounds)
        view.addSubview(mapView)
        let map = AGSMap(basemapType: AGSBasemapType.streets, latitude: 35.681298, longitude: 139.766247, levelOfDetail: 15)
        mapView.map = map
        
        
        // マップが読み込まれたら位置情報の取得を開始
        mapView.locationDisplay.start(completion: { (error) -> Void in
            if let error = error {
                print("Error:\(error.localizedDescription)")
            } else {
                print("Start")
            }
        })


        // 位置情報の表示モード/データソースの変更ボタンを作成
        modeText = UIBarButtonItem(title: "Off", style: .plain, target: self, action: #selector(GpsViewController.changeMode(sender:)))
        dataText = UIBarButtonItem(title: "GPS", style: .plain, target: self, action: #selector(GpsViewController.changeData(sender:)))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let buttons = ([modeText, flexibleItem, dataText])
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height - 44, width: view.frame.size.width, height: 44))
        
        toolbar.setItems(buttons as? [UIBarButtonItem], animated: true)
        view .addSubview(toolbar)
        
    }
    
    
    
    func changeMode(sender: UIBarButtonItem) {
        
        if mapView.locationDisplay.autoPanMode == .off {
            
            // 位置情報の表示モードをAutoPanModeDefaultに変更
            mapView.locationDisplay.autoPanMode = .recenter
            modeText.title = "Recenter"
            
        } else if mapView.locationDisplay.autoPanMode == .recenter {
            
            // 位置情報の表示モードをAutoPanModeNavigationに変更
            mapView.locationDisplay.autoPanMode = .navigation
            modeText.title = "Navigation"
            
        } else if mapView.locationDisplay.autoPanMode == .navigation {
            
            // 位置情報の表示モードをAutoPanModeCompassNavigationに変更
            mapView.locationDisplay.autoPanMode = .compassNavigation
            modeText.title = "CompassNavigation"
            
        } else if mapView.locationDisplay.autoPanMode == .compassNavigation {
            
            // 位置情報の表示モードをAutoPanModeOffに変更
            mapView.locationDisplay.autoPanMode = .off
            modeText.title = "Off"
            
        }
        
    }
    
    
    func changeData(sender: UIBarButtonItem) {
        
        if useGPX == true {
            
            useGPX = false
            dataText.title = "GPS"
            
            // 端末の位置情報サービスをもとにデバイスの位置情報をシミュレート
            mapView.locationDisplay.dataSource = AGSCLLocationDataSource()
            mapView.locationDisplay.start(completion: { (error) -> Void in
                if let error = error {
                    print("Error:\(error.localizedDescription)")
                } else {
                    print("Start")
                }
            })
            
        } else {
            
            useGPX = true
            dataText.title = "GPX"
            
            // gpxファイルのGPSログをもとにデバイスの位置情報をシミュレート
            let gpxLDS = AGSGPXLocationDataSource(name: "tokyo_yokohama")

            mapView.locationDisplay.dataSource = gpxLDS
            mapView.locationDisplay.start(completion: { (error) -> Void in
                if let error = error {
                    print("Error:\(error.localizedDescription)")
                } else {
                    print("Start")
                }
            })
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


    
