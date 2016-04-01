//
//  KeyViewController.m
//  KeyBoardTest
//
//  Created by guo on 14-6-5.
//  Copyright (c) 2014年 guo. All rights reserved.
//

#import "KeyViewController.h"
#import "DrugView.h"
#import "Drug.h"
#import "Administration.h"
#import "ClicnView.h"
#import "AdminisView.h"
#import "PackageView.h"
#import "PackageOrder.h"
#import "ServiceFactory.h"
#import "OrderService.h"
#import "User.h"
#import "GlobalVarService.h"
//#import "DrugListService.h"
//#import "AdministService.h"
//#import "PackageOrderService.h"
//#import "ClicnProService.h"
//#import "OrderService.h"

@interface KeyViewController ()

@property (nonatomic, assign, getter=isShifted) BOOL shifted;

@end

@implementation KeyViewController

#define kFont [UIFont fontWithName:@"GurmukhiMN" size:25]
#define kAltLabel @".?123"
#define KAltLabel2 @"ABC"
#define kReturnLabel @"return"
#define kChar @[ @"Q", @"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P", @"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L", @"Z", @"X", @"C", @"V", @"B", @"N", @"M", @",", @".", @" " ]

#define kChar_shift @[ @"Q", @"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P", @"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L", @"Z", @"X", @"C", @"V", @"B", @"N", @"M", @"!", @"?", @" " ]

#define kChar_alt @[ @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0", @"-", @"/", @":", @";", @"(", @")", @"$", @"&", @"@", @".", @",", @"?", @"!", @"\'", @"\"",@"[" ,@"]",@"%",@" " ]

@synthesize drugView;
@synthesize tableArray;
@synthesize titleArray;
@synthesize gDrug;
@synthesize viewType;
@synthesize clicnView;
@synthesize adminisView;
@synthesize packageView;
@synthesize adminis;
@synthesize packageOrder;
@synthesize clicnProject;
@synthesize orderService;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //获取所有药品名称列表
//        tableArray = [self getData];
    }
    return self;
}

