//
//  WebResponseHandler.m
//  TestApp
//
//  Created by wookyoung noh on 09/10/10.
//  Copyright 2010 factorcat. All rights reserved.
//

#import "WebResponseHandler.h"
#import "Logger.h"
#import "NSStringExt.h"
#import "HTTPServer.h"
#import "ConsoleManager.h"
#import "CommandManager.h"
#import "NSStringExt.h"
#import "GeometryExt.h"
#import "NSArrayExt.h"
#import <QuartzCore/QuartzCore.h>
#import "NSArrayBlock.h"
#import "Inspect.h"
#import "NSBundleExt.h"

#define INSPECT(obj) SWF(@"%@", [obj inspect])

@interface NSString (HTMLExtensions)

+ (NSDictionary *)htmlEscapes;
+ (NSDictionary *)htmlUnescapes;
- (NSString *)htmlEscapedString;
- (NSString *)htmlUnescapedString;

@end
@implementation NSString (HTMLExtensions)

static NSDictionary *htmlEscapes = nil;
static NSDictionary *htmlUnescapes = nil;

+ (NSDictionary *)htmlEscapes {
	if (!htmlEscapes) {
		htmlEscapes = [[NSDictionary alloc] initWithObjectsAndKeys:
					   @"&amp;", @"&",
					   @"&lt;", @"<",
					   @"&gt;", @">",
					   nil
					   ];
	}
	return htmlEscapes;
}

+ (NSDictionary *)htmlUnescapes {
	if (!htmlUnescapes) {
		htmlUnescapes = [[NSDictionary alloc] initWithObjectsAndKeys:
						 @"&", @"&amp;",
						 @"<", @"&lt;", 
						 @">", @"&gt;",
						 nil
						 ];
	}
	return htmlEscapes;
}

static NSString *replaceAll(NSString *s, NSDictionary *replacements) {
	for (NSString *key in replacements) {
		NSString *replacement = [replacements objectForKey:key];
		s = [s stringByReplacingOccurrencesOfString:key withString:replacement];
	}
	return s;
}

- (NSString *)htmlEscapedString {
	return replaceAll(self, [[self class] htmlEscapes]);
}

- (NSString *)htmlUnescapedString {
	return replaceAll(self, [[self class] htmlUnescapes]);
}

@end



@implementation WebResponseHandler


+(void) load {
	[HTTPResponseHandler registerHandler:self];
}

+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
				  method:(NSString *)requestMethod
					 url:(NSURL *)requestURL
			headerFields:(NSDictionary *)requestHeaderFields {
	if ([requestURL.path isEqualToString:@"/"]) {
		return YES;
	}
	
	return NO;
}


