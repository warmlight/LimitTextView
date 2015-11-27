# LimitTextView
------------------------
　　整片文章和代码都基本都是推翻重写，而且可能与网上主流的一些做法不同，我在后面说一下我这么做的一些考虑。当然我还是一个刚入门不久的女娃娃，肯定写的有不尽人意，如果有更好的方法可以跟我说一下。<br/>
　　我稍微整合了一下项目里关于这个功能的其他要求，其实也是一些常见的要求，我把他们封装成了一个控件`LimitTextView`，而且这些附带的功能也是能够自己决定是否开启的。<br/>
　　**ps:本文是以中文两个字节，英文一个字节来处理字数限制的。emoji的长度根据emoji不同字节也不同**<br/>

　　可以看看封装好的`LimitTextView`里都有哪些可以进行操作的属性<br/>
		 
		 //限制输入的字数（以中文为单位），不赋值就是不限制字数
		@property (assign, nonatomic) NSInteger limteNum; 
		
	　 　//根据输入文本自适应行高，默认不自适应    
		@property (assign, nonatomic) BOOL autoHeight; 
		
		//placehold的文字，不设置就不显示       
		@property (strong, nonatomic) NSString *placeHold;
		
		//placehold的font，如果用到placehold才设置
		//因为placehold自适应行高需要知道字号 
		@property (strong, nonatomic) UIFont *placeHoldFont;
		
从属性名就能看出`LimitTextView`具备了哪些功能：<br/>

* textView可以设置限制输入的字数。<br/>
* textView能选择是否够模仿显示出placeHolder（如果你给placeHold赋值即是显示），并且placeHolder会自适应行高。<br/>
* 如果输入的内容**超出textView init的时候的frame**，会自动增高。（不是从一开始输入多少就自适应多少，而是一旦超过初始化时的高度，就会开始自适应高度！！！）

###关键代码
		
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
    if ([textView.text charNumber] <= self.limitNum * 2 && ![self.limitString isEqualToString:@""])	{
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
	

　　这就是所有的关键代码，你肯定很好奇为什么没有`- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text`这个函数<br/>
　　天朝语言自带神奇的力量，在中文联想输入的时候是不会触发` shouldChangeTextInRange:`这个函数的。<br/>
　　是不是想问我神马是联想输入呐？（我是不是很了解不知道的童鞋╮(╯▽╰)╭，因为一开始我也get不到啊(┬＿┬))！！简单来说，就是粗线了下面这个图片圈起来的这个地方，而且你选择了这个地方的文字，此时的输入就代表着联想输入。<br>
![联想输入图片](http://ac-3xs828an.clouddn.com/2e447b66f68ee6f6.png)<br/>

###说明
* 如果一开始我就用中文联想输入，`shouldChangeTextInRange:`无法调用，所以我把处理`placeHold`显示/隐藏的逻辑写到`textViewDidChange`里，避免出现用联想输入而删除`placeHold`的逻辑没执行引起的覆盖情况。
* 关于循环计算字数的代码我没有写到`shouldChangeTextInRange:`里是因为，`textView`里面获取的`textView.text`是已经输入的字 + 高亮的字（不包括当前正在输入的那个高亮拼音/英文）。而我希望的结果是只计算已经确认输入的字的字数。并且，如果我限制输入字数为5个字，我已经输入“I喜欢吃辣”，当你要输入最后一个辣椒的“椒”的时候，刚好输入了拼音“j”，然后此时计算字数，前面中英文一共9个字节加上高亮的“j”，会发现已经到达10个字节的限制，接着如果`return NO;`你之后的拼音就再也没法输入了，感觉这种处理不是很人性化。
* 没有直接用`substringToIndex`而用循环是因为它的截取是不分中英文来截取的，中文英文都当做一个单位来截取。所以只能通过循环每一个字来判断是中文还是英文，进行计算拼接。
* 假设我现在字数限制为5个字，已经输入了“我爱吃辣椒”，但是用户不知道已经到了字数上限决定继续输入，就会走到循环里，然后可能进行多次继续输入的尝试，这时就会多次走入循环。为了避免这种情况，引入了变量`self.limitString`,来进行判断是否属于上述情况。`self.limitString`用来保存一个**连续**超出的输入操作时符合限制字数的string（不知道怎么解释了，看程序就能明白的！）。如果我在超出后（`self.limitString`不等于@“”）进行删除操作，删除字符到符合要求的范围内就会将`self.limitString`赋值为@“”，这样下一次输入超过限制字数后会走入循环。用户可能在删除字符后输入不同的内容，所以要重新走一次循环，进行一次字符串拼接。

**感觉说明的有点绕，我觉得看程序会配合起来会比较好理解，语死早请原谅我啊T^T，我很尽力在解释了！**

###关于效率
　　肯定是在`shouldChangeTextInRange:`进行return来限制操作效率高。我这样做效率感觉还是比较低的？感觉循环这种事如果字数上来了，效率肯定会不高。但是我没找到一个比较简单点的符合我要求的方法。如果有大家可以告诉我一下，不胜感激呢！

###关于使用

	
	#import "ViewController.h"
	#import "LimitTextView.h"
	@interface ViewController ()<LimitTextViewDelegate>

	@end

	@implementation ViewController

	- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    LimitTextView *tx = [[LimitTextView alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 80)];
    tx.backgroundColor = [UIColor lightGrayColor];
    tx.limteNum = 5;
    tx.autoHeight = YES;
    tx.placeHoldFont = [UIFont systemFontOfSize:13];
    tx.placeHold = @"我是placeholder,我的行高可以改变！！！！";
    tx.limitdelegate = self;
    [self.view addSubview:tx];
	}

	//如果超出了限制字数会走这个delegate，可以把提示的逻辑写到这个里面
	- (void)beyondLimitNum {
	    NSLog(@"超过了限制字数( ⊙ o ⊙ )啊！");
	}


推荐看，博主讲的很好，不过博主好像是中英文都当一个字符来处理，没有分开处理，但是文章很不错：<br/>
[详释(常见UITextView 输入之字数限制)之一－－－固定长度](http://blog.csdn.net/fengsh998/article/details/45421107)
　
