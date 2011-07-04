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
    DBCError *error = nil;
    NSString *docDir = nil;
    DBCDatabase *db = [DBCDatabase databaseWithPath:@":memory:"];
    if([db openError:&error]){
        error = nil;
        [db executeUpdate:@"DROP TABLE IF EXISTS test; CREATE TABLE IF NOT EXISTS test (pid INTEGER NOT NULL PRIMARY KEY \
AUTOINCREMENT, pType TEXT NOT NULL, pTitle TEXT, loc_lat FLOAT NOT NULL, loc_lon FLOAT NOT NULL); CREATE UNIQUE INDEX \
locationIndex ON test (loc_lat, loc_lon); INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?2, ?3, ?4 ); \
INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?5, ?6, ?7 ); INSERT INTO test (pType, pTitle, loc_lat, \
loc_lon) VALUES ( ?1, ?8, ?9, ?10 ); INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?11, ?12, ?13 );"
                     error:&error, 
                           @"City", @"Cupertino", [NSNumber numberWithFloat:37.3261f],
                           [NSNumber numberWithFloat:-122.0320f], @"New York", [NSNumber numberWithFloat:40.724],
                           [NSNumber numberWithFloat:-74.006], @"Dnepropetrovsk", [NSNumber numberWithFloat:48.472],
                           [NSNumber numberWithFloat:35.050], @"Kiev", [NSNumber numberWithFloat:50.457],
                           [NSNumber numberWithFloat:30.525],
         nil];
        if(error != nil){
            // Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag for 
            // DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.
            NSLog(@"Occurred an error: %@", error);
        }
        NSError *fmError = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        if (![fileManager fileExistsAtPath:[docDir stringByAppendingPathComponent:@"test.sqlite"]]) {
            [fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"sqlite"] 
                                 toPath:[docDir stringByAppendingPathComponent:@"test.sqlite"] error:&fmError];
        }
        [db attachDatabase:[docDir stringByAppendingPathComponent:@"test.sqlite"] databaseAttachName:@"aTest" 
                     error:&error];
        if(error != nil){
            // Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag for 
            // DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.
            NSLog(@"Occurred an error: %@", error);
        }
    } else {
        // In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag for 
        //DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.  
        NSLog(@"Occurred an error: %@", error);
    }
    error = nil;
    DBCDatabaseResult *result = [db executeQuery:@"SELECT * FROM test" error:&error, nil];
    if(error != nil){
        // In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
        NSLog(@"Occurred an error: %@", error);
    }
    NSLog(@"%@", [[result columnNames] componentsJoinedByString:@" | "]);
    for (DBCDatabaseRow *row in result) {
        NSLog(@"%@", row);
    }
    BOOL closed = [db closeError:&error];
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
