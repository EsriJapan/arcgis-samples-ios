//
//  NetworkViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//


import UIKit
import ArcGIS


class NetworkViewController: UIViewController, AGSRouteTaskDelegate {
    
    var agsMapView: AGSMapView!
    var agsRouteTask: AGSRouteTask!
    var agsRouteResult: AGSRouteResult!
    
    var directionLabel: UILabel!
    var stopPoints: [AGSStopGraphic]! = []
    var directionIndex: Int = 0
    var pointIndex: Int = 0


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //初期表示範囲の設定
        let point = AGSPoint(x: 15554789.5566484, y: 4254781.24130285, spatialReference:AGSSpatialReference(wkid: 102100))
        agsMapView .zoom(toScale: 50000, withCenter: point, animated: true)
        
        //認証の設定:検証用（ArcGIS Onlineのユーザー名とパスワードを指定）
        let credntial = AGSCredential(user: "<ユーザー名>", password: "<パスワード>", authenticationType: .token)


        //ルート検索用のサービスURLの指定
        let networkUrl = URL(string: "https://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World")
        agsRouteTask = AGSRouteTask(url: networkUrl, credential: credntial)
        agsRouteTask.delegate = self

        //検索結果のルートを表示するためのグラフィックスレイヤーを追加
        let graphicsLayer = AGSGraphicsLayer()
        agsMapView.addMapLayer(graphicsLayer, withName:"Graphics Layer")
        
        //通過ポイントを表示するためのグラフィックスレイヤーを追加
        let agsStopsLayer = AGSGraphicsLayer()
        agsMapView.addMapLayer(agsStopsLayer, withName:"Stops Layer")
        
        directionLabel = UILabel(frame: CGRect(x: 0, y: 100, width: view.frame.size.width, height: 30))
        directionLabel.backgroundColor = UIColor.darkGray
        directionLabel.alpha = 0.8
        directionLabel.textColor = UIColor.white
        directionLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(directionLabel)
        
        directionLabel.layer.cornerRadius = 10.0
        directionLabel.clipsToBounds = true
        directionLabel.layer.borderColor = UIColor.darkGray.cgColor
        directionLabel.layer.borderWidth = 3.0
        
