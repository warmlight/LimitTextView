//
//  ViewController.m
//  LimitNumberOfWords
//
//  Created by yiban on 15/11/24.
//  Copyright © 2015年 yiban. All rights reserved.
//

#import "ViewController.h"
#import "LimitTextView.h"
@interface ViewController ()<LimitTextViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    LimitTextView *tx = [[LimitTextView alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 50)];
    tx.backgroundColor = [UIColor lightGrayColor];
    tx.limteNum = 5;
    tx.autoHeight = YES;
    tx.placeHoldFont = [UIFont systemFontOfSize:12];
    tx.placeHold = @"imagePickerController:(YiBanImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info";
    tx.limitdelegate = self;
    [self.view addSubview:tx];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)beyondLimitNum {
    NSLog(@"超过了限制字数( ⊙ o ⊙ )啊！");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
