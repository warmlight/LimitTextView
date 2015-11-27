//
//  NSString+UnicodeLengthOfString.m
//  LimitNumberOfWords
//
//  Created by yiban on 15/11/24.
//  Copyright © 2015年 yiban. All rights reserved.
//

#import "NSString+UnicodeLengthOfString.h"

@implementation NSString (UnicodeLengthOfString)
//分割计算文字长度
- (NSUInteger)unicodeLengthOfString{
    NSUInteger asciiLength = 0;
    
    for (NSUInteger i = 0; i < self.length; i++){
        
        unichar uc = [self characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;
    }
    
    NSUInteger unicodeLength = asciiLength / 2;
    if(asciiLength % 2) {
        unicodeLength++;
    }
    
    return unicodeLength;
}


//-  (int)charNumber{
//    int strlength = 0;
//    char* p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];
//    for (int i=0 ; i<[self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
//        if (*p) {
//            p++;
//            strlength++;
//        }
//        else {
//            p++;
//        }
//    }
//    return strlength;
//}

-  (int)charNumber{
    
    int strlength = 0;
    char* p = (char*)[self cStringUsingEncoding:NSUTF8StringEncoding];
    for (int i=0 ; i<[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding] ;i++) {
        if (*p) {
            if(*p == '\xe4' || *p == '\xe5' || *p == '\xe6' || *p == '\xe7' || *p == '\xe8' || *p == '\xe9')
            {
                strlength--;
            }
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}
@end
