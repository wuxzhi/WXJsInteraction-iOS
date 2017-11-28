//
//  ViewController.m
//  WXJsInteraction-iOS
//
//  Created by wxzhi on 2017/11/24.
//  Copyright © 2017年 wxzhi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
/** 上下文(环境) */
@property (nonatomic, strong) JSContext *jsContext;
/** 矩形 */
@property (nonatomic, strong) UIView *colorView;
//面积的值
@property (strong, nonatomic) IBOutlet UILabel *areaValueLabel;
//周长的值
@property (strong, nonatomic) IBOutlet UILabel *perimeterValueLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-200)];
    _webView.backgroundColor = [UIColor clearColor];
    [_webView setOpaque:NO]; 

    _webView.delegate = self;
    [self.view addSubview:_webView];
    //加载html
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //获取上下文(环境)
    _jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //获取异常信息
    _jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        context.exception = exception;
        NSLog(@"%@", exception);
    };
    
    __weak typeof(self) weakSelf = self;
    //将self和js中'object'关联在一起,通过JSExport协议调用
    _jsContext[@"object"] = weakSelf;
    /*--------js调oc方法，js方直接调用，block等同于function*/
    //移除view
    _jsContext[@"removeView"] = ^(){
        JSContext *jsCtx = [JSContext currentContext];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.colorView removeFromSuperview];
            weakSelf.colorView = nil;
            //输入框的text改变（ps:属oc改变js属性-嵌入js并运行）
            [jsCtx evaluateScript:@"widthInput.value=0"];
            [jsCtx evaluateScript:@"heightInput.value=0"];
        });
    };
    //获取参数1，修改view颜色
    _jsContext[@"viewColorChange"] = ^(NSString *colorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.colorView.backgroundColor = [weakSelf colorWithHexColorString:colorStr alpha:1];
        });
    };
    /* 获取参数2 */
//    _jsContext[@"viewColorChange"] = ^(){
//        NSArray *args = [JSContext currentArguments];//参数
////        for (JSValue *objValue in args) {
////            id obj = objValue.toObject;
////            NSLog(@"js回调的参数：%@ class：%@",obj,[obj class]);
////        }
//        JSValue *colorVal = args[0];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.colorView.backgroundColor = [weakSelf colorWithHexColorString:colorVal.toString alpha:1];
//        });
//    };
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"加载webView出错");
}

#pragma mark --------js调用方法------------
/** 1.添加view */
- (void)addView {
    JSContext *jsCtx = [JSContext currentContext];
    //获取关联对象
    JSValue *objectValue = [JSContext currentThis];
    __weak ViewController *weakSelf = objectValue.toObject;
    
    //获取textarea
    JSValue *textValue = jsCtx[@"heightInput"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.colorView) {
            [weakSelf.colorView removeFromSuperview];
            weakSelf.colorView = nil;
        }
        weakSelf.colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 100, 100)];
        weakSelf.colorView.backgroundColor = [UIColor redColor];
        [weakSelf.view insertSubview:weakSelf.colorView atIndex:0];
        //输入框的text改变（ps:属oc改变js属性）
        [jsCtx evaluateScript:@"widthInput.value=100"];
        //输入框的text改变2（ps:属oc改变js属性）
        textValue[@"value"] = @100;
    });
}

/** 2.改变size ps:JSExport方法名替换*/
- (void)viewSizeChangeWithWidth:(float)width height:(float)height {
    JSValue *objectValue = [JSContext currentThis];
    __weak ViewController *weakSelf = objectValue.toObject;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect newFrame = weakSelf.colorView.frame;
        newFrame.size = CGSizeMake(width, height);
        weakSelf.colorView.frame = newFrame;
    });
}

#pragma mark ----oc调用js方法
//插入jsCode,在html关联js文件不用调用
//- (void)insertOCCallJSCode {
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"js"];
//    NSString *jsStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    [self.jsContext evaluateScript:jsStr];
//}

//计算周长
- (IBAction)perimeterCalculationAction:(UIButton *)sender {
    //获取关联对象
    JSValue *perimeterValue = [_jsContext evaluateScript:@"perimeterCalculation()"];
    _perimeterValueLabel.text = [NSString stringWithFormat:@"%@", perimeterValue.toNumber];
}

//计算面积
- (IBAction)areaCalculationAction:(UIButton *)sender {
    JSValue *areaValue = [_jsContext evaluateScript:[NSString stringWithFormat:@"areaCalculation(%f,%f);",_colorView.frame.size.width,_colorView.frame.size.height]];
//    JSValue *areaValue = [_jsContext[@"areaCalculation"] callWithArguments:@[@(_colorView.frame.size.width),@(_colorView.frame.size.height)]];
    _areaValueLabel.text = [NSString stringWithFormat:@"%@", areaValue.toNumber];
}

#pragma mark  --十六进制颜色
- (UIColor *)colorWithHexColorString:(NSString *)hexColorString alpha:(float)alpha{
    unsigned int red, green, blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColorString substringWithRange:range]]scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColorString substringWithRange:range]]scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColorString substringWithRange:range]]scanHexInt:&blue];
    
    UIColor *color = [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green/255.0f)blue:(float)(blue/255.0f)alpha:alpha];
    return color;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
