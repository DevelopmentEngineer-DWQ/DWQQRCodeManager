# DWQQRCodeManager
一款超级强大的二维码的扫描封装




##使用方法

 *扫描方式1【详见demo中DWQFirstController调用方式】，部分代码如下
```objective-c
// 开始扫描
- (void)startScan {
    [self startReadingMachineReadableCodeObjects:@[AVMetadataObjectTypeQRCode] inView:self.view];
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
```
 *扫描方式2【详见demo中DWQSecondController调用方式】，部分代码如下
```objective-c
 //初始化扫描控制器
    DWQQRScanViewController *controller = [[DWQQRScanViewController alloc] init];
    
    [controller setResultHandler:^(DWQQRScanViewController *controller, NSString *result) {
    //扫描后需要设置的代码在这里写
        
    }];
```
<img src="https://github.com/DWQQRCodeManager/DWQQRManager/Resources/duwenquanLogo.png" alt=“DWQQRCode" width=200/>

##有问题反馈
在使用中有任何问题，欢迎反馈给我，可以用以下联系方式跟我交流

* 邮件(duwenquan0414@gmail.com)
* QQ: 439878592



