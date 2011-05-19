//
//  DBConnectAppDelegate.m
//  DBConnect
//
//  Created by Sergey Mamontov on 5/18/11.
//  Copyright 2011 Tattooed Orange. All rights reserved.
//

#import "DBConnectAppDelegate.h"
#import "DBCDatabase.h"

@implementation DBConnectAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    DBCDatabase *db = [[DBCDatabase alloc] initWithPath:@":memory:" defaultEncoding:DBCDatabaseEncodingUTF8];
    [db open];
    [db evaluateUpdateWithParameters:@"SELECT * FROM sqlite3_master WHERE type='table' NOT LIKE 'sqlite_%@' %l", @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test", [NSNumber numberWithFloat:16.0f], nil];
    window = [[UIWindow alloc] init];
    viewController = [[UIViewController alloc] init];
    [window addSubview:[viewController view]];
    [window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)dealloc {
    [window release];
    [viewController release];
    [super dealloc];
}

@end
