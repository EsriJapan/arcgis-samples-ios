//
//  SketchViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class SketchViewController: UIViewController{
    
    
    var agsGraphicsLayer: AGSGraphicsLayer!
    var agsSketchGraphicsLayer: AGSSketchGraphicsLayer!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //スケッチしたグラフィック表示用のグラフィックスレイヤーの追加
        self.agsGraphicsLayer = AGSGraphicsLayer()
        agsMapView.addMapLayer(self.agsGraphicsLayer, withName:"Graphics Layer")
        
        //スケッチレイヤーの追加
        self.agsSketchGraphicsLayer = AGSSketchGraphicsLayer()
        self.agsSketchGraphicsLayer.midVertexSymbol = nil
        agsMapView.addMapLayer(self.agsSketchGraphicsLayer, withName:"Sketch Layer")
        
        //作成するジオメトリタイプの指定
        self.agsSketchGraphicsLayer.geometry = AGSMutablePolygon()
        agsMapView.touchDelegate = self.agsSketchGraphicsLayer
        
        
        let buttonUndo = UIBarButtonItem(barButtonSystemItem: .Undo, target: self, action: "undoSketch:")
        let buttonRedo = UIBarButtonItem(barButtonSystemItem: .Redo, target: self, action: "redoSketch:")
        let buttonRemove = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "removeSketch:")
        let buttonSubmit = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "submitSketch:")

        let buttons = ([buttonUndo, buttonRedo, buttonRemove, buttonSubmit])
        let toolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44))
        toolbar.setItems(buttons as [UIBarButtonItem], animated: true)
        self.view .addSubview(toolbar)
        
    }
    
    
    func undoSketch(sender: UIBarButtonItem) {
        
        //編集を元に戻す
        if (self.agsSketchGraphicsLayer.undoManager.canUndo) {
            self.agsSketchGraphicsLayer.undoManager.undo()
        }
        
    }
    
    func redoSketch(sender: UIBarButtonItem) {
        
        //編集をやり直す
        if (self.agsSketchGraphicsLayer.undoManager.canRedo) {
            self.agsSketchGraphicsLayer.undoManager.redo()
        }
        
    }
    
    func removeSketch(sender: UIBarButtonItem) {
        
        //選択されている頂点を削除する
        self.agsSketchGraphicsLayer.removeSelectedVertex()
        
    }
    
    
    func submitSketch(sender: UIBarButtonItem) {
        
        //作成したジオメトリからシンボルを指定してグラフィックを作成し、グラフィックスレイヤーに追加
        let fillSymbol = AGSSimpleFillSymbol(color: UIColor.purpleColor() .colorWithAlphaComponent(0.25), outlineColor: UIColor.darkGrayColor())
        let agsGraphic = AGSGraphic(geometry: self.agsSketchGraphicsLayer.geometry, symbol: fillSymbol, attributes: nil)
        
        self.agsGraphicsLayer.addGraphic(agsGraphic)
        self.agsSketchGraphicsLayer.clear()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
