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
    var downloadLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //マップの作成
        agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        
        //マップの初期表示範囲と最大表示スケールの設定
        let agsGeomEngine = AGSGeometryEngine.default()
        let agsPoint = AGSPoint(x: 139.730451, y: 35.665577, spatialReference: AGSSpatialReference(wkid:4326))
        let agsProjectedPoint = agsGeomEngine?.projectGeometry(agsPoint, to: AGSSpatialReference(wkid:102100)) as! AGSPoint
        agsMapView.zoom(toScale: 36111.909643, withCenter: agsProjectedPoint, animated: true)
        agsMapView.maxScale = MaxScale
        
        
        //ArcGIS for Developers のアカウントのユーザー名とパスワードを入力（検証用）
        let agsCredential = AGSCredential(user: "<ユーザー名>", password: "<パスワード>")
        
        //ArcGIS Online のベースマップ（タイルのダウンロード専用）の URL を設定
        let tileServiceURL = "https://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Street_Map/MapServer"
        
        //タイル レイヤーをマップに追加
        //レイヤー読み込みのためのデリゲートを設定
        let tiledUrl = URL(string: tileServiceURL)
        tiledLayer = AGSTiledMapServiceLayer(url: tiledUrl, credential: agsCredential)
        tiledLayer.delegate  = self
        agsMapView.addMapLayer(tiledLayer, withName:"World Street Map")
        
        
        //タイルのエクスポート用タスクを作成
        if exportTileTask == nil {
            exportTileTask = AGSExportTileCacheTask(url: tiledUrl, credential: agsCredential)
        }
        
        //ダウンロード ボタンの追加
        downloadBtn = UIBarButtonItem(title: "ダウンロード", style: .plain, target: self, action: #selector(ExportTilesViewController.exportTiles))
        resetBtn = UIBarButtonItem(title: "リセット", style: .plain, target: self, action: #selector(ExportTilesViewController.resetMap))
        downloadBtn.isEnabled = false
        resetBtn.isEnabled = false
        
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let buttons = ([downloadBtn, flexibleItem, resetBtn])
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height - 44, width: view.frame.size.width, height: 44))
        
        toolbar.setItems(buttons as? [UIBarButtonItem], animated: true)
        view.addSubview(toolbar)
        
        
        //ラベルの作成
        downloadLabel = UILabel(frame: CGRect(x: 0,y: 0,width: 200,height: 30))
        downloadLabel.layer.masksToBounds = true
        downloadLabel.layer.cornerRadius = 10.0
        downloadLabel.textColor = UIColor.darkGray
        downloadLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        downloadLabel.textAlignment = NSTextAlignment.center
        downloadLabel.layer.position = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        view.addSubview(downloadLabel)
        downloadLabel.isHidden = true
        
    }
    
    
    func layer(_ layer: AGSLayer!, didFailToLoadWithError error: Error!) {
        //タイル レイヤーの読み込みのエラー
        let alert = UIAlertController(title:"エラー", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    func layerDidLoad(_ layer: AGSLayer!) {
        //タイル レイヤーの読み込み完了
        downloadBtn.isEnabled = true
    }
    
    
    
    func exportTiles(sender: UIBarButtonItem) {
        
        agsMapView.isUserInteractionEnabled = false
        downloadLabel.isHidden = false
        downloadBtn.isEnabled = false
        
        var limitDescription = ""
        
        //ダウンロードするマップの範囲を設定（現在の表示範囲）
        let currentExtent = agsMapView.visibleAreaEnvelope
        
        //現在のマップ表示のスケール レベルを取得
        let currentLevel = tiledLayer.currentLOD().level - 1
        
        //ダウンロードするマップのスケール レベルを設定（現在のレベルから高縮尺の3レベル）
        let desiredLevels =  [currentLevel, currentLevel + 1, currentLevel + 2]

        //タイルのスケール レベルとマップの範囲をもとにパラメーターを作成
        let params = AGSExportTileCacheParams(levelsOfDetail: desiredLevels, areaOfInterest:currentExtent)
        
        //パラメーターを指定してタイルのダウンロードを実行
        exportTileTask.exportTileCache(withParameters: params, downloadFolderPath: nil, useExisting: true, status: { (status, userInfo) -> Void in
            
            //処理のステータスを確認
            print("\(AGSResumableTaskJobStatusAsString(status)), \(userInfo)")
            if userInfo != nil {
                
                let allMessages =  userInfo?["messages"] as? [AGSGPMessage]
                
                //ダウンロードの進捗表示
                if status == .fetchingResult {
                    let totalBytesDownloaded = userInfo?["AGSDownloadProgressTotalBytesDownloaded"] as? Double
                    let totalBytesExpected = userInfo?["AGSDownloadProgressTotalBytesExpected"] as? Double
                    if totalBytesDownloaded != nil && totalBytesExpected != nil {
                        let dPercentage = totalBytesDownloaded!/totalBytesExpected!
                        print("\(totalBytesDownloaded) / \(totalBytesExpected) = \(dPercentage)")
                        self.downloadLabel.text = "ダウンロード中: \(round(dPercentage*100)) %"

                    }
                }
                else if allMessages != nil && allMessages!.count > 0 {
                    
                    //サーバーから送られる最新の処理メッセージを確認
                    for i in 0..<allMessages!.count {
                        
                        let message = allMessages![i].description
                        
                        //一度のリクエストでダウンロードできるタイル数は100,000タイルが上限
                        if message.contains("ERROR 001564"){
                            limitDescription = message
                        }
                    }

                }
            }
        }) { (localTiledLayer, error) -> Void in
            
            self.agsMapView.isUserInteractionEnabled = true
            self.downloadLabel.isHidden = true
            
            if error != nil {
                
                self.downloadBtn.isEnabled = true
                
                var errorMessage = ""
                if limitDescription.isEmpty {
                    errorMessage = (error?.localizedDescription)!
                } else {
                    errorMessage = limitDescription
                }
                
                //エラー表示
                UIAlertView(title: "エラー", message: errorMessage, delegate: nil, cancelButtonTitle: "OK").show()
                
            } else {
                
                self.resetBtn.isEnabled = true
                
                //タイル レイヤーを削除して、ダウンロードしたタイルをマップに追加
                self.agsMapView.reset()
                self.agsMapView.addMapLayer(localTiledLayer, withName:"Local Tiled Layer")
                if (localTiledLayer?.maxScale)! < MaxScale {
                    self.agsMapView.maxScale = MaxScale
                }
                
                UIAlertView(title: "ダウンロード完了", message: "ダウンロードしたタイルをマップに表示します", delegate: nil, cancelButtonTitle: "OK").show()
                BackgroundHelper.postLocalNotificationIfAppNotActive(message: "タイルのダウンロードが完了しました。")
                
                self.resetBtn.isEnabled = true
                
            }
        }
        
        downloadLabel.text = "ダウンロードの準備中"

        
    }
    
    
    func resetMap(sender: UIBarButtonItem) {
        
        //ダウンロードしたタイルを削除して、タイル レイヤーをマップに追加
        agsMapView.reset()
        agsMapView.addMapLayer(tiledLayer, withName:"World Street Map")
        
        let agsGeomEngine = AGSGeometryEngine.default()
        let agsPoint = AGSPoint(x: 139.730451, y: 35.665577, spatialReference: AGSSpatialReference(wkid:4326))
        let agsProjectedPoint = agsGeomEngine?.projectGeometry(agsPoint, to: AGSSpatialReference(wkid:102100)) as! AGSPoint
        agsMapView.zoom(toScale: 36111.909643, withCenter: agsProjectedPoint, animated: true)
        agsMapView.maxScale = MaxScale
        
        resetBtn.isEnabled = false
        downloadBtn.isEnabled = true
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

