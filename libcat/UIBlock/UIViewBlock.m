//
//  UIViewBlock.m
//  TestApp
//
//  Created by wookyoung noh on 04/10/10.
//  Copyright 2010 factorcat. All rights reserved.
//

#import "UIViewBlock.h"
#import "Async.h"
#import "NSArrayExt.h"

#define DEFAULT_DURATION 0.2

@implementation UIView (Block)

+(void) animate:(AnimationBlock)block {
	[self animateWithDuration:DEFAULT_DURATION
				   animations:^{
					   block(); 
				   }];
}

+(void) animate:(AnimationBlock)block afterDone:(AnimationBlock)doneBlock {
	[self animateWithDuration:DEFAULT_DURATION
				   animations:^{
					   block();
				   }
				   completion:^(BOOL finished) {
						if (finished) {
							doneBlock();
						}
				   }];
}

-(void) traverseSubviews:(TraverseViewBlock)block {
	[self traverseSubviews:block reverse:false];
}

-(void) traverseSubviews:(TraverseViewBlock)block reverse:(BOOL)reverse {
	[self traverseSubviews:block depth:0 reverse:reverse];
}

-(void) traverseSubviews:(TraverseViewBlock)block depth:(int)depth reverse:(BOOL)reverse {
	block(depth, self);
	for (UIView* subview in (reverse ? [[self subviews] reverse] : [self subviews])) {
		[subview traverseSubviews:block depth:depth+1 reverse:reverse];
	}
}

-(void) traverseSuperviews:(TraverseViewBlock)block {
	int depth = 0;
	UIView* view = self;
	while ((view = view.superview) != nil) {
		depth += 1;
	}
	[self traverseSuperviews:block depth:depth];
}

-(void) traverseSuperviews:(TraverseViewBlock)block depth:(int)depth {
	UIView* superview_ = self.superview;
	if (nil != superview_) {
		[superview_ traverseSuperviews:block depth:depth-1];
	}
	block(depth, self);
}

@end