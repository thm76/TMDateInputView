//
//  DateInputView.m
//  DateInputView
//
//  Created by Thomas on 14/11/2013.
//  Copyright (c) 2013 Thomas Müller. All rights reserved.
//

#import "TMDateInputView.h"

#import "NSDate+TMDateInputView.h"

@interface TMDateInputView ()
- (void)setMonth:(NSDate *)month;
- (void)setupWeekdayLabelsInView:(UIView *)view;
- (void)updateDisplay;
@end

@implementation TMDateInputView {
    NSCalendar *_calendar;
    NSDate *_month;
    NSArray *_dayButtons;
}

static CGFloat const kDateInputViewMonthLabelHeight = 32.0f;
static CGFloat const kDateInputViewWeekdayLabelHeight = 22.0f;
static CGFloat const kDateInputViewDayCellHeight = 32.0f;
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
        
        NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:31];
        for (int i = 0; i < 31; i++) {
            UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
            button.bounds = CGRectMake(0.0f, 0.0f, kDateInputViewDayCellHeight, kDateInputViewDayCellHeight);
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button setTitle:[NSString stringWithFormat:@"%d", i+1] forState:UIControlStateNormal];

            [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
            
            [buttons addObject:button];
            [contentView addSubview:button];
        }
        _dayButtons = buttons;
        
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
    NSRange dateRange = [_calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:_month];
    NSLog(@"  (days %d to %d)", dateRange.location, dateRange.length);
    
    NSDateComponents *comps = [_calendar components:NSMonthCalendarUnit|NSYearCalendarUnit|NSTimeZoneCalendarUnit fromDate:_month];
    [comps setDay:dateRange.location];
    NSDate *date = [_calendar dateFromComponents:comps];
    
    // find position of first button in grid
    comps = [_calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSInteger weekday = [comps weekday];
    NSInteger x = weekday - [_calendar firstWeekday];
    if (x < 0) { x+= 7; }
    NSInteger y = 0;
    
    // calculate widths and heights etc
    CGFloat avaiableWidth = CGRectGetWidth(((UIButton *)_dayButtons[0]).superview.bounds);
    CGFloat width = floorf(avaiableWidth / 7);
    CGFloat height = kDateInputViewDayCellHeight;
    
    CGPoint offset;
    offset.x = ((avaiableWidth - width * 7) + width) / 2.0f;
    offset.y = height / 2.0f;
    
    NSLog(@"offset %@, width %f, height %f", NSStringFromCGPoint(offset), width, height);

    // loop through buttons and show/hide and reposition them
    NSUInteger firstVisibleButtonIndex = dateRange.location - 1;
    NSUInteger lastVisibleButtonIndex = firstVisibleButtonIndex + dateRange.length - 1;
    NSDateComponents *oneDayComponents = [[NSDateComponents alloc] init];
    [oneDayComponents setDay:1];
    for (NSUInteger i = 0; i < [_dayButtons count]; i++)
    {
        UIButton *button = (UIButton *)_dayButtons[i];
        if (i < firstVisibleButtonIndex || i > lastVisibleButtonIndex) {
            button.alpha = 0.0f;
            NSLog(@"hiding %d", i);
            continue;
        }
        
        button.alpha = 1.0;
        button.bounds = CGRectMake(0.0f, 0.0f, width, height);
        button.center = CGPointMake(offset.x + x * width, offset.y + y * height);
        
        // adjust text color and background
        NSLog(@"%@", self.tintColor);
        UIColor *color = [date isToday] ? self.tintColor : [UIColor darkTextColor];
        if ([date isSameDayAs:_date]) {
            // background and inverted text color
            button.backgroundColor = color;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:color forState:UIControlStateNormal];
        }
        
        x++;
        if (x > 6) {
            x = 0;
            y++;
        }
        date = [_calendar dateByAddingComponents:oneDayComponents toDate:date options:0];
    }
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
