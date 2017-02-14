//
//  DWQFirstViewController.m
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved.
//

#import "DWQFirstViewController.h"
#import "DWQSecondViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface DWQFirstViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, retain) UILabel *showLabel;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic) UIButton *button;
@end
/**
*  此控制器显示了二维码扫描的基本流程
*  点击Next按钮，进入SecondViewController，对二维码扫描等功能进行了封装
*/

@implementation DWQFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}
-(void)createUI{
    self.view.backgroundColor=[UIColor whiteColor];
    self.title = @"二维码扫描示例-杜文全";
    
    // 显示二维码信息Label
    self.showLabel                 = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, self.view.bounds.size.width - 40, 80)];
    self.showLabel.backgroundColor = [UIColor darkGrayColor];
    self.showLabel.textColor       = [UIColor whiteColor];
    self.showLabel.text            = @"此处显示二维码扫描结果";
    self.showLabel.textAlignment   = NSTextAlignmentCenter;
    [self.view addSubview:self.showLabel];
    
    // 扫描按钮
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    _button.frame     = CGRectMake(20, CGRectGetHeight(self.view.frame)-60, self.view.bounds.size.width-40, 40);
    [_button setTitle:@"扫描" forState:UIControlStateNormal];
    [_button setTitle:@"停止扫描" forState:UIControlStateSelected];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [_button setTintColor:[UIColor clearColor]];
    [_button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(gotoSecondController:)];
    self.navigationItem.rightBarButtonItem = rightItem;


}
// 开始、停止
- (void)buttonClick:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self startScan];
    } else {
        [self stopScan];
    }
}

// 开始扫描
- (void)startReadingMachineReadableCodeObjects:(NSArray *)codeObjects inView:(UIView *)view {
    // 摄像头
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 输入口
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    
    // 会话session(连接输入口和输出口)
    self.session = [[AVCaptureSession alloc] init];
    [self.session addInput:input]; // 连接输入口
    
    // 输出口
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:output]; // 连接输出口
    
    // 设置输出口类型和代理, 我们通过其代理方法拿到输出的数据
    [output setMetadataObjectTypes:codeObjects];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()]; // 使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    
    // 设置展示层（预览层），显示扫描界面/区域
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.frame = view.bounds;
    [view.layer insertSublayer:self.preview atIndex:0];
    
    // 开扫，走你
    [self.session startRunning];
}

// 开始扫描
- (void)startScan {
    [self startReadingMachineReadableCodeObjects:@[AVMetadataObjectTypeQRCode] inView:self.view];
}

// 停止扫描，关闭session
- (void)stopScan {
    self.button.selected = NO;
    [self.session stopRunning];
    [self.preview removeFromSuperlayer];
}

// 识别到二维码 并解析转换为字符串
#pragma mark - <AVCaptureMetadataOutputObjectsDelegate>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self stopScan];
    
    AVMetadataObject *metadata = [metadataObjects objectAtIndex:0];
    NSString *codeStr = nil;
    if ([metadata respondsToSelector:@selector(stringValue)]) {
        codeStr = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
    }
    
    self.showLabel.text = codeStr;
}

#pragma mark - 进入第二个控制器，对二维码扫描进行封装操作
- (void)gotoSecondController:(id)sender {
    DWQSecondViewController *controller = [[DWQSecondViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
