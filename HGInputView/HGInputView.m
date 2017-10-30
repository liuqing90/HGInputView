//
//  HGInputView.m
//  HGInputView
//
//  Created by 刘青 on 2017/10/29.
//  Copyright © 2017年 lq. All rights reserved.
//

#import "HGInputView.h"

#define HEXACOLOR(hexValue, alphaValue) [UIColor colorWithRed : ((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0 green : ((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0 blue : ((CGFloat)(hexValue & 0xFF)) / 255.0 alpha : (alphaValue)]

#define HEXCOLOR(hexValue) HEXACOLOR(hexValue, 1.0)

@interface HGInputView () <UITextViewDelegate>

@property (nonatomic, strong) UIView *sepLine;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, assign) CGFloat textViewMinContentHeight;
@property (nonatomic, assign) CGFloat textViewMaxContentHeight;
@property (nonatomic, assign) BOOL showPromptFlag;

@end

@implementation HGInputView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = HEXCOLOR(0xF8F8F8);
        self.layer.shadowColor = HEXACOLOR(0x000000, 0.08f).CGColor;
        self.layer.shadowOpacity = 1.0f;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 16.0f;
        
        [self setupDefaultConfigs];
        [self setupSubviews];
        [self setupLayout];
    }
    
    return self;
}

- (void)dealloc
{
    self.textView.delegate = nil;
}

#pragma mark - Private Methods

- (void)setupDefaultConfigs
{
    _font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightRegular];
    _lineSpacing = 3.0f;
    _numberOfLines = 4;
    _maxCharacterCount = 1000;
    _textContainerInset = UIEdgeInsetsMake(6, 16, 6, 16);
    _placeholder = @"sending...";
}

- (void)setupSubviews
{
    // separator line
    _sepLine = [[UIView alloc] initWithFrame:CGRectZero];
    _sepLine.backgroundColor = HEXCOLOR(0xE0E0E0);
    [self addSubview:_sepLine];
    
    // text view
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.backgroundColor = HEXCOLOR(0xFFFFFF);
    _textView.layer.cornerRadius = 16.0f;
    _textView.layer.borderColor = HEXCOLOR(0xF0F0F0).CGColor;
    _textView.layer.borderWidth = 1.0f;
    _textView.layer.masksToBounds = YES;
    _textView.textColor = HEXCOLOR(0x404040);
    _textView.font = _font;
    _textView.returnKeyType = UIReturnKeySend;
    _textView.textContainer.lineFragmentPadding = 0.0f;
    _textView.textContainerInset = UIEdgeInsetsMake(0, _textContainerInset.left, 0, _textContainerInset.right);
    _textView.contentInset = UIEdgeInsetsMake(_textContainerInset.top + _lineSpacing / 2, 0, _textContainerInset.bottom + _lineSpacing / 2, 0);
    _textView.scrollIndicatorInsets = UIEdgeInsetsMake(2, 0, 2, 4);
    _textView.layoutManager.allowsNonContiguousLayout = NO;
    _textView.delegate = self;
    _textView.scrollsToTop = NO;
    [self addSubview:_textView];
    
    // placeholder label
    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _placeholderLabel.textColor = HEXCOLOR(0xB0B0B0);
    _placeholderLabel.font = _font;
    _placeholderLabel.text = _placeholder;
    [self addSubview:_placeholderLabel];
    
    // send button
    _sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"send_enable"] forState:UIControlStateNormal];
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"send_disable"] forState:UIControlStateDisabled];
    [_sendButton setTitle:@"Send" forState:UIControlStateDisabled];
    [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [_sendButton setTitleColor:HEXCOLOR(0xB0B0B0) forState:UIControlStateDisabled];
    [_sendButton setTitleColor:HEXCOLOR(0xFFFFFF) forState:UIControlStateNormal];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightRegular];
    [_sendButton addTarget:self action:@selector(handleSendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _sendButton.enabled = NO;
    [self addSubview:_sendButton];
}

- (void)setupLayout
{
    _textViewMinContentHeight = ceilf(_font.lineHeight);
    _textViewMaxContentHeight = ceilf(_font.lineHeight * _numberOfLines + (_numberOfLines - 1) * _lineSpacing);
    
    _sepLine.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0.5f);
    
    CGFloat textViewWidth = CGRectGetWidth(self.bounds) - 12 - 12 - 64 - 12;
    CGFloat textViewMinHeight = _textView.contentInset.top + _textViewMinContentHeight + _textView.contentInset.bottom;
    _textView.frame = CGRectMake(12, 8, textViewWidth, textViewMinHeight);
    _placeholderLabel.frame = CGRectMake(12 + _textContainerInset.left, 8, textViewWidth - _textContainerInset.left - _textContainerInset.right, textViewMinHeight);
    _sendButton.frame = CGRectMake(12 + textViewWidth + 12, 8, 64, 32);
}

- (void)showPrompt
{
    // show prompt
}

