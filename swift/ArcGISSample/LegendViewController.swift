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
        
        agsMapView = AGSMapView(frame: view.bounds)
        agsMapView.enableWrapAround()
        view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //凡例用のダイナミックマップサービスレイヤーの追加
        let dynamicLayerUrl = URL(string: "https://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Specialty/ESRI_StateCityHighway_USA/MapServer")
        let agsDynamicMapServiceLayer = AGSDynamicMapServiceLayer(url:dynamicLayerUrl)
        agsMapView.addMapLayer(agsDynamicMapServiceLayer, withName:"Legend Layer")

        agsDynamicMapServiceLayer?.delegate = self

    }
    
    func layerDidLoad(_ layer: AGSLayer!) {
        
        if (layer.name == "Legend Layer") {
            
            agsMapView.zoom(to:layer.initialEnvelope, animated: false)
            
            //ダイナミックマップサービスレイヤーの表示設定（ID:2のレイヤを表示）
            let dlayer = layer as! AGSDynamicMapServiceLayer
            dlayer.visibleLayers = [2]
            
            //ダイナミックマップサービスレイヤーの凡例情報の取得
            let agsMapServiceInfo = dlayer.mapServiceInfo
            agsMapServiceInfo?.delegate = self
            _ = agsMapServiceInfo?.retrieveLegendInfo()
            
            print("\(agsMapServiceInfo?.serviceDescription)")
            
        }
    }
    
    
    func mapServiceInfo(_ mapServiceInfo: AGSMapServiceInfo!, operation op: Operation!, didFailToRetrieveLegendInfoWithError error: Error!) {
        
        print("\(error.localizedDescription)")
    
    }
    
    
    func mapServiceInfo(_ mapServiceInfo: AGSMapServiceInfo!, operationDidRetrieveLegendInfo op: Operation!) {
        
        let legendView = UIScrollView(frame: CGRect(x: 10, y: 100, width: 150, height: 200))
        legendView.backgroundColor = UIColor.white
        legendView.alpha = 0.8
        legendView.layer.cornerRadius = 10.0
        
        var y:CGFloat = 10;
        
        //ID:2の凡例情報を取得
        let layerInfo = mapServiceInfo.layerInfos[2] as! AGSLayerInfo


        for i in 0 ..< layerInfo.legendImages.count  {
            //各凡例の画像とラベルを取得
            let legendImage = layerInfo.legendImages[i] as! UIImage
            let imageView = UIImageView(image: legendImage)
            let frame:CGRect = CGRect(x: 10, y: y, width:legendImage.size.width, height:legendImage.size.width)
            imageView.frame = frame
            legendView.addSubview(imageView)
            
            let legendlabel = UILabel(frame: CGRect(x: legendImage.size.width + 15, y: y, width: 100, height: legendImage.size.height))
            legendlabel.font = UIFont.boldSystemFont(ofSize: 10)
            legendlabel.textColor = UIColor.black
            legendlabel.text = layerInfo.legendLabels[i] as? String
            legendView.addSubview(legendlabel)
            
            y = y + legendImage.size.height
            
        }
        
        legendView.contentSize = CGSize(width: 150, height: y)
        view.addSubview(legendView)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
