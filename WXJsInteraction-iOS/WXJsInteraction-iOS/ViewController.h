//
//  ViewController.h
//  WXJsInteraction-iOS
//
//  Created by wxzhi on 2017/11/24.
//  Copyright © 2017年 wxzhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol testJSExport <JSExport>
JSExportAs(viewSizeChange, - (void)viewSizeChangeWithWidth:(float)width height:(float)height);
- (void)addView;
@end

@interface ViewController : UIViewController<testJSExport>


@end

