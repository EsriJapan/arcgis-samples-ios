//
//  WmsViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class WmsViewController: UIViewController, AGSWebMapDelegate {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(agsMapView)
        
        //WMSレイヤーの追加
        let wmsUrl = NSURL(string: "http://hazardmap.service-section.com/geoserver/wmscapabilities?id=alos_avnir2_chile_santiago_mosaic_20100227")
        let wmsLayer = AGSWMSLayer (URL: wmsUrl)
        agsMapView.addMapLayer(wmsLayer, withName:"WMS Layer")
        
        
        //コピーライト用のラベルを追加
        let label:UILabel = UILabel(frame: CGRectMake(0, self.view.frame.size.height - 20, 70, 20))
        label.text = "(c) JAXA"
        label.backgroundColor = UIColor.whiteColor()
        label.alpha = 0.5
        self.view.addSubview(label)
        
    }
    
    
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}