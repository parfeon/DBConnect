//
//  DBConnectAppDelegate.m
//  DBConnect
//
//  Created by Sergey Mamontov on 5/18/11.
//  Copyright 2011 Tattooed Orange. All rights reserved.
//

#import "DBConnectAppDelegate.h"
#import "DBCDatabase+Aliases.h"
#import "DBCDatabase+Advanced.h"
#import "DBCDatabase.h"

@implementation DBConnectAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    DBCDatabase *db = [[DBCDatabase alloc] initWithPath:@":memory:" defaultEncoding:DBCDatabaseEncodingUTF8];
    [db open];
    [db setUseCaseSensitiveLike:YES];
    [db evaluateUpdate:@"CREATE TABLE test (room_number INTEGER, building_number INTEGER, client_name TEXT, nullField NULL)", nil];
    
    //[db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type='table' NOT LIKE 'sqlite_%@' %@ %lld, %lld, %lld, %@ , %@, %@, %@, %c, %d, %f, %lld, %lld, %lld;", @"hi", 1657687685465793, 1657687685465793, 1657687685465793, @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test", [NSNumber numberWithFloat:16.0f], 'a', 23, 35.7f, 1657687685465768, 1657687685465768, 16576876854657687];
    //[db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type='table' NOT LIKE 'sqlite_%@' %@ %lld, %lld, %lld, %@ , %@, %@, %@, %c, %d, %f, %lld, %lld, %lld;", @"hi", 1657687685465793, 1657687685465793, 1657687685465793, @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test", [NSNumber numberWithFloat:16.0f], 'a', 23, 35.7f, 1657687685465768, 1657687685465768];
    //[db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type='table' NOT LIKE 'sqlite_%@' %@ , %@, %@, %@;", [NSArray arrayWithObjects:@"hi", @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test123", nil]];
    //[db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type='table' NOT LIKE 'sqlite_%@' ?, ?, ?, ?2, ?;", @"hi", @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test123", @"test1234"];
    //[db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type='table' NOT LIKE 'sqlite_%@' ?, ?, ?, ?, ?;", @"hi", @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test123", nil];
    //[db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type='table' NOT LIKE 'sqlite_%@' ?, ?, ?, ?2, ?;", [NSArray arrayWithObjects:@"hi", @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test123", @"test1234", nil]];
    //[db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type='table' NOT LIKE 'sqlite_%@' ?1, ?6, ?3, ?4 , ?2, ?5;", @"hi", @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test123", @"test12345", @"test1234"];
    //[db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type='table' NOT LIKE 'sqlite_%@' ?1, ?6, ?3, ?4 , ?2, ?5;", @"hi", @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test123", @"test12345", nil];
    //[db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type='table' NOT LIKE 'sqlite_%@';", nil];
    //[db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type='table' NOT LIKE 'sqlite_%@' ?1, ?6, ?3, ?4 , ?2, ?5;", [NSArray arrayWithObjects:@"hi", @"BOOOOO", [NSNumber numberWithFloat:116.0f], @"test123", @"test12345", @"test1234", nil]];
    //[db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type='table' NOT LIKE 'sqlite_%@' @name2, @name41;", @"hi", @"name41",@"hidddd", @"name2", nil];
    //[db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type='table' NOT LIKE 'sqlite_%@'", @"hi", @"name41",@"hidddd", @"name2", nil];
    [db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type=?2; SELECT * FROM sqlite_master WHERE type=?1 NOT LIKE ?2;", @"'table'", @"'sqlite3_%@'", nil];
    //[db rollbackTransaction];
    [db evaluateUpdate:@"INSERT INTO test (room_number, building_number, client_name) VALUES (?1, ?2, ?3)", [NSNumber numberWithInt:1], [NSNumber numberWithInt:36], @"Bob", nil];
    [db evaluateUpdate:@"INSERT INTO test (room_number, building_number, client_name) VALUES (?1, ?2, ?3)", @"Billy", [NSNumber numberWithInt:36], @"Bob", nil];
    [db evaluateQuery:@"SELECT * FROM test;", nil];
    [db databasesList];
    int totalDatabasesTablesCount = [db tablesCount];
    int countInMain = [db tablesCountInDatabase:@"main"];
    NSLog(@"Overall count: %i, in main count: %i", totalDatabasesTablesCount, countInMain);
    [db setJournalSizeLimitForDatabase:nil size:(16*1024)];
    long long dbJournalSize = [db journalSizeLimitForDatabase:nil];
    NSLog(@"main database journal size %lld bytes", dbJournalSize);
    NSArray *tablesList = [db tablesList];
    NSLog(@"LIST OF TABLES: %@", tablesList);
    BOOL closed = [db close];
    NSLog(@"DATABASE CLOSED? %@", closed?@"YES":@"NO");
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
