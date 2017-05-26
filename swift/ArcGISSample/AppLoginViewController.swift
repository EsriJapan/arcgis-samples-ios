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
//アプリの登録と認証: https://esrijapan.github.io/arcgis-dev-resources/register-app/

class AppLoginViewController: UIViewController {
    
    var mapView: AGSMapView!
    var myCredential: AGSCredential!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // 道路地図レイヤー表示用のマップの作成
        mapView = AGSMapView(frame: view.bounds)
        view.addSubview(mapView)
        let map = AGSMap(basemapType: AGSBasemapType.streets, latitude: 35.681298, longitude: 139.766247, levelOfDetail: 5)
        mapView.map = map
        
        
        // トークンのリクエスト先 URL の設定
        let urlString = "https://www.arcgis.com/sharing/oauth2/token"
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        
        // アプリ ID の設定
        let clientId:String = "<Applications_Client_Id>"

        // 秘密鍵の設定
        let clientSecret:String = "<Applications_Client_Secret>"
        
        // トークンの有効期限の設定（1時間）
        let expiration:String = "60"
        
        let grantType:String = "client_credentials"
        let requestStr:String = "client_id=" + clientId + "&client_secret=" + clientSecret + "&expiration=" + expiration + "&grant_type=" + grantType + "&f=json"
        
        request.httpBody = requestStr.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            if (error == nil) {
                
                do {
                    
                    let res = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:Any]
                    
                    DispatchQueue.main.async {
                        
                        // トークンの取得に失敗
                        if res["error"] != nil {
                            
                            let error = res["error"] as! [String: Any]
                            let errorDetails = error["error_description"] as! String
                            print(errorDetails)

                            let alert = UIAlertController(title:"Error", message: errorDetails, preferredStyle: UIAlertControllerStyle.alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(defaultAction)
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            
                            // トークンの取得に成功
                            let token = res["access_token"] as! String
                            print(token)
                            
                            // トークンを指定して認証情報(AGSCredential)を作成
                            self.myCredential = AGSCredential(token: token, referer: nil)
                            
                            // 認証が必要な ArcGIS Online のサービスを使用するタスクに認証情報を設定
                            let routeTask = AGSRouteTask(url: URL(string: "https://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World")!)
                            routeTask.credential = self.myCredential
                            
                            // ルート検索（AGSRouteTask）を実行
                            
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

