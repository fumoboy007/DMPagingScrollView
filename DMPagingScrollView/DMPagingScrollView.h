//
//  DMPagingScrollView.h
//  DMPagingScrollView
//
//  Created by Darren Mo on 2013-05-15.
//  Copyright (c) 2013 Darren Mo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMPagingScrollView : UIScrollView

// The width, in points, of each page. Set to a non-positive number to use the view's width. Default is 0.
@property (nonatomic) CGFloat pageWidth;

// The height, in points, of each page. Set to a non-positive number to use the view's height. Default is 0.
@property (nonatomic) CGFloat pageHeight;

@end
