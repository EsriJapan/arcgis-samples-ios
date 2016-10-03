//
//  AppLoginViewController.swift
//  ArcGISSample
//
//  Created by esrij on H28/09/16.
//  Copyright © 平成28年 esrij. All rights reserved.
//

import UIKit
import ArcGIS



//プライベートなサービスにアクセスするためにアプリ認証をクライアント側で実装するサンプル
//アプリの登録と認証: http://esrijapan.github.io/arcgis-dev-resources/register-app/

class AppLoginViewController: UIViewController {
    
    var mapView: AGSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //マップの作成
        mapView = AGSMapView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view.addSubview(self.mapView)
        
        //タイルマップサービスレイヤーの追加
        let tiledMapServiceLayer = AGSTiledMapServiceLayer (url: URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"))
        mapView.addMapLayer(tiledMapServiceLayer, withName:"Tiled Map Service Layer")
        
        //トークンのリクエスト先URLの設定
        let urlString = "https://www.arcgis.com/sharing/oauth2/token"
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        
        //アプリ ID の設定
        let clientId:String = "<Applications_Client_Id>"
        //秘密鍵の設定
        let clientSecret:String = "<Applications_Client_Secret>"
        
        //トークンの有効期限の設定（1時間）
        let expiration:String = "60"
        
        let grantType:String = "client_credentials"
        let requestStr:String = "client_id=" + clientId + "&client_secret=" + clientSecret + "&expiration=" + expiration + "&grant_type=" + grantType + "&f=json"
        
        request.httpBody = requestStr.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            if (error == nil) {
                
                do {
                    
                    let res = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:Any]
                    
                    DispatchQueue.main.async {
                        
                        
                        if res["error"] != nil {
                            
                            let error = res["error"] as! [String: Any]
                            let errorDetails = error["error_description"] as! String
                            print(errorDetails)

                            let alert = UIAlertController(title:"Error", message: errorDetails, preferredStyle: UIAlertControllerStyle.alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(defaultAction)
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            
                            let token = res["access_token"] as! String
                            print(token)
                            
                            let credential = AGSCredential(token: token)
                            let featureLayer = AGSFeatureLayer(url: URL(string: "<Secure_Service_Layer_URL>"), mode: .onDemand, credential: credential)
                            
                            self.mapView.addMapLayer(featureLayer, withName:"Feature Service Layer")
                            
                        }
                        
                    }
                } catch {
                    
                    print("serialize_error")
                    return
                }
                
            } else {
                
                print("response_error")
            }
            
        })
        
        task.resume()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

