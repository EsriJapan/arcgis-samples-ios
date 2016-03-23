//
//  TimeViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class TimeViewController: UIViewController, AGSWebMapDelegate {
    
    
    var agsMapView: AGSMapView!
    
    var startDate: NSDate!
    var endDate: NSDate!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(self.agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        self.agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //時間対応レイヤー表示用のフィーチャレイヤーの追加
        let timeUrl = NSURL(string: "https://sampleserver3.arcgisonline.com/ArcGIS/rest/services/Hurricanes/NOAA_Tracks_1851_2007/MapServer/0")
        let agsFeatureLayer = AGSFeatureLayer(URL: timeUrl, mode: .OnDemand)
        self.agsMapView.addMapLayer(agsFeatureLayer, withName:"Time Layer")

        //マップ上でフィーチャを表示する時間範囲を指定
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.startDate = dateFormatter.dateFromString("1900-1-1")
        self.endDate = dateFormatter.dateFromString("1901-1-1")
        
        let agsTimeExtent = AGSTimeExtent(start: self.startDate, end: self.endDate)
        self.agsMapView.timeExtent = agsTimeExtent
        
        
        let timeItem = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: #selector(TimeViewController.buttonEvent))
        self.navigationItem.rightBarButtonItem = timeItem
        
    }
    
    
    func buttonEvent(sender: UIBarButtonItem) {
        
        //マップ上でフィーチャを表示する時間範囲を1年単位で変更
        let comps = NSDateComponents()
        comps.year = 1
        let calendar = NSCalendar.currentCalendar()
        
        let startDateNew = calendar.dateByAddingComponents(comps, toDate: self.startDate, options: NSCalendarOptions(rawValue: 0))
        let endDateNew = calendar.dateByAddingComponents(comps, toDate: self.endDate, options: NSCalendarOptions(rawValue: 0))
        
        self.startDate = startDateNew
        self.endDate = endDateNew
        
        print("Start:\(self.startDate.description)", "End:\(self.endDate.description)")

        let agsTimeExtent = AGSTimeExtent(start: self.startDate, end: self.endDate)
        self.agsMapView.timeExtent = agsTimeExtent
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
