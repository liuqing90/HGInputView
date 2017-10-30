//
//  ViewController.m
//  HGInputView
//
//  Created by 刘青 on 2017/10/29.
//  Copyright © 2017年 lq. All rights reserved.
//

#import "ViewController.h"
#import "HGInputView.h"

static const CGFloat kHGInputViewHeight = 48.0f;

@interface ViewController () <HGInputViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) HGInputView *inputView;

@end

@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.title = @"HGInputViewDemo";
    
    [self setupSubviews];
    [self addObserver];
}

- (void)dealloc
{
    [self removeObserver];
}

#pragma mark - Private Methods

- (void)setupSubviews
{
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kHGInputViewHeight)];
    self.textView.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightRegular];
    self.textView.editable = NO;
    [self.view addSubview:self.textView];
    
    self.inputView = [[HGInputView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kHGInputViewHeight, self.view.frame.size.width, kHGInputViewHeight)];
    self.inputView.delegate = self;
    [self.view addSubview:self.inputView];
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardEvent:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardEvent:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (void)handleKeyboardEvent:(NSNotification *)note
{
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat inputViewH = CGRectGetHeight(self.inputView.frame);
    CGFloat inputViewY = CGRectGetMinY(keyboardFrame) - inputViewH;
    CGFloat textViewH = inputViewY;
    self.inputView.frame = CGRectMake(0, inputViewY, self.view.frame.size.width, inputViewH);
    self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, textViewH);
}

#pragma mark - HGInputViewDelegate

- (void)inputView:(HGInputView *)inputView sendText:(NSString *)text
{
    self.textView.text = text;
    [inputView clear];
}

- (void)inputViewDidChangeHeight:(HGInputView *)inputView
{
    CGFloat inputViewY = CGRectGetMinY(inputView.frame);
    CGFloat textViewH = inputViewY;
    self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, textViewH);
}

@end
