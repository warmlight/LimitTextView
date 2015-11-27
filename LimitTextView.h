//
//  LimitTextView.h
//  LimitNumberOfWords
//
//  Created by yiban on 15/11/24.
//  Copyright © 2015年 yiban. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LimitTextViewDelegate <NSObject>
- (void)beyondLimitNum;
@end
@interface LimitTextView : UITextView<UITextViewDelegate>

@property (assign, nonatomic) NSInteger limitNum;      //限制输入的字数，不赋值就是不限制字数
@property (assign, nonatomic) BOOL autoHeight;         //根据输入文本自适应行高，默认不自适应
@property (strong, nonatomic) NSString *placeHold;     //placehold的文字，不设置就不显示
@property (strong, nonatomic) UIFont *placeHoldFont;   //placehold的字号，因为placehold自适应行高需要知道字号
@property (assign, nonatomic) id <LimitTextViewDelegate> limitdelegate;
@end
