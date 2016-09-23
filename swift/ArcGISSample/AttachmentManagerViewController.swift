//
//  AttachmentManagerViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS

class AttachmentManagerViewController: UIViewController, AGSAttachmentManagerDelegate, AGSFeatureLayerEditingDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    var agsMapView: AGSMapView!
    var agsFeatureLayer: AGSFeatureLayer!
    var agsAttachmentMgr: AGSAttachmentManager!
    var image: UIImage!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")

        //写真を添付する編集用フィーチャレイヤーの追加
        let featureLayerUrl = URL(string: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/CommercialDamageAssessment/FeatureServer/0")
        agsFeatureLayer = AGSFeatureLayer(url: featureLayerUrl, mode: .onDemand)
        agsMapView.addMapLayer(agsFeatureLayer, withName:"Feature Layer")
        
        
        let buttonAttachment = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(AttachmentManagerViewController.addAttachment))
        let buttons = ([buttonAttachment])
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height - 44, width: view.frame.size.width, height: 44))
        toolbar.setItems(buttons as [UIBarButtonItem], animated: true)
        view .addSubview(toolbar)
        
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
    
    
    func addAttachment (_ sender: UIBarButtonItem) {
        
        //添付する写真をフォトライブリから選択
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
        
    }

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
   
        //ジオメトリと属性を指定してフィーチャを新規に作成する
        let agsPoint = agsMapView.visibleAreaEnvelope.center
        let agsFeature = AGSGraphic()
        agsFeature.geometry = agsPoint
        agsFeature.setAttribute("Minor", forKey: "typdamage")
        
        //フィーチャをフィーチャレイヤーに更新
        agsFeatureLayer.applyEditsWithFeatures(toAdd: [agsFeature], toUpdate: nil, toDelete: nil)

        agsFeatureLayer.editingDelegate = self
        
    }
    
    
    func featureLayer(_ featureLayer: AGSFeatureLayer!, operation op: Operation!, didFailFeatureEditsWithError error: Error!) {
        
        // 編集に失敗
        print("Error:\(error.localizedDescription)")

    }
    
    
    func featureLayer(_ featureLayer: AGSFeatureLayer!, operation op: Operation!, didFeatureEditsWith editResults: AGSFeatureLayerEditResults!) {
        
        
        let results = editResults.addResults[0] as! AGSEditResult
        
        if (results.error != nil) {
            
            // 編集に失敗
            print("Error:\(results.error.description)")
            
        } else {
            
            // 編集に成功
            //新規に作成したフィーチャに対してAGSAttachmentManagerを作成
            let agsFeature = agsFeatureLayer.lookupFeature(withObjectId: results.objectId)
            agsAttachmentMgr = agsFeatureLayer.attachmentManager(forFeature: agsFeature)
            agsAttachmentMgr.delegate = self
            
            //フォトライブリから選択した写真に名前を指定してフィーチャに添付
            agsAttachmentMgr.addAttachmentAsJpg(with: image, name: "temp.jpg")
            
            if(agsAttachmentMgr .hasLocalEdits()){
                agsAttachmentMgr.postLocalEditsToServer()
            }
            
        }
        
        
    }
    
    
    private func attachmentManager(_ attachmentManager: AGSAttachmentManager!, didPostLocalEditsToServer attachmentsPosted: [AnyObject]!) {
        
        var success = true
        
        for attachment in attachmentsPosted as! [AGSAttachment] {
            
            //写真の添付に失敗
            if attachment.networkError != nil || attachment.editResultError != nil {
            
                success = false
                
                if attachment.networkError != nil {
                    let reason = attachment.networkError.localizedDescription
                    print("Error:\(reason)")

                } else if attachment.editResultError != nil {
                    let reason = attachment.editResultError.errorDescription
                    print("Error:\(reason)")
                }

            }
            
            //写真の添付に成功
            if (success){
                print("didPostLocalEditsToServer")
            }
        

        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
