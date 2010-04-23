//
//  SettingsModel.m
//  LSTAGPS
//
//  Created by Andre Navarro on 3/23/10.
//  Copyright 2010 Andre Navarro All rights reserved.
//

#import "SettingsModel.h"


@implementation SettingsModel


+(id)getSetting:(NSString*)setting {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString *val = nil;
	
	if (standardUserDefaults) 
		val = [standardUserDefaults objectForKey:setting];
	
	return val;
	
}

+(BOOL)setSetting:(NSString*)setting forKey:(NSString*)key {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setObject:setting forKey:key];
		[standardUserDefaults synchronize];
		return YES;
	}	 else {
		return NO;
	}
}

@end
