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
    DBCDatabase *db = [DBCDatabase databaseWithPath:@":memory:"];
    if([db openError:&error]){
        error = nil;
        [db executeUpdate:@"DROP TABLE IF EXISTS test; CREATE TABLE IF NOT EXISTS test (pid INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, pType TEXT NOT NULL, pTitle TEXT, loc_lat FLOAT NOT NULL, loc_lon FLOAT NOT NULL); CREATE UNIQUE INDEX locationIndex ON test (loc_lat, loc_lon); INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?2, ?3, ?4 ); INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?5, ?6, ?7 ); INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?8, ?9, ?10 ); INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?11, ?12, ?13 );"
                     error:&error, 
                           @"City", @"Cupertino", [NSNumber numberWithFloat:37.3261f],
                           [NSNumber numberWithFloat:-122.0320f], @"New York", [NSNumber numberWithFloat:40.724],
                           [NSNumber numberWithFloat:-74.006], @"Dnepropetrovsk", [NSNumber numberWithFloat:48.472],
                           [NSNumber numberWithFloat:35.050], @"Kiev", [NSNumber numberWithFloat:50.457],
                           [NSNumber numberWithFloat:30.525],
         nil];
        if(error != nil){
            // Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.
                NSLog(@"Occurred an error: %@", error);
        }
        //[db attachDatabase:@"test.sqlite" databaseAttachName:@"aTest" error:&error];
        NSError *fmError = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                            objectAtIndex:0];
        if (![fileManager fileExistsAtPath:[docDir stringByAppendingPathComponent:@"test.sqlite"]]) {
            [fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"sqlite"] 
                                 toPath:[docDir stringByAppendingPathComponent:@"test.sqlite"] error:&fmError];
        }
        [db attachDatabase:[docDir stringByAppendingPathComponent:@"test.sqlite"] databaseAttachName:@"aTest" 
                     error:&error];
        if(error != nil){
            // Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.
            NSLog(@"Occurred an error: %@", error);
        }
    } else {
        // In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.  
            NSLog(@"Occurred an error: %@", error);
    }
    //DBCDatabaseResult *result = [db executeQuery:@"SELECT * FROM test WHERE loc_lat > %d AND loc_lat < %d" error:&error, 37, 41, nil];
    //DBCDatabaseResult *result = [db executeQuery:@"SELECT * FROM aTest.test" error:&error, nil];
    error = nil;
    [db setUseCaseSensitiveLike:YES error:&error];
    DBCDatabaseResult *result = [db executeQuery:@"SELECT * FROM test WHERE pTitle LIKE ?1;" error:&error, @"cupertino", nil];
    /*NSLog(@"%@", [[result columnNames] componentsJoinedByString:@" | "]);
    for (DBCDatabaseRow *row in result) {
        NSLog(@"%@", row);
    }*/
    //NSLog(@"%@", result);
    //[db dropTable:@"test" inDatabase:nil error:&error];
    error = nil;
    NSArray *indicedColumnsList = [db indexedColumnsList:nil index:@"locationIndex" error:&error];
    if(error != nil){
        // In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
            NSLog(@"Occurred an error: %@", error);
    } else {
        for(DBCDatabaseIndexedColumnInfo *indexColInfo in indicedColumnsList) NSLog(@"%@", indexColInfo);
    }
    //NSLog(@"Columns information: %@", );
    if(error != nil){
        // Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.
        NSLog(@"Occurred an error: %@", error);
    }
    /*[db evaluateUpdate:@"INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( :placeType, @placeTitle, $placeLatitude, :placeLatitude );"
                 error:&error, [NSDictionary dictionaryWithObjectsAndKeys:@"City", @"placeType", @"Denver", @"placeTitle", [NSNumber numberWithFloat:40.2338f], @"placeLatitude", nil] , nil];*/
/*    [db evaluateUpdate:@"INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?2, ?3, ?3 );"
                 error:&error, @"City", @"Denver", [NSNumber numberWithFloat:40.2338f], nil];*/
    /*[db setUseCaseSensitiveLike:YES];
    [db evaluateUpdate:@"CREATE TABLE test (room_number INTEGER, building_number INTEGER, client_name TEXT, nullField NULL)" error:&error, nil];
    
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
    [db evaluateUpdate:@"SELECT * FROM sqlite_master WHERE type=?2; SELECT * FROM sqlite_master WHERE type=?1 NOT LIKE ?2;" error:&error, @"'table'", @"'sqlite3_%@'", nil];
    //[db rollbackTransaction];
    [db evaluateUpdate:@"INSERT INTO test (room_number, building_number, client_name) VALUES (?1, ?2, ?3)" error:&error, [NSNumber numberWithInt:1], [NSNumber numberWithInt:36], @"Bob", nil];
    [db evaluateUpdate:@"INSERT INTO test (room_number, building_number, client_name) VALUES (?1, ?2, ?3)" error:&error, @"Billy", [NSNumber numberWithInt:36], @"Bob", nil];
    [db evaluateQuery:@"SELECT * FROM test;" error:&error, nil];
    [db databasesList];
    int totalDatabasesTablesCount = [db tablesCount];
    int countInMain = [db tablesCountInDatabase:@"main"];
    NSLog(@"Overall count: %i, in main count: %i", totalDatabasesTablesCount, countInMain);
    [db setJournalSizeLimitForDatabase:nil size:(16*1024)];
    long long dbJournalSize = [db journalSizeLimitForDatabase:nil];
    NSLog(@"main database journal size %lld bytes", dbJournalSize);
    NSArray *tablesList = [db tablesList];
    NSLog(@"LIST OF TABLES: %@", tablesList);*/
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
