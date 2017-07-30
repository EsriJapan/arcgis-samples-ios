//
//  ViewController.swift
//  chart-map
//
//  Created by esrij on H29/07/25.
//  Copyright © 平成29年 com.esrij. All rights reserved.
//

import UIKit
import ArcGIS
import Charts

class ViewController: UIViewController, AGSWebMapDelegate, AGSQueryTaskDelegate {
    

    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var chartView2: PieChartView!
    
    private var webMap: AGSWebMap!
    private var featureLayer: AGSFeatureLayer!
    private var queryTask: AGSQueryTask!
    private var query: AGSQuery!
    
    
    var typeCounts: [Int] = []
    var colors: [UIColor] = []
    var labels: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Web マップの ID を指定して、Web マップを作成
        // http://esrijapan.github.io/arcgis-dev-resources/create-webmap
        self.webMap = AGSWebMap(itemId: "fe0c760f0a404b37a8f7eb004c680c51", credential: nil)
        self.webMap.delegate = self
        
        // Web マップを開く
        self.webMap.open(into: self.mapView)
        
    }
    

    // MARK: - AGSWebMapDelegate
    func webMap(_ webMap: AGSWebMap!, didLoad layer: AGSLayer!) {
        
        // Web マップのレイヤーがロードされた際に、検索対象レイヤーをレイヤー名から判定し取得
        print(layer.name)
        if layer.name == "報告" {
            
            // Charts の API に渡すデータ種別のラベルとシンボル色を取得し、配列に格納
            self.featureLayer = layer as! AGSFeatureLayer
            let renderer = self.featureLayer.renderer as! AGSUniqueValueRenderer
            
            for i in 0 ..< renderer.uniqueValues.count  {
                let uniqueValue = renderer.uniqueValues[i] as! AGSUniqueValue
                colors.append(uniqueValue.symbol.color)
                labels.append(uniqueValue.label)
            }

            // 検索するレイヤーの URL を指定してフィーチャ検索用タスク（AGSQueryTask）を作成
            self.queryTask = AGSQueryTask(url: self.featureLayer.url)
            self.queryTask.delegate = self
            
            //フィーチャ検索用のパラメータを設定
            self.query = AGSQuery()
            self.query.geometry = self.mapView.visibleArea() // 地図の現在の表示範囲を空間条件に設定
            self.query.spatialRelationship = .contains // 現在の表示範囲に「含まれる」データを検索
            self.query.outFields = ["type"]
            self.query.returnGeometry = false
            // 検索結果フィーチャの種別（「type」フィールドの値）ごとの項目数を返す
            self.query.groupByFieldsForStatistics = ["type"]
            let count = AGSOutStatistic()
            count.onStatisticField = "type";
            count.statisticType = .count
            count.outStatisticFieldName = "CountOfTypes"  // 各種別の個数を格納する任意のフィールド名
            self.query.outStatistics = [count]
            
            // パラメータをもとに空間検索を実行（アプリ起動時）
            self.queryTask.execute(with: self.query)
            
            
            // マップのズームとパンニングの監視用の Notification を作成
            NotificationCenter.default.addObserver(self, selector: #selector(self.excuteQuery(notification:)), name: NSNotification.Name.AGSMapViewDidEndPanning, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.excuteQuery(notification:)), name: NSNotification.Name.AGSMapViewDidEndZooming, object: nil)
            
        }
        
    }
    
    
    func excuteQuery(notification: NSNotification?) {
        
        // マップのズームとパンニング時に、現在のマップの表示範囲をもとに空間検索を実行
        self.query.geometry = self.mapView.visibleArea()
        self.queryTask.execute(with: self.query)
        
    }
    
    
    // MARK: - AGSQueryTaskDelegate
    func queryTask(_ queryTask: AGSQueryTask!, operation op: Operation!, didFailWithError error: Error!) {
        print("空間検索のエラー:\(error.localizedDescription)")
    }
    
    
    func queryTask(_ queryTask: AGSQueryTask!, operation op: Operation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {
        
        // 空間検索の検索結果の処理
        // 各種別の個数を格納する配列をリセット
        self.typeCounts = []
        for _ in 0 ..< self.labels.count {
            self.typeCounts.append(0)
        }
        
        
        // 種別ごとの個数を配列に格納
        for i in 0 ..< featureSet.features.count {
            let graphic = featureSet.features[i] as! AGSGraphic
            if let typeNumber = graphic.attribute(forKey: "type") as? Int
            {
                let typeCount = graphic.attribute(forKey: "CountOfTypes") as! Int
                self.typeCounts[typeNumber] = Int(typeCount)
                print("種別:\(self.labels[typeNumber]), 個数:\(typeCount)")
            }
        }
        
        // チャートの作成
        self.createChart()

    }
    
    
    func createChart() {
        
        // バーチャートの作成
        self.chartView.backgroundColor = UIColor.white.withAlphaComponent(0.5) // 背景を半透過
        self.chartView.chartDescription?.text = "" // 説明ラベルを非表示にする

        self.chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:self.labels) // X軸のラベルを設定
        self.chartView.xAxis.labelPosition = .bottomInside // ラベルの表示位置を設定
        self.chartView.xAxis.labelRotationAngle = 30.0 // ラベル表示の回転角度を設定

        // データの数値（Y軸の値）を設定
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<self.typeCounts.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(self.typeCounts[i]))
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "報告件数")
        
        // 各バーの色を設定
        chartDataSet.colors = self.colors
        // バーチャートをビューに設定・表示
        self.chartView.data = BarChartData(dataSet: chartDataSet)
                
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



