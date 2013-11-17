//
//  NSDate+TMDateInputView.h
//  TMDateInputView
//
//  Created by Thomas on 17/11/2013.
//  Copyright (c) 2013 Thomas Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TMDateInputView)

- (BOOL)isSameDayAs:(NSDate *)date;
- (BOOL)isToday;

@end
