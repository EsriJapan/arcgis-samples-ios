//
//  TopMenuController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "TopMenuController.h"


@implementation TopMenuController

- (id)init
{
    if(self = [super initWithStyle:UITableViewStylePlain]){
        self.title = @"メニュー";
        self.items = [[NSMutableArray alloc] initWithObjects:
                      @"LayersViewController",
                      @"SwipeViewController",
                      @"PerspectiveViewController",
                      @"GpsViewController",
                      @"SensorViewController",
                      @"LegendViewController",
                      @"MagnifierViewController",
                      @"SketchViewController",
                      @"WmsViewController",
                      @"TimeViewController",
                      @"WebmapViewController",
                      @"CustomSymbolViewController",
                      @"RotationRendererViewController",
                      @"SearchViewController",
                      @"AttachmentManagerViewController",
                      @"LocatorViewController",
                      @"NetworkViewController",
                      @"ServiceAreaViewController",
                      @"CoordinateConversionViewController",
                      @"JsonViewController",
                      nil];
        
        self.itemNames = [[NSMutableArray alloc] initWithObjects:
                          @"レイヤの表示・非表示",
                          @"スワイプ",
                          @"パース表示",
                          @"ナビゲーション",
                          @"地図の回転",
                          @"凡例",
                          @"拡大鏡",
                          @"スケッチレイヤー",
                          @"WMSレイヤー",
                          @"時間対応レイヤー",
                          @"Webマップの表示",
                          @"シンボルの表示",
                          @"レンダラー",
                          @"属性検索",
                          @"写真の添付",
                          @"リバース ジオコーディング",
                          @"ルート検索",
                          @"到達圏解析",
                          @"座標の表示形式",
                          @"フィーチャをJSON形式で保存",
                          nil];
    }
    return self;
}


- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger) section {
    return [self.items count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"simple-cell"];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simple-cell"];
    }
    
    cell.textLabel.text = [self.itemNames objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    Class class = NSClassFromString([self.items objectAtIndex:indexPath.row]);
    id viewController = [[class alloc] init];
    if(viewController){
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