- (void)updateWithTextView:(UITextView *)textView
{
    NSRange selectedRange = textView.selectedRange;
    
    _placeholderLabel.hidden = textView.text.length != 0;
    _sendButton.enabled = textView.text.length != 0;
    
    if (!textView.markedTextRange) {
        if (textView.text.length > _maxCharacterCount) {
            NSString *truncatedText = [textView.text substringToIndex:_maxCharacterCount];
            [textView setText:truncatedText];
            [self showPrompt];
        }
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = _lineSpacing;
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setValue:HEXCOLOR(0x404040) forKey:NSForegroundColorAttributeName];
        [attributes setValue:_font forKey:NSFontAttributeName];
        [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
        textView.attributedText = attributedText;
    }
    
    CGFloat height = ceilf([textView sizeThatFits:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)].height);
    height = MIN(_textViewMaxContentHeight, MAX(_textViewMinContentHeight, height));
    
    if (height > _textViewMinContentHeight) {
        textView.contentInset = UIEdgeInsetsMake(_lineSpacing, 0, _lineSpacing, 0);
    } else {
        textView.contentInset = UIEdgeInsetsMake(_textContainerInset.top + _lineSpacing / 2, 0, _textContainerInset.top + _lineSpacing / 2, 0);
    }
    
    if (fabs(textView.frame.size.height - height) > 1e-3) {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect textViewFrame = textView.frame;
            textViewFrame.size.height = height + textView.contentInset.top + textView.contentInset.bottom;
            textView.frame = textViewFrame;
            
            CGRect inputBarFrame = self.frame;
            CGFloat inputBarBottom = inputBarFrame.origin.y + inputBarFrame.size.height;
            CGFloat inputBarHeight = textViewFrame.size.height + 16;
            inputBarFrame.origin.y = inputBarBottom - inputBarHeight;
            inputBarFrame.size.height = inputBarHeight;
            self.frame = inputBarFrame;
            
            CGRect sendButtonFrame = _sendButton.frame;
            sendButtonFrame.origin.y = inputBarHeight - 8 - 32;
            _sendButton.frame = sendButtonFrame;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewDidChangeHeight:)]) {
                [self.delegate inputViewDidChangeHeight:self];
            }
        }];
    }
    
    if (height < _textViewMaxContentHeight) {
        [textView scrollRangeToVisible:NSMakeRange(0, 0)];
    } else {
        [textView scrollRangeToVisible:NSMakeRange(textView.text.length - 1, 1)];
    }
    
    textView.selectedRange = selectedRange;
}

#pragma mark - Actions

- (void)handleSendButtonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputView:sendText:)]) {
        [self.delegate inputView:self sendText:[self text]];
    }
}

#pragma mark - Public Methods

- (BOOL)isActive
{
    return [_textView isFirstResponder];
}

- (BOOL)becomeActive
{
    return [_textView becomeFirstResponder];
}

- (BOOL)resignActive
{
    return [_textView resignFirstResponder];
}

- (void)clear
{
    _textView.text = @"";
    [self updateWithTextView:_textView];
}

#pragma mark - Setters & Getters

- (void)setFont:(UIFont *)font
{
    if (!font) {
        font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightRegular];
    }
    
    _font = font;
    _textView.font = font;
    _placeholderLabel.font = font;
    [self setupLayout];
}

- (void)setLineSpacing:(CGFloat)lineSpacing
{
    if (lineSpacing < 0) {
        lineSpacing = 3.0f;
    }
    
    _lineSpacing = lineSpacing;
    _textView.contentInset = UIEdgeInsetsMake(_textContainerInset.top + lineSpacing / 2, 0, _textContainerInset.bottom + lineSpacing / 2, 0);
    [self setupLayout];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    if (numberOfLines < 1) {
        numberOfLines = 4;
    }
    
    _numberOfLines = numberOfLines;
    [self setupLayout];
}

- (void)setMaxCharacterCount:(NSInteger)maxCharacterCount
{
    if (maxCharacterCount < 0) {
        maxCharacterCount = 1000;
    }
    
    _maxCharacterCount = maxCharacterCount;
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    if (textContainerInset.top < 0
        || textContainerInset.left < 0
        || textContainerInset.bottom < 0
        || textContainerInset.right < 0) {
        textContainerInset = UIEdgeInsetsMake(6, 16, 6, 16);
    }
    
    _textContainerInset = textContainerInset;
    _textView.textContainerInset = UIEdgeInsetsMake(0, textContainerInset.left, 0, textContainerInset.right);
    _textView.contentInset = UIEdgeInsetsMake(textContainerInset.top + _lineSpacing / 2, 0, textContainerInset.bottom + _lineSpacing / 2, 0);
    [self setupLayout];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    if (!placeholder) {
        placeholder = @"Sending...";
    }
    _placeholder = [placeholder copy];
    _placeholderLabel.text = placeholder;
}

- (NSString *)text
{
    return self.textView.text;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewShouldBeginEditing:)]) {
        return [self.delegate inputViewShouldBeginEditing:self];
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewDidBeginEditing:)]) {
        [self.delegate inputViewDidBeginEditing:self];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewShouldEndEditing:)]) {
        return [self.delegate inputViewShouldEndEditing:self];
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewDidEndEditing:)]) {
        [self.delegate inputViewDidEndEditing:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self handleSendButtonClicked:nil];
        return NO;
    }
    
    UITextRange *markedTextRange = textView.markedTextRange;
    if (markedTextRange) {
        return YES;
    }
    
    BOOL shouldChangeText = YES;
    
    NSString *fakeText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger diff = _maxCharacterCount - fakeText.length;
    if (diff >= 0) {
        shouldChangeText = YES;
        _showPromptFlag = NO;
    } else {
        shouldChangeText = NO;
        if (!_showPromptFlag) {
            _showPromptFlag = YES;
            [self showPrompt];
        }
        
        NSInteger len = text.length + diff;
        NSRange truncatedRange = NSMakeRange(0, MAX(len, 0));
        NSString *truncatedText = [text substringWithRange:truncatedRange];
        [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:truncatedText]];
        textView.selectedRange = NSMakeRange(range.location + truncatedRange.length, 0);
        [self updateWithTextView:textView];
    }
    
    return shouldChangeText;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateWithTextView:textView];
}

@end
