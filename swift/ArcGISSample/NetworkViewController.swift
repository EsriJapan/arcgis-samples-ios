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
    var stopPoints: NSMutableArray!
    var directionIndex: Int = 0
    var pointIndex: Int = 0


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(self.agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        self.agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //初期表示範囲の設定
        let point = AGSPoint(x: 15554789.5566484, y: 4254781.24130285, spatialReference:AGSSpatialReference(WKID: 102100))
        self.agsMapView .zoomToScale(50000, withCenterPoint: point, animated: true)
        
        //認証の設定:検証用（ArcGIS Onlineのユーザー名とパスワードを指定）
        let credntial = AGSCredential(user: "<ユーザー名>", password: "<パスワード>", authenticationType: .Token)

        //ルート検索用のサービスURLの指定
        let networkUrl = NSURL(string: "https://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World")
        self.agsRouteTask = AGSRouteTask(URL: networkUrl, credential: credntial)
        self.agsRouteTask.delegate = self

        //検索結果のルートを表示するためのグラフィックスレイヤーを追加
        let graphicsLayer = AGSGraphicsLayer()
        self.agsMapView.addMapLayer(graphicsLayer, withName:"Graphics Layer")
        
        //通過ポイントを表示するためのグラフィックスレイヤーを追加
        let agsStopsLayer = AGSGraphicsLayer()
        self.agsMapView.addMapLayer(agsStopsLayer, withName:"Stops Layer")
        
        //通過ポイント格納用
        self.stopPoints = NSMutableArray()
        
        self.directionLabel = UILabel(frame: CGRectMake(0, 100, self.view.frame.size.width, 30))
        self.directionLabel.backgroundColor = UIColor.darkGrayColor()
        self.directionLabel.alpha = 0.8
        self.directionLabel.textColor = UIColor.whiteColor()
        self.directionLabel.adjustsFontSizeToFitWidth = true
        self.view.addSubview(self.directionLabel)
        
        self.directionLabel.layer.cornerRadius = 10.0
        self.directionLabel.clipsToBounds = true
        self.directionLabel.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.directionLabel.layer.borderWidth = 3.0
        
        let buttonAdd = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addStop:")
        let buttonSolve = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "networkSolve:")
        let buttonClear = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "clearStops:")
        let buttonNext = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "moveToNextPoint:")
        
        let buttons = ([buttonAdd, buttonSolve, buttonClear, buttonNext])
        let toolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44))
        toolbar.setItems(buttons as [UIBarButtonItem], animated: true)
        self.view .addSubview(toolbar)
        
        //マップの中心にカーソルを表示
        self.drawCenterSign()
        
    }
    
    
    func drawCenterSign() {
        
        UIGraphicsBeginImageContext(CGSizeMake(20, 20))
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextSetLineWidth(context, 1.0)
        CGContextMoveToPoint(context, 10, 0)
        CGContextAddLineToPoint(context, 10, 20)
        CGContextMoveToPoint(context, 0, 10)
        CGContextAddLineToPoint(context, 20, 10)
        CGContextStrokePath(context)
        
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        
        CGContextSetLineWidth(context, 1.0)
        CGContextMoveToPoint(context, 10, 9)
        CGContextAddLineToPoint(context, 10, 11)
        CGContextMoveToPoint(context, 9, 10)
        CGContextAddLineToPoint(context, 11, 9)
        CGContextStrokePath(context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let caLayer = CALayer()
        caLayer.frame = CGRectMake(self.agsMapView.frame.size.width / 2 - 10, self.agsMapView.frame.size.height / 2 - 10, 20, 20)
        caLayer.contents = image.CGImage
        self.view.layer.addSublayer(caLayer)
        
    }
    
    func addStop(sender: UIBarButtonItem) {

        
        //通過ポイントをグラフィックスレイヤーに追加
        let agsPoint = self.agsMapView.visibleAreaEnvelope.center
        let agsSym = self.stopSymbol()
        let agsGraphic = AGSGraphic(geometry: agsPoint, symbol: agsSym, attributes: nil)
        (self.agsMapView.mapLayerForName("Stops Layer") as! AGSGraphicsLayer).addGraphic(agsGraphic)
        
        //通過ポイントを配列に格納
        let agsStopGraphic = AGSStopGraphic(geometry: agsPoint, symbol: agsSym, attributes: nil)
        self.stopPoints.addObject(agsStopGraphic)
        
    }
    
    
    func clearStops(sender: UIBarButtonItem) {
        
        (self.agsMapView.mapLayerForName("Graphics Layer") as! AGSGraphicsLayer).removeAllGraphics()
        (self.agsMapView.mapLayerForName("Stops Layer") as! AGSGraphicsLayer).removeAllGraphics()

        self.directionLabel.text = ""
        self.stopPoints.removeAllObjects()
        self.agsRouteResult = nil
        
    }
    
    func networkSolve(sender: UIBarButtonItem) {
        
        self.pointIndex = 0
        self.directionIndex = 0
        
        //通過ポイントが2点以上ある場合
        if self.stopPoints.count > 1 {
            
            //ルート検索用のパラメータを設定
            let agsRouteTaskParams = AGSRouteTaskParameters()
            agsRouteTaskParams.directionsLanguage = "ja-JP"
            agsRouteTaskParams.returnRouteGraphics = true
            agsRouteTaskParams.returnDirections = true
            agsRouteTaskParams.outSpatialReference = AGSSpatialReference(WKID :102100)
            agsRouteTaskParams.setStopsWithFeatures(self.stopPoints as [AnyObject])
            
            //ルート検索を実行
            self.agsRouteTask.solveWithParameters(agsRouteTaskParams)
            
        } else {
            
            let alert = UIAlertController(title:"確認", message: "通過点を2ポイント以上追加してください。", preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    
    func routeTask(routeTask: AGSRouteTask!, operation op: NSOperation!, didFailSolveWithError error: NSError!) {
        
        //ルート検索の処理に失敗した場合にエラー内容を表示
        let alert = UIAlertController(title:"ルートを検索できませんでした。", message: "Error:" + error.description, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func routeTask(routeTask: AGSRouteTask!, operation op: NSOperation!, didSolveWithResult routeTaskResult: AGSRouteTaskResult!) {
        
        //検索結果のルートデータを取得
        self.agsRouteResult = routeTaskResult.routeResults.last as! AGSRouteResult

        //検索結果のルートデータをグラフィックレイヤに表示
        let agsGraphic = self.agsRouteResult.routeGraphic
        agsGraphic.symbol = self.routeSymbol()
        (self.agsMapView.mapLayerForName("Graphics Layer") as! AGSGraphicsLayer).addGraphic(agsGraphic)
        
        //検索結果のルートデータにズーム
        let agsEnvelope: AnyObject = self.agsRouteResult.routeGraphic.geometry.envelope.mutableCopy()
        agsEnvelope.expandByFactor(2.0)
        self.agsMapView.zoomToEnvelope(agsEnvelope as! AGSEnvelope, animated: true)
        
    }
    
    
    func routeSymbol() -> AGSCompositeSymbol {
        
        //検索結果のルートシンボルの作成
        let rs = AGSCompositeSymbol()
        
        let sls1 = AGSSimpleLineSymbol()
        sls1.color = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.9)
        sls1.style = .Solid
        sls1.width = 8
        rs.addSymbol(sls1)
        
        let sls2 = AGSSimpleLineSymbol()
        sls2.color = UIColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 0.4)
        sls2.style = .Solid;
        sls2.width = 4
        rs.addSymbol(sls2)
        
        return rs
    }

    func stopSymbol() -> AGSCompositeSymbol {
        
        //通過ポイントシンボルの作成
        let ss = AGSCompositeSymbol()
        
        let sms1 = AGSSimpleMarkerSymbol()
        sms1.color = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.9)
        sms1.style = .Circle
        sms1.size = CGSizeMake(18,18)
        ss.addSymbol(sms1)
        
        let sms2 = AGSSimpleMarkerSymbol()
        sms2.color = UIColor.magentaColor()
        sms2.style = .Circle
        sms2.size = CGSizeMake(14, 14)
        ss.addSymbol(sms2)
        
        return ss

    }
    
    func moveToNextPoint(sender: UIBarButtonItem) {

        if self.agsRouteResult == nil {
            return
        }
        
        //検索結果のルートデータの道順を表示する
        let agsDirections = self.agsRouteResult.directions
        let agsDirectionGraphic = agsDirections.graphics[self.directionIndex] as! AGSDirectionGraphic
        
        self.directionLabel.text = "  " + agsDirectionGraphic.text
        
        let agsDirectionPoly = agsDirectionGraphic.geometry as! AGSPolyline
        let agsPoint = agsDirectionPoly.pointOnPath(0, atIndex: self.pointIndex)
        self.agsMapView.centerAtPoint(agsPoint, animated: true)
        
        if self.pointIndex == agsDirectionPoly.numPointsInPath(0) - 1 {
            self.pointIndex = 0
            if self.directionIndex == agsDirections.graphics.count - 1 {
                self.directionIndex = 0
            } else {
                self.directionIndex++
            }
        } else {
            self.pointIndex++
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}