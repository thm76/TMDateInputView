//
//  NSDate+TMDateInputView.m
//  TMDateInputView
//
//  Created by Thomas on 17/11/2013.
//  Copyright (c) 2013 Thomas Müller. All rights reserved.
//

#import "NSDate+TMDateInputView.h"

@implementation NSDate (TMDateInputView)

+ (NSCalendar *)sharedCalendar
{
    static NSCalendar *_sharedCalendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    });
    return _sharedCalendar;
}

- (BOOL)isSameDayAs:(NSDate *)date
{
    NSDateComponents *comps1 = [[NSDate sharedCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    NSDateComponents *comps2 = [[NSDate sharedCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    return ([comps1 year] == [comps2 year] && [comps1 month] == [comps2 month] && [comps1 day] == [comps2 day]);
}

- (BOOL)isToday
{
    return [self isSameDayAs:[NSDate date]];
}

@end
