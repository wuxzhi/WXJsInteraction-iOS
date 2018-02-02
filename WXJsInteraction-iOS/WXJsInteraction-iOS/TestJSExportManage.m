//
//  TestJSExportManage.m
//  WXJsInteraction-iOS
//
//  Created by wxzhi on 2018/2/2.
//  Copyright © 2018年 wxzhi. All rights reserved.
//

#import "TestJSExportManage.h"

@implementation TestJSExportManage

static TestJSExportManage *testJSExportManage = nil;

+ (TestJSExportManage *)sharedManager
{
    @synchronized(self)
    {
        if (testJSExportManage == nil)
        {
            testJSExportManage = [[self alloc] init];
        }
    }
    
    return testJSExportManage;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (testJSExportManage == nil)
        {
            testJSExportManage = [super allocWithZone:zone];
            return testJSExportManage;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)addView {
    [_delegate addView];
}

- (void)viewSizeChangeWithWidth:(float)width height:(float)height {
    [_delegate viewSizeChangeWithWidth:width height:height];
}


@end
