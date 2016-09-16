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
        
        let agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //スケッチしたグラフィック表示用のグラフィックスレイヤーの追加
        agsGraphicsLayer = AGSGraphicsLayer()
        agsMapView.addMapLayer(agsGraphicsLayer, withName:"Graphics Layer")
        
        //スケッチレイヤーの追加
        agsSketchGraphicsLayer = AGSSketchGraphicsLayer()
        agsSketchGraphicsLayer.midVertexSymbol = nil
        agsMapView.addMapLayer(agsSketchGraphicsLayer, withName:"Sketch Layer")
        
        //作成するジオメトリタイプの指定
        agsSketchGraphicsLayer.geometry = AGSMutablePolygon()
        agsMapView.touchDelegate = agsSketchGraphicsLayer
        
        
        let buttonUndo = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(SketchViewController.undoSketch))
        let buttonRedo = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(SketchViewController.redoSketch))
        let buttonRemove = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(SketchViewController.removeSketch))
        let buttonSubmit = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(SketchViewController.submitSketch))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)


        let buttons = ([buttonUndo, flexibleItem, buttonRedo, flexibleItem, buttonRemove, flexibleItem, buttonSubmit])
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height - 44, width: view.frame.size.width, height: 44))
        toolbar.setItems(buttons as [UIBarButtonItem], animated: true)
        view .addSubview(toolbar)
        
    }
    
    
    func undoSketch(_ sender: UIBarButtonItem) {
        
        //編集を元に戻す
        if (agsSketchGraphicsLayer.undoManager.canUndo) {
            agsSketchGraphicsLayer.undoManager.undo()
        }
        
    }
    
    func redoSketch(_ sender: UIBarButtonItem) {
        
        //編集をやり直す
        if (agsSketchGraphicsLayer.undoManager.canRedo) {
            agsSketchGraphicsLayer.undoManager.redo()
        }
        
    }
    
    func removeSketch(_ sender: UIBarButtonItem) {
        
        //選択されている頂点を削除する
        agsSketchGraphicsLayer.removeSelectedVertex()
        
    }
    
    
    func submitSketch(_ sender: UIBarButtonItem) {
        
        //作成したジオメトリからシンボルを指定してグラフィックを作成し、グラフィックスレイヤーに追加
        let fillSymbol = AGSSimpleFillSymbol(color: UIColor.purple .withAlphaComponent(0.25), outlineColor: UIColor.darkGray)
        let agsGraphic = AGSGraphic(geometry: agsSketchGraphicsLayer.geometry, symbol: fillSymbol, attributes: nil)
        
        agsGraphicsLayer.addGraphic(agsGraphic)
        agsSketchGraphicsLayer.clear()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
