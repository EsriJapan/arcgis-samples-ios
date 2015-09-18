//
//  LegendViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//



import UIKit
import ArcGIS


class LegendViewController: UIViewController, AGSLayerDelegate, AGSMapServiceInfoDelegate {
    
    var agsMapView: AGSMapView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.agsMapView.enableWrapAround()
        self.view.addSubview(self.agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        self.agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //凡例用のダイナミックマップサービスレイヤーの追加
        let dynamicLayerUrl = NSURL(string: "http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Specialty/ESRI_StateCityHighway_USA/MapServer")
        let agsDynamicMapServiceLayer = AGSDynamicMapServiceLayer(URL:dynamicLayerUrl)
        self.agsMapView.addMapLayer(agsDynamicMapServiceLayer, withName:"Legend Layer")

        agsDynamicMapServiceLayer.delegate = self

    }
    
    func layerDidLoad(layer: AGSLayer!) {
        
        if (layer.name == "Legend Layer") {
            
            self.agsMapView.zoomToEnvelope(layer.initialEnvelope, animated: true)
            
            //ダイナミックマップサービスレイヤーの表示設定（ID:2のレイヤを表示）
            let dlayer = layer as! AGSDynamicMapServiceLayer
            dlayer.visibleLayers = [2]
            
            //ダイナミックマップサービスレイヤーの凡例情報の取得
            let agsMapServiceInfo = dlayer.mapServiceInfo
            agsMapServiceInfo.delegate = self
            agsMapServiceInfo.retrieveLegendInfo()
            
            print("\(agsMapServiceInfo.serviceDescription)")
            
        }
    }
    
    
    func mapServiceInfo(mapServiceInfo: AGSMapServiceInfo!, operation op: NSOperation!, didFailToRetrieveLegendInfoWithError error: NSError!) {
        
        print("\(error)")
    
    }
    
    
    func mapServiceInfo(mapServiceInfo: AGSMapServiceInfo!, operationDidRetrieveLegendInfo op: NSOperation!) {
        
        let legendView = UIScrollView(frame: CGRectMake(10, 100, 150, 200))
        legendView.backgroundColor = UIColor.whiteColor()
        legendView.alpha = 0.8
        legendView.layer.cornerRadius = 10.0
        
        var y:CGFloat = 10;
        
        //ID:2の凡例情報を取得
        let layerInfo = mapServiceInfo.layerInfos[2] as! AGSLayerInfo


        for var i=0; i < layerInfo.legendImages.count ; ++i {
            
            //各凡例の画像とラベルを取得
            let legendImage = layerInfo.legendImages[i] as! UIImage
            let imageView = UIImageView(image: legendImage)
            let frame:CGRect = CGRect(x: 10, y: y, width:legendImage.size.width, height:legendImage.size.width)
            imageView.frame = frame
            legendView.addSubview(imageView)
            
            
            let legendlabel = UILabel(frame: CGRectMake(legendImage.size.width + 15, y, 100, legendImage.size.height))
            legendlabel.font = UIFont.boldSystemFontOfSize(10)
            legendlabel.textColor = UIColor .blackColor()
            legendlabel.text = layerInfo.legendLabels[i] as? String
            legendView.addSubview(legendlabel)
            
            y = y + legendImage.size.height
            
        }
        
        legendView.contentSize = CGSizeMake(150, y)
        self.view.addSubview(legendView)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}