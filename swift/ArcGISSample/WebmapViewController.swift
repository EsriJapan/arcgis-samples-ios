//
//  WebmapViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


// デリゲート プロトコルの宣言
class WebmapViewController: UIViewController, AGSMapViewLayerDelegate, AGSWebMapDelegate {
    
    
    var mapView: AGSMapView!
    var webmap: AGSWebMap!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Webマップを表示するマップの作成
        mapView = AGSMapView(frame: view.bounds)
        view.addSubview(mapView)
        
        // AGSMapView のデリゲートを自身に設定
        mapView.layerDelegate = self
        
        // WebマップのアイテムIDを指定して、Webマップを作成
        webmap = AGSWebMap(itemId: "d3ee769333954213b2f7e894e8e1032c", credential: nil)
        
        // 地図を表示するビュー（AGSMapView クラス）上で、Web マップを開く
        webmap.open(into: mapView)
        
        // AGSWebMap のデリゲートを自身に設定
        webmap.delegate = self

    }
    
    
    // AGSMapView のデリゲート メソッド（地図の読み込み完了時に実行）
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        
        // 位置情報の表示モードを設定
        mapView.locationDisplay.autoPanMode = .default
        
        // 地図が現在位置にズームされる際の表示縮尺の設定
        self.mapView.locationDisplay.zoomScale = 100000
        
        // 現在位置の表示を開始
        self.mapView.locationDisplay.startDataSource()
        
    }


    
    func didOpen(_ webMap: AGSWebMap!, into mapView: AGSMapView!) {
        
        // Webマップの読み込み
        print("didOpenWebMap:\(webmap.version)")
        
    }
    
    
    func webMap(_ webMap: AGSWebMap!, didLoad layer: AGSLayer!) {
        
        // Webマップに含まれるレイヤの読み込み
        print("didLoadLayer:\(layer.name)")
        
    }
    
    
    func webMap(_ webMap: AGSWebMap!, didFailToLoadWithError error: Error!) {
        
        // Webマップの読み込み失敗
        print("\(error.localizedDescription)")
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
