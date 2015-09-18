//
//  CustomSymbolViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS

class CustomSymbolViewController: UIViewController {
    
    
    var agsMapView: AGSMapView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(self.agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        self.agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //グラフィックスレイヤーの追加
        let agsGraphicsLayer = AGSGraphicsLayer(fullEnvelope: self.agsMapView.maxEnvelope, renderingMode: .Dynamic)
        self.agsMapView.addMapLayer(agsGraphicsLayer, withName:"Graphics Layer")

        let point = AGSPoint(x: 15554789.5566484, y: 4254781.24130285, spatialReference:AGSSpatialReference(WKID: 102100))
        self.agsMapView.zoomToScale(100000, withCenterPoint: point, animated: true)

        //マーカーシンボルを作成してグラフィックスレイヤーに追加
        let agsMarkerSymbol = AGSPictureMarkerSymbol(image: self.getImage())
        let pointGraphic = AGSGraphic(geometry: point, symbol: agsMarkerSymbol, attributes: nil)
        agsGraphicsLayer.addGraphic(pointGraphic)
        
        //テキストシンボルを作成してグラフィックスレイヤーに追加
        let agsTextSym = AGSTextSymbol()
        agsTextSym.text = "東京ミッドタウン"
        agsTextSym.fontSize = 20.0
        agsTextSym.fontFamily = "Hiragino Kaku Gothic ProN W6"
        agsTextSym.bold = true
        agsTextSym.color = UIColor.blackColor()
        
        let agsTextGraphic = AGSGraphic(geometry: point, symbol: agsTextSym, attributes: nil)
        agsGraphicsLayer.addGraphic(agsTextGraphic)
        
        
        let slider = UISlider(frame: CGRectMake(0, 100, self.view.frame.size.width, 50))
        slider.minimumValue = -180.0
        slider.maximumValue = 180.0
        slider.addTarget(self, action: "sliderEvent:", forControlEvents: .ValueChanged)
        self.view.addSubview(slider)

    }
    
    
    func sliderEvent(sender: UISlider) {
        
        //レイヤー名を指定して、マップ上のレイヤーを取得
        let graphicsLayer = self.agsMapView.mapLayerForName("Graphics Layer") as! AGSGraphicsLayer
        
        //シンボルをUISliderの値に応じて回転
        let agsPointGraphic = graphicsLayer.graphics[0] as! AGSGraphic
        let pointSymbol = agsPointGraphic.symbol as! AGSPictureMarkerSymbol
        pointSymbol.angle = Double(-sender.value)
        
        let agsTextGraphic = graphicsLayer.graphics[1] as! AGSGraphic
        let textSymbol = agsTextGraphic.symbol as! AGSTextSymbol
        textSymbol.angle = Double(-sender.value)
        
    }
    
    
    func getImage() -> UIImage {
        
        //マーカーシンボルに表示する画像を作成する
        UIGraphicsBeginImageContext(CGSizeMake(48, 48))
        let context = UIGraphicsGetCurrentContext()
        CGContextSetAllowsAntialiasing(context, true)
        CGContextSetShouldAntialias(context, true)
        CGContextSaveGState(context)
        
        CGContextSetShadow(context, CGSizeMake(2, 6), 1)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextFillEllipseInRect(context, CGRectMake(0, 0, 36, 36))
        CGContextRestoreGState(context)

        let myGradient:CGGradientRef
        let myColorspace:CGColorSpaceRef
        let num_locations:size_t = 5
        let locations:[CGFloat] = [ 0.00, 0.2528, 0.5955, 0.7865, 1 ]
        let components:[CGFloat] = [1.0, 1.0, 1,0, 0.9, 1.0, 0.992157, 0.917647, 0.9, 0.878431, 0.854902, 0.811765, 0.9, 0.956863, 0.956863, 0.956863, 0.9, 0.882353, 0.870588, 0.780392, 0.9]
        
        myColorspace = CGColorSpaceCreateDeviceRGB()!
        myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, num_locations)!
        
        let myStartPoint = CGPoint(x: 12, y: 12), myEndPoint = CGPoint(x: 16, y: 16)
        let myStartRadius = CGFloat(0)
        let myEndRadius = CGFloat(28)
        
        CGContextAddEllipseInRect(context, CGRectMake(0, 0, 36, 36))
        CGContextClip(context)
        CGContextDrawRadialGradient(context, myGradient, myStartPoint, myStartRadius, myEndPoint, myEndRadius, CGGradientDrawingOptions.DrawsAfterEndLocation)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}