        let buttonAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(NetworkViewController.addStop))
        let buttonSolve = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(NetworkViewController.networkSolve))
        let buttonClear = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(NetworkViewController.clearStops))
        let buttonNext = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(NetworkViewController.moveToNextPoint))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        
        let buttons = ([buttonAdd, flexibleItem, buttonSolve, flexibleItem, buttonClear, flexibleItem, buttonNext])
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height - 44, width: view.frame.size.width, height: 44))
        toolbar.setItems(buttons as [UIBarButtonItem], animated: true)
        view .addSubview(toolbar)
        
        //マップの中心にカーソルを表示
        drawCenterSign()
        
    }
    
    
    func drawCenterSign() {
        
        UIGraphicsBeginImageContext(CGSize(width: 20, height: 20))
        let context = UIGraphicsGetCurrentContext()
        
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setLineWidth(1.0)
        context?.move(to: CGPoint(x: 10, y: 0))
        context?.addLine(to: CGPoint(x: 10, y: 20))
        context?.move(to: CGPoint(x: 0, y: 10))
        context?.addLine(to: CGPoint(x: 20, y: 10))
        context?.strokePath()
        
        context?.setStrokeColor(UIColor.white.cgColor)
        
        context?.setLineWidth(1.0)
        context?.move(to: CGPoint(x: 10, y: 9))
        context?.addLine(to: CGPoint(x: 10, y: 11))
        context?.move(to: CGPoint(x: 9, y: 10))
        context?.addLine(to: CGPoint(x: 11, y: 9))
        context?.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let caLayer = CALayer()
        caLayer.frame = CGRect(x: agsMapView.frame.size.width / 2 - 10, y: agsMapView.frame.size.height / 2 - 10, width: 20, height: 20)
        caLayer.contents = image?.cgImage
        view.layer.addSublayer(caLayer)
        
    }
    
    func addStop(_ sender: UIBarButtonItem) {

        
        //通過ポイントをグラフィックスレイヤーに追加
        let agsPoint = agsMapView.visibleAreaEnvelope.center
        let agsSym = stopSymbol()
        let agsGraphic = AGSGraphic(geometry: agsPoint, symbol: agsSym, attributes: nil)
        (agsMapView.mapLayer(forName: "Stops Layer") as! AGSGraphicsLayer).addGraphic(agsGraphic)
        
        //通過ポイントを配列に格納
        let agsStopGraphic = AGSStopGraphic(geometry: agsPoint, symbol: agsSym, attributes: nil)
        stopPoints.append(agsStopGraphic!)
        
    }
    
    
    func clearStops(_ sender: UIBarButtonItem) {
        
        (agsMapView.mapLayer(forName: "Graphics Layer") as! AGSGraphicsLayer).removeAllGraphics()
        (agsMapView.mapLayer(forName: "Stops Layer") as! AGSGraphicsLayer).removeAllGraphics()

        directionLabel.text = ""
        stopPoints.removeAll()
        agsRouteResult = nil
        
    }
    
    func networkSolve(_ sender: UIBarButtonItem) {
        
        pointIndex = 0
        directionIndex = 0
        
        //通過ポイントが2点以上ある場合
        if stopPoints.count > 1 {
            
            //ルート検索用のパラメータを設定
            let agsRouteTaskParams = AGSRouteTaskParameters()
            agsRouteTaskParams.directionsLanguage = "ja-JP"
            agsRouteTaskParams.returnRouteGraphics = true
            agsRouteTaskParams.returnDirections = true
            agsRouteTaskParams.outSpatialReference = AGSSpatialReference(wkid :102100)
            agsRouteTaskParams.setStopsWithFeatures(stopPoints)
            
            //ルート検索を実行
            agsRouteTask.solve(with: agsRouteTaskParams)
            
        } else {
            
            let alert = UIAlertController(title:"確認", message: "通過点を2ポイント以上追加してください。", preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    func routeTask(_ routeTask: AGSRouteTask!, operation op: Operation!, didFailSolveWithError error: Error!) {
        
        //ルート検索の処理に失敗した場合にエラー内容を表示
        let alert = UIAlertController(title:"ルートを検索できませんでした。", message: "Error:" + error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func routeTask(_ routeTask: AGSRouteTask!, operation op: Operation!, didSolveWith routeTaskResult: AGSRouteTaskResult!) {
        
        //検索結果のルートデータを取得
        agsRouteResult = routeTaskResult.routeResults.last as! AGSRouteResult

        //検索結果のルートデータをグラフィックレイヤに表示
        let agsGraphic = agsRouteResult.routeGraphic
        agsGraphic?.symbol = routeSymbol()
        (agsMapView.mapLayer(forName: "Graphics Layer") as! AGSGraphicsLayer).addGraphic(agsGraphic)
        
        //検索結果のルートデータにズーム
        let agsEnvelope = agsRouteResult.routeGraphic.geometry.envelope.mutableCopy() as AnyObject
        agsEnvelope.expand(byFactor: 2.0)
        agsMapView.zoom(to: agsEnvelope as! AGSEnvelope, animated: true)
        
    }
    
    
    func routeSymbol() -> AGSCompositeSymbol {
        
        //検索結果のルートシンボルの作成
        let rs = AGSCompositeSymbol()
        
        let sls1 = AGSSimpleLineSymbol()
        sls1.color = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.9)
        sls1.style = .solid
        sls1.width = 8
        rs.addSymbol(sls1)
        
        let sls2 = AGSSimpleLineSymbol()
        sls2.color = UIColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 0.4)
        sls2.style = .solid;
        sls2.width = 4
        rs.addSymbol(sls2)
        
        return rs
    }

    func stopSymbol() -> AGSCompositeSymbol {
        
        //通過ポイントシンボルの作成
        let ss = AGSCompositeSymbol()
        
        let sms1 = AGSSimpleMarkerSymbol()
        sms1.color = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.9)
        sms1.style = .circle
        sms1.size = CGSize(width: 18,height: 18)
        ss.addSymbol(sms1)
        
        let sms2 = AGSSimpleMarkerSymbol()
        sms2.color = UIColor.magenta
        sms2.style = .circle
        sms2.size = CGSize(width: 14, height: 14)
        ss.addSymbol(sms2)
        
        return ss

    }
    
    func moveToNextPoint(_ sender: UIBarButtonItem) {

        if agsRouteResult == nil {
            return
        }
        
        //検索結果のルートデータの道順を表示する
        let agsDirections = agsRouteResult.directions
        let agsDirectionGraphic = agsDirections?.graphics[directionIndex] as! AGSDirectionGraphic
        
        directionLabel.text = "  " + agsDirectionGraphic.text
        
        let agsDirectionPoly = agsDirectionGraphic.geometry as! AGSPolyline
        let agsPoint = agsDirectionPoly.point(onPath: 0, at: pointIndex)
        agsMapView.center(at: agsPoint, animated: true)
        
        if pointIndex == agsDirectionPoly.numPoints(inPath: 0) - 1 {
            pointIndex = 0
            if directionIndex == (agsDirections?.graphics.count)! - 1 {
                directionIndex = 0
            } else {
                directionIndex += 1
            }
        } else {
            pointIndex += 1
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
