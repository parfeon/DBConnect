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
    //[db evaluateUpdateWithParameters:@"SELECT * FROM sqlite3_master WHERE type='table' NOT LIKE 'sqlite_%@' %@ %lld, %lld, %lld, %@ , %@, %@, %@, %c, %d, %f, %lld, %lld, %lld;", @"hi", 1657687685465793, 1657687685465793, 1657687685465793, @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test", [NSNumber numberWithFloat:16.0f], 'a', 23, 35.7f, 1657687685465768, 1657687685465768, 16576876854657687];
    //[db evaluateUpdateWithParameters:@"SELECT * FROM sqlite3_master WHERE type='table' NOT LIKE 'sqlite_%@' %@ , %@, %@, %@;", [NSArray arrayWithObjects:@"hi", @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test123", nil]];
    //[db evaluateUpdateWithParameters:@"SELECT * FROM sqlite3_master WHERE type='table' NOT LIKE 'sqlite_%@' ?, ?, ?, ?2, ?;", @"hi", @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test123", @"test1234"];
    //[db evaluateUpdateWithParameters:@"SELECT * FROM sqlite3_master WHERE type='table' NOT LIKE 'sqlite_%@' ?, ?, ?, ?2, ?;", [NSArray arrayWithObjects:@"hi", @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test123", @"test1234", nil]];
    //[db evaluateUpdateWithParameters:@"SELECT * FROM sqlite3_master WHERE type='table' NOT LIKE 'sqlite_%@' ?1, ?6, ?3, ?4 , ?2, ?5;", @"hi", @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test123", @"test12345", @"test1234"];
    //[db evaluateUpdateWithParameters:@"SELECT * FROM sqlite3_master WHERE type='table' NOT LIKE 'sqlite_%@' ?1, ?6, ?3, ?4 , ?2, ?5;", [NSArray arrayWithObjects:@"hi", @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test123", @"test12345", @"test1234", nil]];
    [db evaluateUpdateWithParameters:@"SELECT * FROM sqlite3_master WHERE type='table' NOT LIKE 'sqlite_%@' @name2, @name41;", @"hi", @"name41",@"hidddd", @"name2", nil];
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
