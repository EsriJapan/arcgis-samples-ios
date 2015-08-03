//
//  ServiceAreaViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//


import UIKit
import ArcGIS


class ServiceAreaViewController: UIViewController, AGSServiceAreaTaskDelegate {
    
    var agsMapView: AGSMapView!
    var agsSaTask: AGSServiceAreaTask!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(self.agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        self.agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        let point = AGSPoint(x: 15554789.5566484, y: 4254781.24130285, spatialReference:AGSSpatialReference(WKID: 102100))
        self.agsMapView .zoomToScale(50000, withCenterPoint: point, animated: true)
        
        //認証の設定:検証用（ArcGIS Onlineのユーザー名とパスワードを指定）
        let credntial = AGSCredential(user: "<ユーザー名>", password: "<パスワード>", authenticationType: .Token)
        
        //到達圏解析用のサービスURLの指定
        let saUrl = NSURL(string: "https://route.arcgis.com/arcgis/rest/services/World/ServiceAreas/NAServer/ServiceArea_World")
        self.agsSaTask = AGSServiceAreaTask(URL: saUrl, credential: credntial)
        self.agsSaTask.delegate = self
        
        //検索結果の到達圏（ポリゴン）を表示するためのグラフィックスレイヤーを追加
        let agsResultsLayer:AGSGraphicsLayer = AGSGraphicsLayer()
        self.agsMapView.addMapLayer(agsResultsLayer, withName:"Graphics Layer")
        
        //解析地点（ポイント）を表示するためのグラフィックスレイヤーを追加
        let agsFacilitiesLayer:AGSGraphicsLayer = AGSGraphicsLayer()
        self.agsMapView.addMapLayer(agsFacilitiesLayer, withName:"Facilities Layer")
        
        
        let buttonSolve = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "networkSolve:")
        let buttonClear = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "clearStops:")
        
        var buttons = ([buttonSolve, buttonClear])
        var toolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44))
        toolbar.setItems(buttons as [AnyObject], animated: true)
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
    
    
    func clearStops(sender: UIBarButtonItem) {
        
        //グラフィックスレイヤーに追加されたグラフィックを削除
        (self.agsMapView.mapLayerForName("Graphics Layer") as! AGSGraphicsLayer).removeAllGraphics()
        (self.agsMapView.mapLayerForName("Facilities Layer") as! AGSGraphicsLayer).removeAllGraphics()
        
    }
    
    
    func networkSolve(sender: UIBarButtonItem) {
        
        //解析地点のポイントを作成しグラフィックスレイヤーに追加
        let agsPoint = self.agsMapView.visibleAreaEnvelope.center
        let agsSym = AGSSimpleMarkerSymbol()
        agsSym.color = UIColor.magentaColor()
        agsSym.size = CGSizeMake(12, 12)
        
        let agsGraphic = AGSGraphic(geometry: agsPoint, symbol: agsSym, attributes: nil)
        (self.agsMapView.mapLayerForName("Facilities Layer") as! AGSGraphicsLayer).addGraphic(agsGraphic)

        //到達圏解析用のパラメータを設定
        let agsSaTaskParams = AGSServiceAreaTaskParameters()

        //解析地点ポイントの配列
        let agsFacilityGraphic = AGSFacilityGraphic(point: agsPoint, name: "Facility Point")
        let facilities = [agsFacilityGraphic]
        let agsFeatSet = AGSFeatureSet(features: facilities)
    
        //解析する到達圏（分）の配列
        let breaks = [3, 5]
        
        agsSaTaskParams.outSpatialReference = AGSSpatialReference(WKID: 102100)
        agsSaTaskParams.facilities = agsFeatSet
        agsSaTaskParams.returnFacilities = false
        agsSaTaskParams.returnPointBarriers = false
        agsSaTaskParams.returnPolylineBarriers = false
        agsSaTaskParams.returnPolygonBarriers = false
        agsSaTaskParams.outputPolygons = .Simplified
        agsSaTaskParams.defaultBreaks = breaks
        
        //到達圏解析を実行
        self.agsSaTask.solveServiceAreaWithParameters(agsSaTaskParams)
        
    }
    
    
    func serviceAreaTask(serviceAreaTask: AGSServiceAreaTask!, operation op: NSOperation!, didSolveServiceAreaWithResult serviceAreaTaskResult: AGSServiceAreaTaskResult!) {
        
        //解析結果のポリゴン（5分の到達圏）にシンボルを設定しグラフィックスレイヤーに追加
        let agsGraphic1 = serviceAreaTaskResult.serviceAreaPolygons[0] as! AGSGraphic
        
        let agsOutlineSym1 = AGSSimpleLineSymbol()
        agsOutlineSym1.color = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        agsOutlineSym1.width = 1.5
        
        let agsSym1 = AGSSimpleFillSymbol()
        agsSym1.color = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5)
        agsSym1.style = .Solid
        agsSym1.outline = agsOutlineSym1
        
        agsGraphic1.symbol = agsSym1
        (self.agsMapView.mapLayerForName("Graphics Layer") as! AGSGraphicsLayer).addGraphic(agsGraphic1)


        //解析結果のポリゴン（3分の到達圏）にシンボルを設定しグラフィックスレイヤーに追加
        let agsGraphic2 = serviceAreaTaskResult.serviceAreaPolygons[1] as! AGSGraphic
        
        let agsOutlineSym2 = AGSSimpleLineSymbol()
        agsOutlineSym2.color = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        agsOutlineSym2.width = 1.5
        
        let agsSym2 = AGSSimpleFillSymbol()
        agsSym2.color = UIColor(red: 0, green: 0, blue: 1.0, alpha: 0.5)
        agsSym2.style = .Solid;
        agsSym2.outline = agsOutlineSym2
        
        agsGraphic2.symbol = agsSym2
        (self.agsMapView.mapLayerForName("Graphics Layer") as! AGSGraphicsLayer).addGraphic(agsGraphic2)
        
        
        //解析結果のポリゴン（5分の到達圏）にズーム
        let agsPolygon = agsGraphic1.geometry as! AGSPolygon
        self.agsMapView.zoomToEnvelope(agsPolygon.envelope, animated: true)

    }
    
    
    func serviceAreaTask(serviceAreaTask: AGSServiceAreaTask!, operation op: NSOperation!, didFailSolveWithError error: NSError!) {
        
        //到達圏解析の処理に失敗した場合にエラー内容を表示
        let alert = UIAlertController(title:"到達圏を検索できませんでした。", message: "Error:" + error.description, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}