- (void)startResponse {
	NSString* arg = nil;
	NSString* query = [url query];
	if (nil != query) {
		NSString* param = @"arg=";
		if (query.length > param.length) {
			arg = [query slice:param.length backward:-1];
		}
	}
	BOOL recursive = [arg isEqualToString:LS_OPTION_RECURSIVE];
	NSMutableArray* ary = [NSMutableArray array];
	NSMutableArray* topLinks = [NSMutableArray array];
	NSArray* arrayLS = [COMMANDMAN array_ls:[CONSOLEMAN currentTargetObjectOrTopViewController] arg:arg];
	NSString* title = [NSBundle bundleName];
	for (NSArray* pair in arrayLS) {
		int lsType = [[pair objectAtFirst] intValue];
		id obj = [pair objectAtSecond];
		switch (lsType) {
			case LS_OBJECT: {
					NSString* classNameUpper = [SWF(@"%@", [obj class]) uppercaseString];
					[ary addObject:SWF(@"[%@]: %@", classNameUpper, [INSPECT(obj) htmlEscapedString])];
					if ([obj isKindOfClass:[UIView class]]) {
						[ary addObject:SWF(@"<img src='/image/%p.png' /><hr />", obj)];
					} else if ([obj respondsToSelector:@selector(title)]) {
						title = SWF(@"%@ :: %@", [NSBundle bundleName], [obj title]);
						if (recursive) {
							[topLinks addObject:@"<a href='/'>recursive off</a>"];
						} else {
							[topLinks addObject:@"<a href='/?arg=-r'>recursive on</a>"];
						}
					}
				}
				break;
			case LS_VIEWCONTROLLERS:
				[ary addObject:SWF(@"VIEWCONTROLLERS: %@", [INSPECT(array_prefix_index(obj)) htmlEscapedString])];
				break;
			case LS_TABLEVIEW:
				[ary addObject:SWF(@"TABLEVIEW: %@", [INSPECT(obj) htmlEscapedString])];
				break;
			case LS_SECTIONS: {
					[ary addObject:SWF(@"SECTIONS: ")];
					int section = 0;
					for (NSArray* sectionArray in (NSArray*)obj) {
						int row = 0;
						for (id cell in sectionArray) {
							[ary addObject:SWF(@"[%d %d] %@<br /><img src='/image/%p.png' /><hr />", section, row, [INSPECT(cell) htmlEscapedString], cell)];
							row += 1;
						}
						section += 1;
					}
				}
				break;
			case LS_VIEW:
				[ary addObject:SWF(@"VIEW: %@", [INSPECT(obj) htmlEscapedString])];
				[ary addObject:SWF(@"<img src='/image/%p.png' /><hr />", obj)];
				break;
			case LS_INDENTED_VIEW: {
					int depth = [[pair objectAtThird] intValue];
					[ary addObject:SWF(@"%@%@<br /><img src='/image/%p.png' /><hr />", [TAB repeat:depth], [INSPECT(obj) htmlEscapedString], obj)];
				}
				break;				
			case LS_VIEW_SUBVIEWS: {
					[ary addObject:SWF(@"VIEW.SUBVIEWS: ")];
					int idx = 0;
					for (id subview in (NSArray*)obj) {
						[ary addObject:SWF(@"[%d] %@<br /><img src='/image/%p.png' /><hr />", idx, [INSPECT(subview) htmlEscapedString], subview)];
						idx += 1;
					}				
				}
				break;
			case LS_TABBAR:
				[ary addObject:SWF(@"TABBAR: %@", [INSPECT(obj) htmlEscapedString])];
				[ary addObject:SWF(@"<img src='/image/%p.png' /><hr />", obj)];
				break;				
			case LS_NAVIGATIONITEM:
				[ary addObject:SWF(@"NAVIGATIONITEM: %@", [INSPECT(obj) htmlEscapedString])];
				break;																
			case LS_NAVIGATIONCONTROLLER_TOOLBAR:
				[ary addObject:SWF(@"NAVIGATIONCONTROLLER_TOOLBAR: %@", [INSPECT(obj) htmlEscapedString])];				
				[ary addObject:SWF(@"<img src='/image/%p.png' /><hr />", obj)];
				break;								
			case LS_NAVIGATIONCONTROLLER_TOOLBAR_ITEMS:
				[ary addObject:SWF(@"NAVIGATIONCONTROLLER_TOOLBAR_ITEMS: %@", [INSPECT(obj) htmlEscapedString])];				
				break;																
			default:
				break;
		}
	}
	[ary addObject:@"<img src='/image/capture.png' border='20'>"];

	NSString* body = SWF(@"<pre>%@</pre>", [ary join:LF]);
	NSString* head = SWF(@"<meta http-equiv='content-type' content='text/html; charset=UTF-8' /><title>%@</title>", title);
	NSString* html = SWF(@"<html><head>%@</head><body bgcolor='#d3d3d3'>%@%@</body></html>", head, [topLinks join:LF], body);
	
	NSData* fileData = [html dataUsingEncoding:NSUTF8StringEncoding];

	CFHTTPMessageRef response =
	CFHTTPMessageCreateResponse(
								kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_1);
	CFHTTPMessageSetHeaderFieldValue(
									 response, (CFStringRef)@"Content-Type", (CFStringRef)@"text/html");
	CFHTTPMessageSetHeaderFieldValue(
									 response, (CFStringRef)@"Connection", (CFStringRef)@"close");
	CFHTTPMessageSetHeaderFieldValue(
									 response,
									 (CFStringRef)@"Content-Length",
									 (CFStringRef)[NSString stringWithFormat:@"%ld", [fileData length]]);
	CFDataRef headerData = CFHTTPMessageCopySerializedMessage(response);
	
	@try
	{
		[fileHandle writeData:(NSData *)headerData];
		[fileHandle writeData:fileData];
	}
	@catch (NSException *exception)
	{
		// Ignore the exception, it normally just means the client
		// closed the connection from the other end.
	}
	@finally
	{
		CFRelease(headerData);
		[server closeHandler:self];
	}
}

@end
