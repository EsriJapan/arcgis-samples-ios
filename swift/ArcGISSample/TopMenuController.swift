//
//  TopMenuController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit

class TopMenuController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    
    let items = [
        "GpsViewController",
        "SpatialQueryViewController",
        "SwipeViewController",
        "AppLoginViewController",
        "ElevationViewController",
        "SceneLayerViewController",
        "SceneGraphicsViewController",
        "FeatureLayerViewController",
        "ExtrusionRendererViewController"
    ]
    
    let itemNames = [
        "ナビゲーション",
        "空間検索",
        "スワイプ",
        "アプリ認証",
        "地形表示（3D）",
        "景観表示（3D）",
        "グラフィック表示（3D）",
        "レイヤーの表示（3D）",
        "レイヤーの立ち上げ（3D）"
    ]
    
    
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = "メニュー"
        tableView = UITableView(frame: view.bounds)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        cell.textLabel!.text = "\(itemNames[indexPath.row])"
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let strTarget:String = "ArcGISSample."
        let strVC:String = items[indexPath.row] as String
        let className = strTarget + strVC
        
        if let theClass = NSClassFromString(className) as? UIViewController.Type {
            let controller = theClass.init(nibName: nil, bundle: nil)
            navigationController!.pushViewController(controller, animated: true)
        }

    }
        
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

