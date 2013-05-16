// The MIT License (MIT)
//
// Copyright (c) 2013 Darren Mo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


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
