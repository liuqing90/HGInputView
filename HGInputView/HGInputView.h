//
//  HGInputView.h
//  HGInputView
//
//  Created by 刘青 on 2017/10/29.
//  Copyright © 2017年 lq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HGInputView;

NS_ASSUME_NONNULL_BEGIN

@protocol HGInputViewDelegate <NSObject>

@optional

- (BOOL)inputViewShouldBeginEditing:(HGInputView *)inputView;
- (void)inputViewDidBeginEditing:(HGInputView *)inputView;
- (BOOL)inputViewShouldEndEditing:(HGInputView *)inputView;
- (void)inputViewDidEndEditing:(HGInputView *)inputView;
- (void)inputViewDidChangeHeight:(HGInputView *)inputView;
- (void)inputView:(HGInputView *)inputView sendText:(NSString * _Nullable)text;

@end

@interface HGInputView : UIView

@property (nonatomic, weak, nullable) id<HGInputViewDelegate> delegate;

@property (nonatomic, copy, readonly, nullable) NSString *text;

// default is system font 14.0 plain
@property (nonatomic, strong, null_resettable) UIFont *font;

// default is 3.0
@property (nonatomic, assign) CGFloat lineSpacing;

// default is 4
@property (nonatomic, assign) NSInteger numberOfLines;

// default is 1000
@property (nonatomic, assign) NSInteger maxCharacterCount;

// default is {6, 16, 6, 16}
@property (nonatomic, assign) UIEdgeInsets textContainerInset;

// default is "sending..."
@property (nonatomic, copy, null_resettable) NSString *placeholder;

- (BOOL)isActive;

- (BOOL)becomeActive;

- (BOOL)resignActive;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
