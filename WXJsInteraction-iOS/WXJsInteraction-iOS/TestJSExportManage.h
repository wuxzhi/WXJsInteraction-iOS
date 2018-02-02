//
//  TestJSExportManage.h
//  WXJsInteraction-iOS
//
//  Created by wxzhi on 2018/2/2.
//  Copyright © 2018年 wxzhi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TestJSExportDelegate <JSExport>
- (void)viewSizeChangeWithWidth:(float)width height:(float)height;
- (void)addView;
@end

@protocol TestJSExport <JSExport>
JSExportAs(viewSizeChange, - (void)viewSizeChangeWithWidth:(float)width height:(float)height);
- (void)addView;
@end

@interface TestJSExportManage : NSObject<TestJSExport>
@property (nonatomic, weak) id<TestJSExportDelegate> delegate;
+ (TestJSExportManage *)sharedManager;
+ (id)allocWithZone:(NSZone *)zone;
@end
