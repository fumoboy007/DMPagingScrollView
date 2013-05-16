//
//  DMPagingScrollView.m
//  DMPagingScrollView
//
//  Created by Darren Mo on 2013-05-15.
//  Copyright (c) 2013 Darren Mo. All rights reserved.
//

#import "DMPagingScrollView.h"

#import <objc/runtime.h>


#define DRAG_DISPLACEMENT_THRESHOLD 20


@interface DMPagingScrollView () <UIScrollViewDelegate>

@end


@implementation DMPagingScrollView {
	// Delegate caching
	BOOL _delegateRespondsToWillBeginDragging;
	BOOL _delegateRespondsToWillEndDragging;
	BOOL _delegateRespondsToDidEndDragging;
	BOOL _delegateRespondsToDidEndDecelerating;
	BOOL _delegateRespondsToDidEndScrollingAnimation;
	BOOL _delegateRespondsToDidEndZooming;
	
	
	// Indicates whether a snapping animation is occurring
	BOOL _snapping;
	
	
	// Properties of the drag
	CGPoint _dragVelocity;
	CGPoint _dragDisplacement;
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self performInit];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self performInit];
	}
	
	return self;
}

- (void)performInit {
	[super setDelegate:self];
	
	
	if ([super isPagingEnabled]) {
		[super setPagingEnabled:NO];
		
		_pagingEnabled = YES;
	}
}

#pragma mark - Overriding the delegate

@synthesize delegate = _actualDelegate;

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
	if (delegate == _actualDelegate)
		return;
	
	
	_actualDelegate = delegate;
	
	
	// Account for any caching that UIScrollView may perform
	[super setDelegate:nil];
	[super setDelegate:self];
	
	
	// Do our own caching
	_delegateRespondsToWillBeginDragging = [_actualDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)];
	_delegateRespondsToWillEndDragging = [_actualDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)];
	_delegateRespondsToDidEndDragging = [_actualDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)];
	_delegateRespondsToDidEndDecelerating = [_actualDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)];
	_delegateRespondsToDidEndScrollingAnimation = [_actualDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)];
	_delegateRespondsToDidEndZooming = [_actualDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	if (_actualDelegate && IsSelectorPartOfScrollViewDelegate([anInvocation selector])) {
		[anInvocation invokeWithTarget:_actualDelegate];
	} else {
		[super forwardInvocation:anInvocation];
	}
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	BOOL respondsToSelector = [super respondsToSelector:aSelector];
	
	if (!respondsToSelector) {
		if (_actualDelegate && IsSelectorPartOfScrollViewDelegate(aSelector))
			respondsToSelector = [_actualDelegate respondsToSelector:aSelector];
	}
	
	return respondsToSelector;
}

static inline BOOL IsSelectorPartOfScrollViewDelegate(SEL aSelector) {
	struct objc_method_description optionalMethodDescription = protocol_getMethodDescription(@protocol(UIScrollViewDelegate), aSelector, NO, YES);
	struct objc_method_description requiredMethodDescription = protocol_getMethodDescription(@protocol(UIScrollViewDelegate), aSelector, YES, YES);
	
	return optionalMethodDescription.name != NULL || requiredMethodDescription.name != NULL;
}

#pragma mark - Configuration

@synthesize pagingEnabled = _pagingEnabled;

- (void)setPagingEnabled:(BOOL)pagingEnabled {
	if (pagingEnabled == _pagingEnabled)
		return;
	
	
	_pagingEnabled = pagingEnabled;
	
	
	if (_pagingEnabled)
		[self snapToPage];
}

- (void)setPageWidth:(CGFloat)pageWidth {
	if (pageWidth == _pageWidth)
		return;
	
	
	_pageWidth = pageWidth;
	
	
	if (_pagingEnabled)
		[self snapToPage];
}

#pragma mark - Paging support

- (void)snapToPage {
	CGPoint pageOffset;
	pageOffset.x = [self pageOffsetForComponent:YES];
	pageOffset.y = [self pageOffsetForComponent:NO];
	
	
	CGPoint currentOffset = self.contentOffset;
	
	if (!CGPointEqualToPoint(pageOffset, currentOffset)) {
		_snapping = YES;
		
		[self setContentOffset:pageOffset animated:YES];
	}
	
	
	_dragVelocity = CGPointZero;
	_dragDisplacement = CGPointZero;
}

- (CGFloat)pageOffsetForComponent:(BOOL)isX {
	CGFloat pageLength = isX ? _pageWidth : _pageHeight;
	
	if (pageLength < FLT_EPSILON)
		pageLength = isX ? CGRectGetWidth(self.bounds) : CGRectGetHeight(self.bounds);
	
	pageLength *= self.zoomScale;
	
	
	CGFloat totalLength = isX ? self.contentSize.width : self.contentSize.height;
	
	CGFloat visibleLength = (isX ? CGRectGetWidth(self.bounds) : CGRectGetHeight(self.bounds)) * self.zoomScale;
	
	CGFloat currentOffset = isX ? self.contentOffset.x : self.contentOffset.y;
	
	CGFloat dragVelocity = isX ? _dragVelocity.x : _dragVelocity.y;
	
	CGFloat dragDisplacement = isX ? _dragDisplacement.x : _dragDisplacement.y;
	
	
	CGFloat newOffset;
	
	
	CGFloat index = currentOffset / pageLength;
	
	CGFloat lowerIndex = floorf(index);
	CGFloat upperIndex = ceilf(index);
	
	if (ABS(dragDisplacement) < DRAG_DISPLACEMENT_THRESHOLD) {
		if (index - lowerIndex > upperIndex - index) {
			index = upperIndex;
		} else {
			index = lowerIndex;
		}
	} else {
		if (dragVelocity > 0) {
			index = upperIndex;
		} else {
			index = lowerIndex;
		}
	}
	
	
	newOffset = pageLength * index;
	
	if (newOffset > totalLength - visibleLength)
		newOffset = totalLength - visibleLength;
	
	if (newOffset < 0)
		newOffset = 0;
	
	
	return newOffset;
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	_dragDisplacement = scrollView.contentOffset;
	
	
	if (_delegateRespondsToWillBeginDragging)
		[_actualDelegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if (_pagingEnabled) {
		*targetContentOffset = scrollView.contentOffset;
		
		
		_dragVelocity = velocity;
		
		_dragDisplacement = CGPointMake(scrollView.contentOffset.x - _dragDisplacement.x, scrollView.contentOffset.y - _dragDisplacement.y);
	}
	
	
	if (!_pagingEnabled && _delegateRespondsToWillEndDragging)
		[_actualDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate && _pagingEnabled)
		[self snapToPage];
	
	
	if (_delegateRespondsToDidEndDragging)
		[_actualDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (_pagingEnabled)
		[self snapToPage];
	
	
	if (_delegateRespondsToDidEndDecelerating)
		[_actualDelegate scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	if (!_snapping && _pagingEnabled) {
		[self snapToPage];
	} else {
		_snapping = NO;
	}
	
	
	if (_delegateRespondsToDidEndScrollingAnimation)
		[_actualDelegate scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
	if (_pagingEnabled)
		[self snapToPage];
	
	
	if (_delegateRespondsToDidEndZooming)
		[_actualDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
}

@end
