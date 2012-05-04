//
//  main.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
	@try {
		return NSApplicationMain(argc, (const char **)argv);
	}
	@catch (NSException *exception) {
		NSLog(@"Catch Main %@, %@, %@", [exception name], [exception reason], [exception userInfo]);
	}
}
