//
//  NSNumberExt.m
//  Bloque
//
//  Created by Woo-Kyoung Noh on 08/03/10.
//  Copyright 2010 factorcat. All rights reserved.
//

#import "NSNumberExt.h"
#import "Logger.h"


int get_random(int div) {
	return (arc4random() % div);
}

CGFloat int_to_float(int val) {
	return val + 0.0f;
}

int float_to_int(float val) {
	return (int)val;
}

BOOL is_odd(int n) {
	return 1 == n%2;
}

int enum_rshift(int greatest, int current) {
	return ((current+1) == greatest) ? 0 : current+1;
}



@implementation NSNumber (MathFunctions)
-(NSString*) chr {
	return [NSString stringWithFormat:@"%C", [self charValue]];
}
-(NSNumber*) next {
	return [NSNumber numberWithInt:[self intValue] + 1];
}
-(NSNumber*) round_up {
	double value = round([self doubleValue]);
	return [NSNumber numberWithDouble:value];
}
-(NSNumber*) ceiling {
	double value = ceil([self doubleValue]);
	return [NSNumber numberWithDouble:value];
}
-(NSNumber*) floor_down {
	double value = floor([self doubleValue]);
	return [NSNumber numberWithDouble:value];
}
@end