-(id)init:(NSArray *)aTitleArray view:(NSString *)aViewType;{
    titleArray = aTitleArray;
    viewType = aViewType;
    orderService = [ServiceFactory getOrderService];
    return [self initWithNibName:nil bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([viewType isEqualToString:@"药品"]) {
        drugView = [[DrugView alloc]initWithFrame:CGRectMake(0, 0, 768, 380)];
        drugView.titleArray = titleArray;
        drugView.drugArray = tableArray;
        [self.view addSubview:drugView];
    }else if([viewType isEqualToString:@"非药品"]){
        clicnView = [[ClicnView alloc]initWithFrame:CGRectMake(0, 0, 768, 380)];
        clicnView.titleArray = titleArray;
        clicnView.clicnArray = tableArray;
        [self.view addSubview:clicnView];
    }else if([viewType isEqualToString:@"途径"]){
        adminisView = [[AdminisView alloc]initWithFrame:CGRectMake(0, 0, 768, 380)];
        adminisView.titleArray = titleArray;
        adminisView.adminisArray = tableArray;
        [self.view addSubview:adminisView];
    }else if([viewType isEqualToString:@"套餐医嘱"]){
        packageView = [[PackageView alloc]initWithFrame:CGRectMake(0, 0, 768, 380)];
        packageView.titleArray = titleArray;
        packageView.packageArray = tableArray;
        [self.view addSubview:packageView];
    }

    [self registerAsObserver];
    
    NSMutableArray *buttons = [NSMutableArray arrayWithArray:self.characterKeys];
    [buttons addObjectsFromArray:self.altButtons];
	[buttons addObject:self.deleteButton];
	
	for (UIButton *b in buttons) {
//		[b setBackgroundImage:[PKCustomKeyboard imageFromColor:[UIColor colorWithWhite:0.5 alpha:0.5]] forState:UIControlStateHighlighted];
		b.layer.cornerRadius = 7.0;
		b.layer.masksToBounds = YES;
		b.layer.borderWidth = 0;
	}
	
	for (UIButton *b in self.altButtons)
		[b setTitle:kAltLabel forState:UIControlStateNormal];
	
	[self.returnButton setTitle:kReturnLabel forState:UIControlStateNormal];
	self.returnButton.titleLabel.adjustsFontSizeToFitWidth = YES;
	
	[self loadCharactersWithArray:kChar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击字母键触发的消息
- (IBAction)characterPressed:(id)sender {
    [[UIDevice currentDevice] playInputClick];
	UIButton *button = (UIButton *)sender;
	NSString *character = [NSString stringWithString:button.titleLabel.text];
    self.textOutPut.text = [self.textOutPut.text stringByAppendingString:character];
    if ([viewType isEqualToString:@"药品"]) {
        drugView.iKvo = self.textOutPut.text;
    }else if ([viewType isEqualToString:@"非药品"]){
        clicnView.iKvo = self.textOutPut.text;
    }else if([viewType isEqualToString:@"途径"]){
        adminisView.iKvo = self.textOutPut.text;
    }else if([viewType isEqualToString:@"套餐医嘱"]){
        packageView.iKvo = self.textOutPut.text;
    }
}
//用来标识监听
static void *OpeningBalance = (void*)&OpeningBalance;
//注册监听输入框的变化
-(void)registerAsObserver{
    if ([viewType isEqualToString:@"药品"]) {
        [drugView addObserver:self forKeyPath:@"iKvo" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:OpeningBalance];
    }else if([viewType isEqualToString:@"非药品"]){
        [clicnView addObserver:self forKeyPath:@"iKvo" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:OpeningBalance];
    }else if([viewType isEqualToString:@"途径"]){
        [adminisView addObserver:self forKeyPath:@"iKvo" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:OpeningBalance];
    }else if([viewType isEqualToString:@"套餐医嘱"]){
//        [packageView addObserver:self forKeyPath:@"iKvo" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:OpeningBalance];
    }
}

//删除监听
-(void)unregisterObserver{
    if ([viewType isEqualToString:@"药品"]) {
         [drugView removeObserver:self forKeyPath:@"iKvo" ];
    }else if([viewType isEqualToString:@"途径"]){
         [adminisView removeObserver:self forKeyPath:@"iKvo" ];
    }else if ([viewType isEqualToString:@"非药品"]){
        [clicnView removeObserver:self forKeyPath:@"iKvo" ];
    }else if([viewType isEqualToString:@"套餐医嘱"]){
//         [packageView removeObserver:self forKeyPath:@"iKvo" ];
    }
   
}

//监听的回调函数，只要监听的值变化就会调用
//keypath标识之前监听的key就是，object标识被对象，change是一个字典里面包含了新旧值，context是私有变量
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change context:(void *)context{
    if (context == OpeningBalance) {
        NSString *currStr = [change objectForKey:NSKeyValueChangeNewKey];
        [self siftedList:currStr];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//点击delete键时触发的消息
- (IBAction)deletePressed:(id)sender {
    if (_textOutPut.text.length == 0) {
        return;
    }
    [[UIDevice currentDevice] playInputClick];
    NSMutableString *tmpStr = [NSMutableString stringWithString:_textOutPut.text];
    NSInteger len = _textOutPut.text.length;
    NSRange range = NSMakeRange(len-1, 1);
    [tmpStr deleteCharactersInRange:range];
    _textOutPut.text = tmpStr;
    
    if ([viewType isEqualToString:@"药品"]) {
        drugView.iKvo = tmpStr;
    }else if ([viewType isEqualToString:@"非药品"]){
        clicnView.iKvo = tmpStr;
    }else if([viewType isEqualToString:@"途径"]){
        adminisView.iKvo = tmpStr;
    }else if([viewType isEqualToString:@"套餐医嘱"]){
        //packageView.iKvo = tmpStr;
    }
}

//点击消失界面按钮
- (IBAction)dismissPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^(){
        [self unregisterObserver];
        if ([viewType isEqualToString:@"药品"]) {
            //获取用户的用药限制级别
            BOOL bLimit = [orderService getDrugLimit:drugView.gDrug.drugCode];
            NSLog(@"用药限制->%d",bLimit);
            if (!bLimit) {
                UIAlertView *tmpAlter = [[UIAlertView alloc]initWithTitle:@"提示！" message:@"没有开药权限！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [tmpAlter show];
                return ;
            }
            self.gDrug = drugView.gDrug;
            NSLog(@"%@",[drugView.drugTableView indexPathForSelectedRow]);
           if (gDrug != nil && [drugView.drugTableView indexPathForSelectedRow] != nil) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"editTheOrderTextNotification" object:gDrug];
            }
        }else if ([viewType isEqualToString:@"非药品"]){
            self.clicnProject = clicnView.clicnProj;
            NSLog(@"%@",[drugView.drugTableView indexPathForSelectedRow]);
            if (clicnProject != nil && [clicnView.clicnTableView indexPathForSelectedRow] != nil) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"editTheClicnOrderTextNotification" object:clicnProject];
            }
        }else if ([viewType isEqualToString:@"途径"]){
            self.adminis = adminisView.adminis;
            if (adminis != nil && [adminisView.adminisTableView indexPathForSelectedRow] != nil) {
                //adminisBack(adminis.administrationName);
                [[NSNotificationCenter defaultCenter]postNotificationName:@"editAdministNotification" object:adminis];
            }
        }else if ([viewType isEqualToString:@"套餐医嘱"] && [packageView.packageTableView indexPathForSelectedRow] != nil){
//            self.packageOrder = packageView.packageOrder;
//            if (packageOrder != nil && [packageView.packageTableView indexPathForSelectedRow] != nil){
//                [[NSNotificationCenter defaultCenter]postNotificationName:@"editPackageOrderNotification" object:packageOrder];
//            }
        }
    }];

}

