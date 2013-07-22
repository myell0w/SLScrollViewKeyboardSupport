//
//  SLScrollViewKeyboardSupport.m
//  SLScrollViewKeyboardSupport
//
//  The MIT License (MIT)
//  Copyright (c) 2013 Oliver Letterer, Sparrow-Labs
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "SLScrollViewKeyboardSupport.h"

static UIView *findFirstResponderInView(UIView *view)
{
    if (view.isFirstResponder) {
        return view;
    }
    
    for (UIView *subview in view.subviews) {
        UIView *firstResponder = findFirstResponderInView(subview);
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    
    return nil;
}



@interface SLScrollViewKeyboardSupport () {
    
}

@end



@implementation SLScrollViewKeyboardSupport

#pragma mark - Initialization

- (id)initWithScrollView:(UIScrollView *)scrollView
{
    if (self = [super init]) {
        _scrollView = scrollView;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillHideCallback:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillShowCallback:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private category implementation ()

- (void)_keyboardWillShowCallback:(NSNotification *)notification
{
    UIView *firstResponder = findFirstResponderInView([[UIApplication sharedApplication] keyWindow]);
    UIScrollView *scrollView = self.scrollView;
    
    if (![firstResponder isDescendantOfView:scrollView]) {
        return;
    }
    
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] | UIViewAnimationOptionBeginFromCurrentState;
    
    CGRect keyboardFrame = [[UIApplication sharedApplication].keyWindow convertRect:endFrame toView:scrollView];
    CGRect hiddenFrame = CGRectIntersection(keyboardFrame, scrollView.bounds);

    [UIView animateWithDuration:duration delay:0.0f options:options animations:^{
        //[scrollView setContentOffset:CGPointMake(0.0f, CGRectGetMinY(responderFrame)) animated:NO];
        scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(hiddenFrame), 0.0f);
    } completion:NULL];
}

- (void)_keyboardWillHideCallback:(NSNotification *)notification
{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] | UIViewAnimationOptionBeginFromCurrentState;
    
    [UIView animateWithDuration:duration delay:0.0f options:options animations:^{
        self.scrollView.contentInset = UIEdgeInsetsZero;
    } completion:NULL];
}

@end
