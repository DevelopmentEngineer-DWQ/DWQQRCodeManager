//
//  DWQSecondViewController.m
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved.
//

#import "DWQSecondViewController.h"
#import "DWQQRScanViewController.h"
#import "DWQQROptionView.h"
#import "DWQQRImageHelper.h"
@interface DWQSecondViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation DWQSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}
-(void)createUI{
    // 生成二维码
    
    self.title=@"iOS高级工程师杜文全";
    self.inputField.rightViewMode = UITextFieldViewModeAlways;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 50, 40);
    [button setTitle:@"生成" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor darkGrayColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(generateQRCode:) forControlEvents:UIControlEventTouchUpInside];
    self.inputField.rightView = button;

}
- (IBAction)scan:(id)sender {
    //初始化扫描控制器
    DWQQRScanViewController *controller = [[DWQQRScanViewController alloc] init];
    
    [controller setResultHandler:^(DWQQRScanViewController *controller, NSString *result) {
        self.resultLabel.text = result;
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
   
    [self presentViewController:controller animated:YES completion:nil];

}
- (void)generateQRCode:(id)sender {
    self.resultImageView.image = [DWQQRImageHelper generateImageWithStr:self.inputField.text size:self.resultImageView.frame.size.width];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
