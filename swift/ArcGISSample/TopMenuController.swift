//
//  TopMenuController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit

class TopMenuController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    
    private let items = [
        "LayersViewController",
        "SwipeViewController",
        "PerspectiveViewController",
        "GpsViewController",
        "SensorViewController",
        "LegendViewController",
        "MagnifierViewController",
        "SketchViewController",
        "WmsViewController",
        "TimeViewController",
        "WebmapViewController",
        "CustomSymbolViewController",
        "RotationRendererViewController",
        "SearchViewController",
        "AttachmentManagerViewController",
        "LocatorViewController",
        "NetworkViewController",
        "ServiceAreaViewController",
        "CoordinateConversionViewController",
        "JsonViewController"
    ]
    
    private let itemNames = [
        "レイヤの表示・非表示",
        "スワイプ",
        "パース表示",
        "ナビゲーション",
        "地図の回転",
        "凡例",
        "拡大鏡",
        "スケッチレイヤー",
        "WMSレイヤー",
        "時間対応レイヤー",
        "Webマップの表示",
        "シンボルの表示",
        "レンダラー",
        "属性検索",
        "写真の添付",
        "リバース ジオコーディング",
        "ルート検索",
        "到達圏解析",
        "座標変換",
        "JSONのエンコード・デコード"
    ]
    
    
    
    private var tableView: UITableView!
    private var myNavigationController: UINavigationController?

    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.title = "メニュー"
        tableView = UITableView(frame: self.view.bounds)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        cell.textLabel!.text = "\(itemNames[indexPath.row])"
        return cell
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let strTarget:String = "ArcGISSample."
        let strVC:String = items[indexPath.row] as String
        let className = strTarget + strVC
        
        if let theClass = NSClassFromString(className) as? UIViewController.Type {
            let controller = theClass.init(nibName: nil, bundle: nil)
            self.navigationController!.pushViewController(controller, animated: true)
        }


    }
        
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