//点击取消按钮时触发的事件
- (IBAction)cancelBtnClicked:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^(){
        [self unregisterObserver];
        NSLog(@"自定义键盘消失");
    }];
}

//给键盘加载标题
-(void)loadCharactersWithArray:(NSArray *)characArray {
	int i = 0;
	for (UIButton *b in self.characterKeys) {
		[b setTitle:[characArray objectAtIndex:i] forState:UIControlStateNormal];
		if ([b.titleLabel.text characterAtIndex:0] < 128){
           [b.titleLabel setFont:[UIFont systemFontOfSize:28]];
        }else{
            [b.titleLabel setFont:kFont];
        }
		i++;
	}
}

//点击alt时触发的消息
- (IBAction)altPressed:(id)sender {
    [[UIDevice currentDevice] playInputClick];
	[self.keyboardBackground setImage:[UIImage imageNamed:@"Keyboard_Blank700.png"]];
	self.shifted = NO;
	UIButton *button = (UIButton *)sender;
	
	if ([button.titleLabel.text isEqualToString:kAltLabel]) {
		[self loadCharactersWithArray:kChar_alt];
		for (UIButton *b in self.altButtons)
			[b setTitle:KAltLabel2 forState:UIControlStateNormal];
	}
	else {
		[self loadCharactersWithArray:kChar];
		for (UIButton *b in self.altButtons)
			[b setTitle:kAltLabel forState:UIControlStateNormal];
	}
}


//筛选项目/药品名称列表
-(void)siftedList:(NSString *)str{
    if ([viewType isEqualToString:@"药品"]) {
        if (str == nil || [str isEqualToString:@""]) {
            drugView.drugArray = tableArray;
            [drugView.drugTableView reloadData];
            return ;
        }
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"inputCode BEGINSWITH[cd] %@",str];
        drugView.drugArray = [tableArray filteredArrayUsingPredicate:pred];
        [drugView.drugTableView reloadData];
    }else if ([viewType isEqualToString:@"非药品"]){
        if (str == nil || [str isEqualToString:@""]) {
            clicnView.clicnArray = tableArray;
            [clicnView.clicnTableView reloadData];
            return ;
        }
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"inputCode BEGINSWITH[cd] %@",str];
        clicnView.clicnArray = [tableArray filteredArrayUsingPredicate:pred];
        [clicnView.clicnTableView  reloadData];
    }else if([viewType isEqualToString:@"途径"]){
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"inputCode BEGINSWITH[cd] %@",str];
         adminisView.adminisArray = [tableArray filteredArrayUsingPredicate:pred];
          [adminisView.adminisTableView reloadData];
    }else if([viewType isEqualToString:@"套餐医嘱"]){
//        NSPredicate *pred = [NSPredicate predicateWithFormat:@"packageCode BEGINSWITH[cd] %@",str];
//         packageView.packageArray = [NSMutableArray arrayWithArray:[tableArray filteredArrayUsingPredicate:pred]];
//          [packageView.packageTableView reloadData];
    }
   
  
}

//获取药品名称列表
-(NSArray *)getData{
    NSArray *muArray = nil;
    if ([viewType isEqualToString:@"药品"]) {
        muArray = [orderService getDrugList];
        return muArray;
    }else if ([viewType isEqualToString:@"非药品"]){
        muArray = [orderService getClicnList];
        return muArray;
    }else if ([viewType isEqualToString:@"途径"]){
        muArray = [orderService getAdministList];
        return muArray;
        
    }else {//套餐医嘱
//        User *curUser = [[ServiceFactory getGlobalVarService]getCurrentUser];
        muArray = [[ServiceFactory getOrderService] getPackageOrders];
        return muArray;
    }
}

@end
