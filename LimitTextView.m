//
//  LimitTextView.m
//  LimitNumberOfWords
//
//  Created by yiban on 15/11/24.
//  Copyright © 2015年 yiban. All rights reserved.
//

#import "LimitTextView.h"
#import "NSString+UnicodeLengthOfString.h"

@interface LimitTextView()
@property (strong, nonatomic) UILabel *placeHoldLabel;
@property (strong, nonatomic) NSString *limitString;   //用来存储当前输入的第一次超过时从中截取的符合字数限制的string

@end

@implementation LimitTextView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)setPlaceHold:(NSString *)placeHold {
    _placeHold = placeHold;
    if (self.placeHoldFont != nil) {
        [self createPlaceHoldLabel];
    }
}

- (void)setPlaceHoldFont:(UIFont *)placeHoldFont {
    _placeHoldFont = placeHoldFont;
    if (self.placeHold.length > 0) {
        [self createPlaceHoldLabel];
    }
}

- (void)createPlaceHoldLabel {
    CGFloat labelWidth = self.frame.size.width - 10;
    self.placeHoldLabel = [[UILabel alloc] init];
    //不限制行数 自动行高
    self.placeHoldLabel.numberOfLines = 0;
    self.placeHoldLabel.font = self.placeHoldFont;
    self.placeHoldLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.placeHoldLabel.text = self.placeHold;
    [self addSubview:self.placeHoldLabel];
    // label可设置的最大高度 MAXFLOAT
    CGSize size = CGSizeMake(labelWidth, MAXFLOAT);
    //获取当前文本的属性
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:self.placeHoldFont,NSFontAttributeName,nil];
    //获取文本需要的size，限制宽度
    CGSize  actualsize =[self.placeHold boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    self.placeHoldLabel.frame =CGRectMake(5,5, labelWidth, actualsize.height);
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.placeHold.length > 0) {
        //textview没有placeholder，模仿placeholder的状态来控制placeholderLabel的显示和消失
        //textview长度为0
        if (self.text.length==0){
            self.placeHoldLabel.hidden = NO;
        }
        else{
            self.placeHoldLabel.hidden=YES;
        }
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //如果在变化中是高亮部分在变，就不计算字符
    if (selectedRange && pos) {
        return;
    }
    
    //字数超过后通过退格键把字数删除到符合限制的范围内，会调用这个函数
    //将limitString赋值为@“”，方便下一次循环判断
    if ([textView.text charNumber] <= self.limitNum * 2 && ![self.limitString isEqualToString:@""]){
        self.limitString = @"";
    }
    
    //超过规定的字数时
    if ([textView.text charNumber] > self.limitNum * 2) {
        //判断是否是普通的字符或asc码，我就是拿来判断是不是纯英文
        BOOL asc = [textView.text canBeConvertedToEncoding:NSASCIIStringEncoding];
        if (asc){
            //是纯英文就好办，可以直接截取相应的字符数用来显示
            NSString *str = [textView.text substringToIndex:self.limitNum * 2];
            if ([self.limitdelegate respondsToSelector:@selector(beyondLimitNum)]) {
                [self.limitdelegate beyondLimitNum];
            }
            [textView setText:str];
        }else{
            //当前输入的第一次超过才会进行循环截取，如果继续输入直接赋值为截取的符合字数限制的字符串，避免再次循环
            if ([self.limitString isEqualToString:@""]) {
                //如果是中英文混合输入，那么就不能单纯用substringToIndex截取，因为它一视同仁
                //不管中英文都当做一个单位来截断
                __block NSString *str = [[NSString alloc] init];
                __block NSInteger num = 0;
                __weak LimitTextView * bSelf = self;
                //逐字遍历，不管是中文英文，中文就按照字，英文就是按字母
                [textView.text enumerateSubstringsInRange:NSMakeRange(0, [textView.text length])
                                                  options:NSStringEnumerationByComposedCharacterSequences
                                               usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                                   NSInteger subLen = [substring charNumber];
                                                   num += subLen;
                                                   NSLog(@"%d", num);
                                                   if (num <= self.limitNum * 2) {
                                                       str  = [str stringByAppendingString:substring];
                                                   }else{
                                                       if ([bSelf.limitdelegate respondsToSelector:@selector(beyondLimitNum)]) {
                                                           [bSelf.limitdelegate beyondLimitNum];
                                                       }
                                                       self.limitString = str;
                                                       return;
                                                   }
                                               }];

            }
            [textView setText:self.limitString];
        }
    }
    
    //滚动到一个特定区域
    [self textViewIndicateMoveToCurrentPosition];
    //随着输入越多字数，textview不断变高
    if (self.autoHeight) {
        if (self.contentSize.height > self.frame.size.height){
            CGRect frame = self.frame;
            frame.size.height = self.contentSize.height;
            self.frame = frame;
        }
    }
}


//滚动到一个特定区域（这里是保证固定高度时输入能一直可见，在最后一行）
- (void)textViewIndicateMoveToCurrentPosition {
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    if (osVersionSupported) {
        [self layoutIfNeeded];
        CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.end];
        caretRect.size.height += self.textContainerInset.bottom;
        [self scrollRectToVisible:caretRect animated:NO];
    }
}

@end
