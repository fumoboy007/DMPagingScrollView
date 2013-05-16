//
//  ViewController.m
//  DMPagingScrollView
//
//  Created by Darren Mo on 2013-05-15.
//  Copyright (c) 2013 Darren Mo. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end


@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	
	__weak UIView *lastView = nil;
	
	for (NSUInteger idx = 0; idx < 5; idx++) {
		UIView *newView = NewView();
		
		[_scrollView addSubview:newView];
		
		
		NSMutableArray *constraints = [[NSMutableArray alloc] init];
		
		if (lastView) {
			[constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[lastView]-50-[newView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lastView, newView)]];
		} else {
			[constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[newView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(newView)]];
		}
		
		[constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(newView)]];
		[constraints addObject:[NSLayoutConstraint constraintWithItem:newView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
		
		[_scrollView addConstraints:constraints];
		
		
		lastView = newView;
	}
	
	if (lastView)
		[_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[lastView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lastView)]];
}

static inline UIView *NewView() {
	UIView *view = [[UIView alloc] init];
	
	view.backgroundColor = [UIColor greenColor];
	
	view.translatesAutoresizingMaskIntoConstraints = NO;
	[view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:200]];
	
	return view;
}

@end
