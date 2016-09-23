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
        
        agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        let point = AGSPoint(x: 15554789.5566484, y: 4254781.24130285, spatialReference:AGSSpatialReference(wkid: 102100))
        agsMapView .zoom(toScale: 50000, withCenter: point, animated: true)
        
        //認証の設定:検証用（ArcGIS Onlineのユーザー名とパスワードを指定）
        let credntial = AGSCredential(user: "<ユーザー名>", password: "<パスワード>", authenticationType: .token)


        //到達圏解析用のサービスURLの指定
        let saUrl = URL(string: "https://route.arcgis.com/arcgis/rest/services/World/ServiceAreas/NAServer/ServiceArea_World")
        agsSaTask = AGSServiceAreaTask(url: saUrl, credential: credntial)
        agsSaTask.delegate = self
        
        //検索結果の到達圏（ポリゴン）を表示するためのグラフィックスレイヤーを追加
        let agsResultsLayer:AGSGraphicsLayer = AGSGraphicsLayer()
        agsMapView.addMapLayer(agsResultsLayer, withName:"Graphics Layer")
        
        //解析地点（ポイント）を表示するためのグラフィックスレイヤーを追加
        let agsFacilitiesLayer:AGSGraphicsLayer = AGSGraphicsLayer()
        agsMapView.addMapLayer(agsFacilitiesLayer, withName:"Facilities Layer")
        
        
        let buttonSolve = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ServiceAreaViewController.networkSolve))
        let buttonClear = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(ServiceAreaViewController.clearStops))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        
        let buttons = ([buttonSolve, flexibleItem, buttonClear])
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height - 44, width: view.frame.size.width, height: 44))
        toolbar.setItems(buttons as [UIBarButtonItem], animated: true)
        view.addSubview(toolbar)
        
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
    
    
    func clearStops(_ sender: UIBarButtonItem) {
        
        //グラフィックスレイヤーに追加されたグラフィックを削除
        (agsMapView.mapLayer(forName: "Graphics Layer") as! AGSGraphicsLayer).removeAllGraphics()
        (agsMapView.mapLayer(forName: "Facilities Layer") as! AGSGraphicsLayer).removeAllGraphics()
        
    }
    
    
    func networkSolve(_ sender: UIBarButtonItem) {
        
        //解析地点のポイントを作成しグラフィックスレイヤーに追加
        let agsPoint = agsMapView.visibleAreaEnvelope.center
        let agsSym = AGSSimpleMarkerSymbol()
        agsSym.color = UIColor.magenta
        agsSym.size = CGSize(width: 12, height: 12)
        
        let agsGraphic = AGSGraphic(geometry: agsPoint, symbol: agsSym, attributes: nil)
        (agsMapView.mapLayer(forName: "Facilities Layer") as! AGSGraphicsLayer).addGraphic(agsGraphic)

        //到達圏解析用のパラメータを設定
        let agsSaTaskParams = AGSServiceAreaTaskParameters()

        //解析地点ポイントの配列
        let agsFacilityGraphic:Any = AGSFacilityGraphic(point: agsPoint, name: "Facility Point")
        let facilities = [agsFacilityGraphic]
        let agsFeatSet = AGSFeatureSet(features: facilities)

    
        //解析する到達圏（分）の配列
        let breaks = [3, 5]
        
        agsSaTaskParams.outSpatialReference = AGSSpatialReference(wkid: 102100)
        agsSaTaskParams.facilities = agsFeatSet
        agsSaTaskParams.returnFacilities = false
        agsSaTaskParams.returnPointBarriers = false
        agsSaTaskParams.returnPolylineBarriers = false
        agsSaTaskParams.returnPolygonBarriers = false
        agsSaTaskParams.outputPolygons = .detailed
        agsSaTaskParams.defaultBreaks = breaks
        
        //到達圏解析を実行
        agsSaTask.solveServiceArea(with: agsSaTaskParams)
        
    }
    
    
    func serviceAreaTask(_ serviceAreaTask: AGSServiceAreaTask!, operation op: Operation!, didSolveServiceAreaWith serviceAreaTaskResult: AGSServiceAreaTaskResult!) {
        
        //解析結果のポリゴン（5分の到達圏）にシンボルを設定しグラフィックスレイヤーに追加
        let agsGraphic1 = serviceAreaTaskResult.serviceAreaPolygons[0] as! AGSGraphic
        
        let agsOutlineSym1 = AGSSimpleLineSymbol()
        agsOutlineSym1.color = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        agsOutlineSym1.width = 1.5
        
        let agsSym1 = AGSSimpleFillSymbol()
        agsSym1.color = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5)
        agsSym1.style = .solid
        agsSym1.outline = agsOutlineSym1
        
        agsGraphic1.symbol = agsSym1
        (agsMapView.mapLayer(forName: "Graphics Layer") as! AGSGraphicsLayer).addGraphic(agsGraphic1)


        //解析結果のポリゴン（3分の到達圏）にシンボルを設定しグラフィックスレイヤーに追加
        let agsGraphic2 = serviceAreaTaskResult.serviceAreaPolygons[1] as! AGSGraphic
        
        let agsOutlineSym2 = AGSSimpleLineSymbol()
        agsOutlineSym2.color = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        agsOutlineSym2.width = 1.5
        
        let agsSym2 = AGSSimpleFillSymbol()
        agsSym2.color = UIColor(red: 0, green: 0, blue: 1.0, alpha: 0.5)
        agsSym2.style = .solid;
        agsSym2.outline = agsOutlineSym2
        
        agsGraphic2.symbol = agsSym2
        (agsMapView.mapLayer(forName: "Graphics Layer") as! AGSGraphicsLayer).addGraphic(agsGraphic2)
        
        
        //解析結果のポリゴン（5分の到達圏）にズーム
        let agsPolygon = agsGraphic1.geometry as! AGSPolygon
        agsMapView.zoom(to: agsPolygon.envelope, animated: true)

    }
    
    
    func serviceAreaTask(_ serviceAreaTask: AGSServiceAreaTask!, operation op: Operation!, didFailSolveWithError error: Error!) {
        
        //到達圏解析の処理に失敗した場合にエラー内容を表示
        let alert = UIAlertController(title:"到達圏を検索できませんでした。", message: "Error:" + error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
