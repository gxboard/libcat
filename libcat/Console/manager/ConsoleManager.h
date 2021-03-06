//
//  ConsoleManager.h
//  TestApp
//
//  Created by wookyoung noh on 07/10/10.
//  Copyright 2010 factorcat. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CONSOLEMAN	[ConsoleManager sharedManager]
enum {
	kTagLogsButton = 50,
	kTagRecordButton,
};
#define SETTING_CONSOLE_LOGS_BUTTON @"Console Logs Button"
#define SETTING_CONSOLE_RECORD_BUTTON @"Console Record Button"

typedef enum { kGetterReturnTypeString, kGetterReturnTypeObject } GetterReturnType ;


@interface ConsoleManager : NSObject {
	id currentTargetObject; // TARGET
	int server_port;
	int COLUMNS;
}
@property (nonatomic, retain) id currentTargetObject; // retain to get the view class in command_prompt:arg:
@property (nonatomic, readonly) int server_port;
@property (nonatomic) int COLUMNS;

-(id) input:(NSString*)command arg:(id)arg ;
-(id) input:(NSString*)input ;
+ (ConsoleManager*) sharedManager ;

-(id) get_argObject:(NSString*)arg ;
-(NSString*) getterChain:(id)command arg:(id)arg ;
-(id) arg_to_proper_object:(id)arg ;
-(NSString*) setterChain:(id)command arg:(id)arg ;
-(id) currentTargetObjectOrTopViewController ;
-(id) getterChainObject:(id)command arg:(id)arg returnType:(GetterReturnType)returnType ;

-(UIViewController*) get_topViewController ;
-(UIWindow*) get_keyWindow ;
-(UIViewController*) get_rootViewController ;

-(void) start_up ;
-(void) start_up:(int)port ;
-(void) start_servers ;
-(void) start_servers:(int)port ;
-(void) stop ;
-(NSString*) get_local_ip_address ;
-(void) make_console_buttons ;
-(void) hide_console_button ;
-(void) toggle_logs_button ;
-(void) update_record_button ;
@end



@interface ConsoleButton : UIButton
@end