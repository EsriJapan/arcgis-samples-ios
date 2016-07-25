//
//  ExportTilesViewController.swift
//  ArcGISSample
//
//  Created by esrij on H28/07/24.
//  Copyright © 平成28年 esrij. All rights reserved.
//

import UIKit
import ArcGIS

let MaxScale:Double = 2256.994353

class ExportTilesViewController: UIViewController, AGSLayerDelegate {
    
    var agsMapView: AGSMapView!
    var exportTileTask:AGSExportTileCacheTask!
    var tiledLayer:AGSTiledMapServiceLayer!
    var downloadBtn: UIBarButtonItem!
    var resetBtn: UIBarButtonItem!
    var indicatorView: UIActivityIndicatorView!
    var downloadLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //マップの作成
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(self.agsMapView)
        
        //マップの初期表示範囲と最大表示スケールの設定
        let agsGeomEngine = AGSGeometryEngine.defaultGeometryEngine()
        let agsPoint = AGSPoint(x: 139.730451, y: 35.665577, spatialReference: AGSSpatialReference(WKID:4326))
        let agsProjectedPoint = agsGeomEngine.projectGeometry(agsPoint, toSpatialReference: AGSSpatialReference(WKID:102100)) as! AGSPoint
        self.agsMapView.zoomToScale(36111.909643, withCenterPoint: agsProjectedPoint, animated: true)
        self.agsMapView.maxScale = MaxScale
        
        
        //ArcGIS for Developers のアカウントのユーザー名とパスワードを入力（検証用）
        let agsCredential = AGSCredential(user: "<ユーザー名>", password: "<パスワード>")
        
        //ArcGIS Online のベースマップ（タイルのダウンロード専用）の URL を設定
        let tileServiceURL = "https://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Street_Map/MapServer"
        
        //タイル レイヤーをマップに追加
        //レイヤー読み込みのためのデリゲートを設定
        let tiledUrl = NSURL(string: tileServiceURL)
        self.tiledLayer = AGSTiledMapServiceLayer(URL: tiledUrl, credential: agsCredential)
        self.tiledLayer.delegate  = self
        self.agsMapView.addMapLayer(self.tiledLayer, withName:"World Street Map")
        
        
        //タイルのエクスポート用タスクを作成
        if self.exportTileTask == nil {
            self.exportTileTask = AGSExportTileCacheTask(URL: tiledUrl, credential: agsCredential)
        }
        
        //ダウンロード ボタンの追加
        self.downloadBtn = UIBarButtonItem(title: "ダウンロード", style: .Plain, target: self, action: #selector(ExportTilesViewController.exportTiles))
        self.resetBtn = UIBarButtonItem(title: "リセット", style: .Plain, target: self, action: #selector(ExportTilesViewController.resetMap))
        self.downloadBtn.enabled = false
        self.resetBtn.enabled = false
        
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let buttons = ([self.downloadBtn, flexibleItem, self.resetBtn])
        let toolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44))
        
        toolbar.setItems(buttons as? [UIBarButtonItem], animated: true)
        self.view.addSubview(toolbar)
        
        
        //インジケータの作成
        self.indicatorView = UIActivityIndicatorView()
        self.indicatorView.center = self.view.center
        self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(self.indicatorView)
        
