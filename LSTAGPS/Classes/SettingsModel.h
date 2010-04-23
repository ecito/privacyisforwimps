//
//  SettingsModel.h
//  LSTAGPS
//
//  Created by Andre Navarro on 3/23/10.
//  Copyright 2010 Andre Navarro All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingsModel : NSObject {

}

+(id)getSetting:(NSString*)setting;
+(BOOL)setSetting:(NSString*)setting forKey:(NSString*)key;

@end

