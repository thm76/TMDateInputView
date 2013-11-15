//
//  DateInputView.m
//  DateInputView
//
//  Created by Thomas on 14/11/2013.
//  Copyright (c) 2013 Thomas Müller. All rights reserved.
//

#import "TMDateInputView.h"

@interface TMDateInputView ()
- (void)setMonth:(NSDate *)month;
- (void)setupWeekdayLabelsInView:(UIView *)view;
- (void)updateDisplay;
@end

@implementation TMDateInputView {
    NSCalendar *_calendar;
    NSDate *_month;
}

static CGFloat const kDateInputViewMonthLabelHeight = 33.0f;
static CGFloat const kDateInputViewWeekdayLabelHeight = 22.0f;
static CGFloat const kDateInputViewDayCellHeight = 33.0f;
static CGFloat const kDateInputViewSpacing = 1.0f;

+ (CGFloat)preferredHeight
{
    CGFloat spacing = kDateInputViewSpacing / [UIScreen mainScreen].scale;

    CGFloat height = 0;
    height += kDateInputViewMonthLabelHeight;
    height += spacing;
    height += kDateInputViewWeekdayLabelHeight;
    height += spacing;
    height += kDateInputViewDayCellHeight * 6;
    
    return ceilf(height);
}

- (id)init
{
    return [self initWithFrame:CGRectMake(0.0f, 0.0f, 320.0, [TMDateInputView preferredHeight])];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.753 green:0.765 blue:0.788 alpha:1.000]; // gridColor
        
        CGFloat spacing = kDateInputViewSpacing / [UIScreen mainScreen].scale;
        CGFloat width = CGRectGetWidth(frame);
        
        UIView *monthLabelView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                          0.0f,
                                                                          width,
                                                                          kDateInputViewMonthLabelHeight)];
        [self addSubview:monthLabelView];
        
        UIView *weekdayLabelView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                            CGRectGetMaxY(monthLabelView.frame) + spacing,
                                                                            width,
                                                                            kDateInputViewWeekdayLabelHeight)];
        [self addSubview:weekdayLabelView];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                       CGRectGetMaxY(weekdayLabelView.frame) + spacing,
                                                                       width,
                                                                       CGRectGetHeight(frame) - CGRectGetHeight(weekdayLabelView.frame) - 1.0f)];
        [self addSubview:contentView];
        
        for (UIView *view in @[monthLabelView, weekdayLabelView, contentView]) {
            view.backgroundColor = [UIColor whiteColor];
        }
        
        _calendar = [NSCalendar currentCalendar];
        
        [self setupWeekdayLabelsInView:weekdayLabelView];
        
        self.date = [NSDate date];
    }
    return self;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    [self setMonth:date];
}

- (void)setMonth:(NSDate *)month
{
    _month = month;
    [self updateDisplay];
}

- (void)updateDisplay
{
    NSLog(@"updating for %@", _month);
}

- (void)setupWeekdayLabelsInView:(UIView *)parentView
{
    for (UIView *view in parentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [_calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSDateComponents *dayComps = [[NSDateComponents alloc] init];
    [dayComps setDay:[_calendar firstWeekday] - [comps weekday]];
    date = [_calendar dateByAddingComponents:dayComps toDate:date options:0];

    [dayComps setDay:1];
    
    NSLog(@"firstWeekDay: %lu", (unsigned long)[_calendar firstWeekday]);
    NSLog(@"weekday: %ld", (long)[[_calendar components:NSWeekdayCalendarUnit fromDate:date] weekday]);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ccc"];
    
    CGFloat width = floorf(CGRectGetWidth(parentView.bounds) / 7);
    CGFloat x = floorf((CGRectGetWidth(parentView.bounds) - width * 7) / 2);
    CGRect frame = CGRectMake(x, 0.0f, width, CGRectGetHeight(parentView.bounds));
    NSLog(@"first frame: %@", NSStringFromCGRect(frame));
    
    for (NSUInteger i = 0; i < 7; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.font = [UIFont systemFontOfSize:10.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [formatter stringFromDate:date];
        [parentView addSubview:label];
        
        date = [_calendar dateByAddingComponents:dayComps toDate:date options:0];
        frame.origin.x += frame.size.width;
    }
}

@end