        //ラベルの作成
        self.downloadLabel = UILabel(frame: CGRectMake(0,0,200,30))
        self.downloadLabel.layer.masksToBounds = true
        self.downloadLabel.layer.cornerRadius = 10.0
        self.downloadLabel.textColor = UIColor.darkGrayColor()
        self.downloadLabel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        self.downloadLabel.textAlignment = NSTextAlignment.Center
        self.downloadLabel.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.indicatorView.layer.position.y + 30)
        self.view.addSubview(self.downloadLabel)
        self.downloadLabel.hidden = true
        
    }
    
    
    func layer(layer: AGSLayer!, didFailToLoadWithError error: NSError!) {
        //タイル レイヤーの読み込みのエラー
        UIAlertView(title: "エラー", message: error.localizedDescription, delegate: nil, cancelButtonTitle: nil).show()
    }
    
    func layerDidLoad(layer: AGSLayer!) {
        //タイル レイヤーの読み込み完了
        self.downloadBtn.enabled = true
    }
    
    
    
    func exportTiles(sender: UIBarButtonItem) {
        
        self.agsMapView.userInteractionEnabled = false
        self.downloadLabel.hidden = false
        self.downloadBtn.enabled = false
        
        var limitDescription = ""
        
        //ダウンロードするマップの範囲を設定（現在の表示範囲）
        let currentExtent = self.agsMapView.visibleAreaEnvelope
        
        //現在のマップ表示のスケール レベルを取得
        let currentLevel = self.tiledLayer.currentLOD().level - 1
        
        //ダウンロードするマップのスケール レベルを設定（現在のレベルから高縮尺の3レベル）
        let desiredLevels =  [currentLevel, currentLevel + 1, currentLevel + 2]
        
        //タイルのスケール レベルとマップの範囲をもとにパラメーターを作成
        let params = AGSExportTileCacheParams(levelsOfDetail: desiredLevels, areaOfInterest:currentExtent)
        
        //パラメーターを指定してタイルのダウンロードを実行
        self.exportTileTask.exportTileCacheWithParameters(params, downloadFolderPath: nil, useExisting: true, status: { (status, userInfo) -> Void in
            
            //処理のステータスを確認
            print("\(AGSResumableTaskJobStatusAsString(status)), \(userInfo)")
            if userInfo != nil {
                
                let allMessages =  userInfo["messages"] as? [AGSGPMessage]
                
                //ダウンロードの進捗表示
                if status == .FetchingResult {
                    let totalBytesDownloaded = userInfo["AGSDownloadProgressTotalBytesDownloaded"] as? Double
                    let totalBytesExpected = userInfo["AGSDownloadProgressTotalBytesExpected"] as? Double
                    if totalBytesDownloaded != nil && totalBytesExpected != nil {
                        let dPercentage = totalBytesDownloaded!/totalBytesExpected!
                        print("\(totalBytesDownloaded) / \(totalBytesExpected) = \(dPercentage)")
                        self.downloadLabel.text = "ダウンロード中: \(round(dPercentage*100)) %"

                    }
                }
                else if allMessages != nil && allMessages!.count > 0 {
                    
                    //サーバーから送られる最新の処理メッセージを確認
                    for i in 0..<allMessages!.count {
                        
                        let message = allMessages![i].description as String
                        
                        //一度のリクエストでダウンロードできるタイル数は1000,000タイルが上限
                        if message.containsString("ERROR 001564") {
                            limitDescription = message
                        }
                    }
                    
                    
                    
                }
            }
        }) { (localTiledLayer, error) -> Void in
            
            self.indicatorView.stopAnimating()
            self.agsMapView.userInteractionEnabled = true
            self.downloadLabel.hidden = true
            
            if error != nil {
                
                self.downloadBtn.enabled = true
                
                var errorMessage = ""
                if limitDescription.isEmpty {
                    errorMessage = error.localizedDescription
                } else {
                    errorMessage = limitDescription
                }
                
                //エラー表示
                UIAlertView(title: "エラー", message: errorMessage, delegate: nil, cancelButtonTitle: "OK").show()
                
            } else {
                
                self.resetBtn.enabled = true
                
                //タイル レイヤーを削除して、ダウンロードしたタイルをマップに追加
                self.agsMapView.reset()
                self.agsMapView.addMapLayer(localTiledLayer, withName:"Local Tiled Layer")
                if localTiledLayer.maxScale < MaxScale {
                    self.agsMapView.maxScale = MaxScale
                }
                
                UIAlertView(title: "ダウンロード完了", message: "ダウンロードしたタイルをマップに表示します", delegate: nil, cancelButtonTitle: "OK").show()
                BackgroundHelper.postLocalNotificationIfAppNotActive("タイルのダウンロードが完了しました。")
                
                self.resetBtn.enabled = true
                
            }
        }
        
        self.indicatorView.startAnimating()
        self.downloadLabel.text = "ダウンロードの準備中"

        
    }
    
    
    func resetMap(sender: UIBarButtonItem) {
        
        //ダウンロードしたタイルを削除して、タイル レイヤーをマップに追加
        self.agsMapView.reset()
        self.agsMapView.addMapLayer(self.tiledLayer, withName:"World Street Map")
        
        let agsGeomEngine = AGSGeometryEngine.defaultGeometryEngine()
        let agsPoint = AGSPoint(x: 139.730451, y: 35.665577, spatialReference: AGSSpatialReference(WKID:4326))
        let agsProjectedPoint = agsGeomEngine.projectGeometry(agsPoint, toSpatialReference: AGSSpatialReference(WKID:102100)) as! AGSPoint
        self.agsMapView.zoomToScale(36111.909643, withCenterPoint: agsProjectedPoint, animated: true)
        self.agsMapView.maxScale = MaxScale
        
        self.resetBtn.enabled = false
        self.downloadBtn.enabled = true
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

