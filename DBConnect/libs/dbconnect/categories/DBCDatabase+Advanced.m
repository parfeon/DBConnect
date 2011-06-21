/**
 *
 * Copyright (c) 2011 Sergey Mamontov
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "DBCDatabase+Advanced.h"
#import "DBCDatabase+Aliases.h"
#import "DBCMacro.h"

@implementation DBCDatabase (DBCDatabase_Advanced)

#pragma mark DBCDatabase instance initialization

/**
 * Open new database connection to sqlite database file at path, provided in init
 * Connection will be opened with flags passed to SQLite API
 * @parameters
 *      int flags        - database connection bit-field flags
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return whether database connection was opened with provided flags or not
 */
- (BOOL)openWithFlags:(int)flags error:(DBCError**)error {
    if(dbConnectionOpened) return dbConnectionOpened;
    dbFlags = flags;
    int resultCode = sqlite3_open_v2((dbPath==nil||[dbPath length]==0?NULL:[dbPath UTF8String]), &dbConnection, dbFlags, NULL);
    
    if(resultCode != SQLITE_OK){
        recentErrorCode = resultCode;
        *error = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:(inMemoryDB?@"in memory":dbPath)] retain];
        dbConnectionOpened = NO;
        DBCDebugLogger(@"[DBC:ERROR] %@", error);
        sqlite3_close(dbConnection);
    } else {
        sqlite3_busy_timeout(dbConnection, 250);
        [self setDatabaseEncoding:dbEncoding];
        dbConnectionOpened = YES;
    }
    return dbConnectionOpened;
}

#pragma mark SQLite database file pages

/**
 * Free unused database pages
 * WARNING: ROWID values may be reset
 * @return whether vacuum was successfull or not
 */
- (BOOL)freeUnusedPages {
    if(!dbConnectionOpened) return -1;
    if([self freePagesCountInDatabase:@"main"] == 0) return YES;
    return [self evaluateUpdate:@"VACUUM;" error:NULL, nil, nil];
}

/**
 * Get free pages count in database
 * @parameters
 *      NSString *databaseName - database name
 * @return free pages count in database
 */
- (int)freePagesCountInDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self evaluateQuery:[NSString stringWithFormat:@"PRAGMA %@.freelist_count;", databaseName], nil];
    if(result != nil) if([result count] > 0) return [[result rowAtIndex:0] intForColumn:@"freelist_count"];
    return -1;
}

/**
 * Get pages count in database (including unused)
 * @parameters
 *      NSString *databaseName - database name
 * @return pages count in database 
 */
- (int)pagesCountInDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self evaluateQuery:[NSString stringWithFormat:@"PRAGMA %@.page_count;", databaseName], nil];
    if(result != nil) if([result count] > 0) return [[result rowAtIndex:0] intForColumn:@"page_count"];
    return -1;
}

/**
 * Set page size in specified database
 * @parameters
 *      NSString *databaseName - database name
 *      int newPageSize        - new page size in bytes (must be a power of two)
 * WARNING: ROWID values may be reset
 * @return whether set was successfull or not
 */
- (BOOL)setPageSizeInDatabase:(NSString*)databaseName size:(int)newPageSize {
    if(!dbConnectionOpened) return NO;
    if(databaseName == nil) databaseName = @"main";
    return [self evaluateUpdate:[NSString stringWithFormat:@"PRAGMA %@.page_size = %i; VACUUM;", databaseName, newPageSize], nil];
}

/**
 * Get page size for specific database
 * @parameters
 *      NSString *databaseName - database name
 * @return page size for specific database
 */
- (int)pageSizeInDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self evaluateQuery:[NSString stringWithFormat:@"PRAGMA %@.page_size;", databaseName], nil];
    if(result != nil) if([result count] > 0) return [[result rowAtIndex:0] intForColumn:@"page_size"];
    return -1;
}

#pragma mark Database backup/restore

/**
 * Restore database from file into current database connection
 * @parameters
 *      NSString *dbFilePath - sqlite database file path
 * @retuen whether restore was successfull or not
 */
- (BOOL)restoreDatabaseFromFile:(NSString*)dbFilePath {
    return [self restoreDatabaseFromFile:dbFilePath database:nil];
}

/**
 * Restore database from file into provided database by it's name
 * @parameters
 *      NSString *dbFilePath   - sqlite database file path
 *      NSString *databaseName - target database
 * @retuen whether restore was successfull or not
 */
- (BOOL)restoreDatabaseFromFile:(NSString*)dbFilePath database:(NSString*)databaseName {
    if(!dbConnectionOpened) return NO;
    int resultCode = SQLITE_OK;
    DBCLockLogger(@"[DBC:Restore] Waiting for Lock (Line: %d)", __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:Restore] Lock acquired (Line: %d)", __LINE__);
    sqlite3 *sourceDBConnection = NULL;
    int retryCount = 0;
    BOOL shouldRetry = NO;
    do {
        shouldRetry = NO;
        resultCode = sqlite3_open_v2([dbFilePath UTF8String], &sourceDBConnection, SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE, NULL);
        if(resultCode == SQLITE_LOCKED || resultCode == SQLITE_BUSY){
            if(dbBusyRetryCount && retryCount < dbBusyRetryCount){
                shouldRetry = YES;
                sqlite3_sleep(150);
            } else {
                recentErrorCode = resultCode;
                DBCReleaseObject(recentError);
                recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                      additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                DBCDebugLogger(@"[DBC:Restore] Can't restore database due to error: %@", recentError);
                sqlite3_close(sourceDBConnection);
                sourceDBConnection = NULL;
                [queryLock unlock];
                DBCLockLogger(@"[DBC:Restore] Relinquished from previously acquired lock (Line: %d)", __LINE__);
                return NO;
            }
        }
    } while (shouldRetry);
    
    if (databaseName == nil) databaseName = @"main";
    sqlite3_backup *backup = sqlite3_backup_init(dbConnection, [databaseName UTF8String], sourceDBConnection, "main");
    if(backup){
        retryCount = 0;
        shouldRetry = NO;
        do {
            shouldRetry = NO;
            resultCode = sqlite3_backup_step(backup, -1);
            if(resultCode == SQLITE_LOCKED || resultCode == SQLITE_BUSY){
                shouldRetry = YES;
                sqlite3_sleep(150);
            } else {
                sqlite3_backup_finish(backup);
                recentErrorCode = resultCode;
                DBCReleaseObject(recentError);
                recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                      additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                DBCDebugLogger(@"[DBC:Restore] Can't restore database due to error: %@", recentError);
                sqlite3_close(sourceDBConnection);
                sourceDBConnection = NULL;
                [queryLock unlock];
                DBCLockLogger(@"[DBC:Restore] Relinquished from previously acquired lock (Line: %d)", __LINE__);
                return NO;
            }
        } while (shouldRetry);
        sqlite3_backup_finish(backup);
    }
    sqlite3_close(sourceDBConnection);
    sourceDBConnection = NULL;
    [queryLock unlock];
    DBCLockLogger(@"[DBC:Restore] Relinquished from previously acquired lock (Line: %d)", __LINE__);
    return resultCode==SQLITE_OK;
}


/**
 * Backup database to file from current database connection
 * @parameters
 *      NSString *dbFileStorePath - sqlite database store file path
 * @retuen whether backup was successfull or not
 */
- (BOOL)backupDatabaseToFile:(NSString*)dbFileStorePath {
    return [self backupDatabaseToFile:dbFileStorePath fromDatabase:nil];
}

/**
 * Backup database to file from provided database by it's name
 * @parameters
 *      NSString *dbFilePath   - sqlite database store file path
 *      NSString *databaseName - target database
 * @retuen whether backup was successfull or not
 */
- (BOOL)backupDatabaseToFile:(NSString*)dbFileStorePath fromDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return NO;
    int resultCode = SQLITE_OK;
    DBCLockLogger(@"[DBC:Backup] Waiting for Lock (Line: %d)", __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:Backup] Lock acquired (Line: %d)", __LINE__);
    sqlite3 *sourceDBConnection = NULL;
    int retryCount = 0;
    BOOL shouldRetry = NO;
    do {
        shouldRetry = NO;
        resultCode = sqlite3_open_v2([dbFileStorePath UTF8String], &sourceDBConnection, SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE, NULL);
        if(resultCode == SQLITE_LOCKED || resultCode == SQLITE_BUSY){
            if(dbBusyRetryCount && retryCount < dbBusyRetryCount){
                shouldRetry = YES;
                sqlite3_sleep(150);
            } else {
                recentErrorCode = resultCode;
                DBCReleaseObject(recentError);
                recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                      additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                DBCDebugLogger(@"[DBC:Backup] Can't restore database due to error: %@", recentError);
                sqlite3_close(sourceDBConnection);
                sourceDBConnection = NULL;
                [queryLock unlock];
                DBCLockLogger(@"[DBC:Backup] Relinquished from previously acquired lock (Line: %d)", __LINE__);
                return NO;
            }
        }
    } while (shouldRetry);
    
    if (databaseName == nil) databaseName = @"main";
    sqlite3_backup *backup = sqlite3_backup_init(dbConnection, [databaseName UTF8String], sourceDBConnection, "main");
    if(backup){
        do {
            shouldRetry = NO;
            resultCode = sqlite3_backup_step(backup, 5);
            if(resultCode == SQLITE_OK || resultCode == SQLITE_LOCKED || resultCode == SQLITE_BUSY){
                sqlite3_sleep(250);
            }
        } while (resultCode==SQLITE_OK || resultCode==SQLITE_BUSY || resultCode==SQLITE_LOCKED);
        sqlite3_backup_finish(backup);
    }
    sqlite3_close(sourceDBConnection);
    sourceDBConnection = NULL;
    [queryLock unlock];
    DBCLockLogger(@"[DBC:Backup] Relinquished from previously acquired lock (Line: %d)", __LINE__);
    return resultCode==SQLITE_OK;
}

#pragma mark Transaction journal

/**
 * Turn off transaction journaling for current database connection
 * @return whether journaling turned off on current database connection or not
 */
- (BOOL)turnOffJournaling {
    return [self setJournalMode:DBCDatabaseJournalingModeOff];
}

/**
 * Turn off transaction journaling for specified database connection
 * @parameters
 *      NSString *databaseName - target database name
 * @return whether journaling turned off on current database connection or not
 */
- (BOOL)turnOffJournalingForDatabase:(NSString*)databaseName {
    return [self setJournalMode:DBCDatabaseJournalingModeOff forDatabase:databaseName];
}

/**
 * Turn on transaction journaling for current database connection
 * @return whether journaling turned on on current database connection or not
 */
- (BOOL)turnOnJournaling {
    return [self setJournalMode:DBCDatabaseJournalingModeDelete];
}

/**
 * Turn on transaction journaling for specified database connection
 * @parameters
 *      NSString *databaseName - target database name
 * @return whether journaling turned on on current database connection or not
 */
- (BOOL)turnOnJournalingForDatabase:(NSString*)databaseName {
    return [self setJournalMode:DBCDatabaseJournalingModeDelete forDatabase:databaseName];
}

/**
 * Set new journal mode for current database connection and any newly attached 
 * databases
 * @parameters
 *      NSString *journalMode - new journalig mode
 * @return whether set was successfull or not
 */
- (BOOL)setJournalMode:(DBCDatabaseJournalingMode)journalMode {
    if(!dbConnectionOpened) return NO;
    NSArray *allowedModes = [NSArray arrayWithObjects:@"delete", @"truncate", @"persist", @"memory", @"off", nil];
    if((int)journalMode < 0 || (int)journalMode >= [allowedModes count]) return NO;
    return [self evaluateUpdate:[NSString stringWithFormat:@"PRAGMA journal_mode = %@;", [allowedModes objectAtIndex:journalMode]], nil];
}

/**
 * Get current database connection journaling mode
 * @return journaling mode for current database connection
 */
- (DBCDatabaseJournalingMode)journalMode {
    if(!dbConnectionOpened) return -1;
    NSArray *allowedModes = [NSArray arrayWithObjects:@"delete", @"truncate", @"persist", @"memory", @"off", nil];
    DBCDatabaseResult *result = [self evaluateQuery:@"PRAGMA journal_mode;", nil];
    if([result count] > 0){
        return [allowedModes indexOfObject:[[[result rowAtIndex:0] stringForColumn:@"journal_mode"] lowercaseString]];
    }
    return -1;
}

/**
 * Set new journal mode for specified database
 * @parameters
 *      NSString *journalMode  - new journalig mode
 *      NSString *databaseName - target database name
 * @return whether set was successfull or not
 */
- (BOOL)setJournalMode:(DBCDatabaseJournalingMode)journalMode forDatabase:(NSString*)databaseName {
    NSArray *allowedModes = [NSArray arrayWithObjects:@"delete", @"truncate", @"persist", @"memory", @"off", nil];
    if((int)journalMode < 0 || (int)journalMode >= [allowedModes count]) return NO;
    return [self evaluateUpdate:[NSString stringWithFormat:@"PRAGMA %@.journal_mode = %@;", databaseName, [allowedModes objectAtIndex:journalMode]], nil];
}

/**
 * Get specified database connection journaling mode
 * @parameters
 *      NSString *databaseName - target database name
 * @return journaling mode for specified database connection
 */
- (DBCDatabaseJournalingMode)journalModeForDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    NSArray *allowedModes = [NSArray arrayWithObjects:@"delete", @"truncate", @"persist", @"memory", @"off", nil];
    DBCDatabaseResult *result = [self evaluateQuery:[NSString stringWithFormat:@"PRAGMA %@.journal_mode;", databaseName], nil];
    if([result count] > 0){
        return [allowedModes indexOfObject:[[[result rowAtIndex:0] stringForColumn:@"journal_mode"] lowercaseString]];
    }
    return -1;
}

/**
 * Set default journal size limit for specified database
 * @parameters
 *      NSString *databaseName            - target database name
 *      long long int newJournalSizeLimit - new journal size in bytes
 * @return whether set was successfull or not
 */
- (BOOL)setJournalSizeLimitForDatabase:(NSString*)databaseName size:(long long int)newJournalSizeLimit {
    if(!dbConnectionOpened) return NO;
    if(databaseName == nil) databaseName = @"main";
    return [self evaluateUpdate:[NSString stringWithFormat:@"PRAGMA %@.journal_size_limit = %lld;", databaseName, newJournalSizeLimit], nil];
}

/**
 * Get journal size for specified database
 * @parameters
 *      NSString *databaseName - target database name
 * @return journal size in bytes for specified database
 */
- (long long int)journalSizeLimitForDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self evaluateQuery:[NSString stringWithFormat:@"PRAGMA %@.journal_size_limit;", databaseName], nil];
    if(result != nil && [result count] > 0){
        return [[result rowAtIndex:0] longLongForColumn:@"journal_size_limit"];
    }
    return -1;
}

#pragma mark Database locking

/**
 * Set default locking mode for current cdatabase connection and any newly 
 * attached databases
 * @parameters
 *      DBCDatabaseLockingMode lockingMode - new locking mode
 * @return whether set was successfull or not
 */
- (BOOL)setLockingMode:(DBCDatabaseLockingMode)lockingMode {
    if(!dbConnectionOpened) return NO;
    NSArray *allowedModes = [NSArray arrayWithObjects:@"normal", @"exclusive", nil];
    if((int)lockingMode < 0 || (int)lockingMode >= [allowedModes count]) return NO;
    return [self evaluateUpdate:[NSString stringWithFormat:@"PRAGMA locking_mode = %@;", [allowedModes objectAtIndex:lockingMode]], nil];
}

/**
 * Get current database connection locking mode
 * @return current database connection locking mode
 */
- (DBCDatabaseLockingMode)lockingMode {
    if(!dbConnectionOpened) return -1;
    NSArray *allowedModes = [NSArray arrayWithObjects:@"normal", @"exclusive", nil];
    DBCDatabaseResult *result = [self evaluateQuery:@"PRAGMA locking_mode;", nil];
    if([result count] > 0){
        return [allowedModes indexOfObject:[[[result rowAtIndex:0] stringForColumn:@"locking_mode"] lowercaseString]];
    }
    return -1;
}

/**
 * Set default locking mode for specified database name
 * attached databases
 * @parameters
 *      NSString *databaseName             - target database name
 *      DBCDatabaseLockingMode lockingMode - new locking mode
 * @return whether set was successfull or not
 */
- (BOOL)setLockingMode:(DBCDatabaseLockingMode)lockingMode forDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return NO;
    if(databaseName == nil) databaseName = @"main";
    NSArray *allowedModes = [NSArray arrayWithObjects:@"normal", @"exclusive", nil];
    if((int)lockingMode < 0 || (int)lockingMode >= [allowedModes count]) return NO;
    return [self evaluateUpdate:[NSString stringWithFormat:@"PRAGMA %@.locking_mode = %@;", 
                                 databaseName, [allowedModes objectAtIndex:lockingMode]], nil];
}

/**
 * Get specified database locking mode
 * @parameters
 *      NSString *databaseName - target database name
 * @return specified database locking mode
 */
- (DBCDatabaseLockingMode)lockingModeForDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    NSArray *allowedModes = [NSArray arrayWithObjects:@"normal", @"exclusive", nil];
    DBCDatabaseResult *result = [self evaluateQuery:[NSString stringWithFormat:@"PRAGMA %@.locking_mode;", databaseName], nil];
    if([result count] > 0){
        return [allowedModes indexOfObject:[[[result rowAtIndex:0] stringForColumn:@"locking_mode"] lowercaseString]];
    }
    return -1;
}

/**
 * Set maximum pages count
 * @parameters
 *      NSString *databaseName    - target database name
 *      long long int newPageSize - new maximum pages count
 * @return whether set was successfull or not
 */
- (BOOL)setMaximumPageCountForDatabase:(NSString*)databaseName size:(int)newPageCount {
    if(!dbConnectionOpened) return NO;
    if(databaseName == nil) databaseName = @"main";
    if(newPageCount > 1073741823 || newPageCount < 0) return NO;
    return [self evaluateUpdate:[NSString stringWithFormat:@"PRAGMA %@.max_page_count = %d;", databaseName, newPageCount], nil];
}

/**
 * Reset maximum pages count for spicified database to it's default value
 * @parameters
 *      NSString *databaseName    - target database name
 * @return whether set was successfull or not
 */
- (BOOL)resetMaximumPageCountForDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return NO;
    if(databaseName == nil) databaseName = @"main";
    return [self evaluateUpdate:[NSString stringWithFormat:@"PRAGMA %@.max_page_count = 1073741823;", databaseName], nil];
}

/**
 * Get maximum pages count for specified database
 * @parameters
 *      NSString *databaseName    - target database name
 * @return maximum pages count for specified database
 */
- (int)maximumPageCountForDatabase:(NSString*)databaseName {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self evaluateQuery:[NSString stringWithFormat:@"PRAGMA %@.max_page_count;", databaseName], nil];
    if([result count] > 0){
        return [[result rowAtIndex:0] intForColumn:@"max_page_count"];
    }
    return -1;
}

/**
 * Set read locks state 
 * @parameters
 *      BOOL omit - should omit read lock or not
 * @return whether set was successfull or not
 */
- (BOOL)setOmitReadlockLike:(BOOL)omit {
    if(!dbConnectionOpened) return NO;
    return [self evaluateUpdate:@"PRAGMA omit_readlock = %d;", (omit?1:0), nil];
}

/**
 * Get whether omit read lock flag or not
 * @return whether omit read lock flag or not
 */
- (BOOL)omitReadlock {
    if(!dbConnectionOpened) return NO;
    DBCDatabaseResult *result = [self evaluateQuery:@"PRAGMA max_page_count;", nil];
    if([result count] > 0){
        return [[result rowAtIndex:0] intForColumn:@"omit_readlock"]==1;
    }
    return NO;
}

#pragma mark Database virtual table (module) registration

/**
 * Register virtual table (module)
 * @parameters
 *      const sqlite3_module* module   - SQL virtual table structure
 *      NSString *moduleName           - module name
 *      void *userData                 - user data passed to module
 *      void(*)(void*) cleanupFunction - cleanup function which used to free retained resources
 *  @return return code which indicate was module registered or not
 */
- (int)registerModule:(const sqlite3_module*)module moduleName:(NSString*)moduleName userData:(void*)userData cleanupFunction:(void(*)(void*))cleanupFunction {
    int returnCode = SQLITE_ERROR;
    if(!dbConnectionOpened) return returnCode;
    if(cleanupFunction != NULL) returnCode = sqlite3_create_module_v2(dbConnection, [moduleName UTF8String], module, userData, cleanupFunction);
    returnCode = sqlite3_create_module(dbConnection, [moduleName UTF8String], module, userData);
    return returnCode;
}

#pragma mark Database functions registration/unregistration

/**
 * Register scalar function
 * @parameters
 *      void(*)(sqlite3_context*, int, sqlite3_value) function - registered function with defined
 *                                                               signature
 *      NSString* fnName                                       - registered function name
 *      int fnParametersCount                                  - count of parameters, expected in
 *                                                               SQL function
 *      int expectedTextValueRepresentation                    - expected passed text value representation
 *                                                               SQLITE_UTF8, SQLITE_UTF16, SQLITE_UTF16BE, 
 *                                                               SQLITE_UTF16LE, or SQLITE_ANY
 *      void *fnUserData                                       - user data which will be passed to C function
 *  @return return code which indicate was function registered or not
 */
- (int)registerScalarFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))function functionName:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData {
    int returnCode = SQLITE_ERROR;
    if(!dbConnectionOpened) return returnCode;
    if(expectedTextValueRepresentation==SQLITE_UTF8||expectedTextValueRepresentation==SQLITE_ANY){
        returnCode = sqlite3_create_function(dbConnection, [fnName UTF8String], fnParametersCount, expectedTextValueRepresentation, fnUserData, function, NULL, NULL);
    } else if(expectedTextValueRepresentation==SQLITE_UTF16||expectedTextValueRepresentation==SQLITE_UTF16BE||
              expectedTextValueRepresentation==SQLITE_UTF16LE){
        returnCode = sqlite3_create_function16(dbConnection, [fnName cStringUsingEncoding:NSUTF16StringEncoding], fnParametersCount, expectedTextValueRepresentation, fnUserData, function, NULL, NULL);
    }
    return returnCode;
}

/**
 * Unregister scalar function. Should be used same function parameteres, which was used to register it
 * @parameters
 *      NSString* fnName                                       - registered function name
 *      int fnParametersCount                                  - count of parameters, expected in
 *                                                               SQL function
 *      int expectedTextValueRepresentation                    - expected passed text value representation
 *                                                               SQLITE_UTF8, SQLITE_UTF16, SQLITE_UTF16BE, 
 *                                                               SQLITE_UTF16LE, or SQLITE_ANY
 *  @return return code which indicate was function unregistered or not
 */
- (int)unRegisterScalarFunction:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation {
    int returnCode = SQLITE_ERROR;
    if(expectedTextValueRepresentation==SQLITE_UTF8||expectedTextValueRepresentation==SQLITE_ANY){
        returnCode = sqlite3_create_function(dbConnection, [fnName UTF8String], fnParametersCount, expectedTextValueRepresentation, NULL, NULL, NULL, NULL);
    } else if(expectedTextValueRepresentation==SQLITE_UTF16||expectedTextValueRepresentation==SQLITE_UTF16BE||
              expectedTextValueRepresentation==SQLITE_UTF16LE){
        returnCode = sqlite3_create_function16(dbConnection, [fnName cStringUsingEncoding:NSUTF16StringEncoding], fnParametersCount, expectedTextValueRepresentation, NULL, NULL, NULL, NULL);
    }
    return returnCode;
}

/**
 * Register aggregation function
 * @parameters
 *      void(*)(sqlite3_context*, int, sqlite3_value) stepFunction - registered step function with defined
 *                                                                   signature
 *      void(*)(sqlite3_context*) finalyzeFunction                 - registered finalyzed function with defined
 *                                                                   signature
 *      NSString* fnName                                           - registered function name
 *      int fnParametersCount                                      - count of parameters, expected in
 *                                                                   SQL function
 *      int expectedTextValueRepresentation                        - expected passed text value representation
 *                                                                   SQLITE_UTF8, SQLITE_UTF16, SQLITE_UTF16BE, 
 *                                                                   SQLITE_UTF16LE, or SQLITE_ANY
 *      void *fnUserData                                           - user data which will be passed to C function
 *  @return return code which indicate was function registered or not
 */
- (int)registerAggregationFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))stepFunction finalyzeFunction:(void(*)(sqlite3_context*))finalyzeFunction functionName:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData {
    int returnCode = SQLITE_ERROR;
    if(!dbConnectionOpened) return returnCode;
    if(expectedTextValueRepresentation==SQLITE_UTF8||expectedTextValueRepresentation==SQLITE_ANY){
        returnCode = sqlite3_create_function(dbConnection, [fnName UTF8String], fnParametersCount, expectedTextValueRepresentation, fnUserData, NULL, stepFunction, finalyzeFunction);
    } else if(expectedTextValueRepresentation==SQLITE_UTF16||expectedTextValueRepresentation==SQLITE_UTF16BE||
              expectedTextValueRepresentation==SQLITE_UTF16LE){
        returnCode = sqlite3_create_function16(dbConnection, [fnName cStringUsingEncoding:NSUTF16StringEncoding], fnParametersCount, expectedTextValueRepresentation, fnUserData, NULL, stepFunction, finalyzeFunction);
    }
    return returnCode;
}

/**
 * Unregister aggregation function. Should be used same function parameteres, which was used to register it
 * @parameters
 *      NSString* fnName                                       - registered function name
 *      int fnParametersCount                                  - count of parameters, expected in
 *                                                               SQL function
 *      int expectedTextValueRepresentation                    - expected passed text value representation
 *                                                               SQLITE_UTF8, SQLITE_UTF16, SQLITE_UTF16BE, 
 *                                                               SQLITE_UTF16LE, or SQLITE_ANY
 *  @return return code which indicate was function unregistered or not
 */
- (int)unRegisterAggregationFunction:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation {
    int returnCode = SQLITE_ERROR;
    if(expectedTextValueRepresentation==SQLITE_UTF8||expectedTextValueRepresentation==SQLITE_ANY){
        returnCode = sqlite3_create_function(dbConnection, [fnName UTF8String], fnParametersCount, expectedTextValueRepresentation, NULL, NULL, NULL, NULL);
    } else if(expectedTextValueRepresentation==SQLITE_UTF16||expectedTextValueRepresentation==SQLITE_UTF16BE||
              expectedTextValueRepresentation==SQLITE_UTF16LE){
        returnCode = sqlite3_create_function16(dbConnection, [fnName cStringUsingEncoding:NSUTF16StringEncoding], fnParametersCount, expectedTextValueRepresentation, NULL, NULL, NULL, NULL);
    }
    return returnCode;
}

/**
 * Register collation function
 * @parameters
 *      void(*)(sqlite3_context*, int, sqlite3_value) function - registered function with defined
 *                                                               signature
 *      NSString* fnName                                       - registered function name
 *      int expectedTextValueRepresentation                    - expected passed text value representation
 *                                                               SQLITE_UTF8, SQLITE_UTF16, SQLITE_UTF16BE, 
 *                                                               SQLITE_UTF16LE, SQLITE_UTF16_ALIGNED, or SQLITE_ANY
 *      void *fnUserData                                       - user data which will be passed to C function
 *  @return return code which indicate was function registered or not
 */
- (int)registerCollationFunction:(int(*)(void*, int, const void*, int, const void*))function cleanupFunction:(void(*)(void*))cleanupFunction functionName:(NSString*)fnName textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData {
    int returnCode = SQLITE_ERROR;
    if(!dbConnectionOpened) return returnCode;
    if(cleanupFunction!=NULL){
        returnCode = sqlite3_create_collation_v2(dbConnection, [fnName UTF8String], expectedTextValueRepresentation, fnUserData, function, cleanupFunction);
    } else {
        if(expectedTextValueRepresentation==SQLITE_UTF8||expectedTextValueRepresentation==SQLITE_ANY){
            returnCode = sqlite3_create_collation(dbConnection, [fnName UTF8String], expectedTextValueRepresentation, fnUserData, function);
        } else if(expectedTextValueRepresentation==SQLITE_UTF16||expectedTextValueRepresentation==SQLITE_UTF16BE||
                  expectedTextValueRepresentation==SQLITE_UTF16LE){
            returnCode = sqlite3_create_collation16(dbConnection, [fnName cStringUsingEncoding:NSUTF16StringEncoding], expectedTextValueRepresentation, fnUserData, function);
        }
    }
    return returnCode;
}

/**
 * Unregister collation function. Should be used same function parameteres, which was used to register it
 * @parameters
 *      NSString* fnName                                       - registered function name
 *      int expectedTextValueRepresentation                    - expected passed text value representation
 *                                                               SQLITE_UTF8, SQLITE_UTF16, SQLITE_UTF16BE, 
 *                                                               SQLITE_UTF16LE, SQLITE_UTF16_ALIGNED, or SQLITE_ANY
 *  @return return code which indicate was function unregistered or not
 */
- (int)unRegisterCollationFunction:(NSString*)fnName textValueRepresentation:(int)expectedTextValueRepresentation {
    int returnCode = SQLITE_ERROR;
    returnCode = sqlite3_create_collation_v2(dbConnection, [fnName UTF8String], expectedTextValueRepresentation, NULL, NULL, NULL);
    if(returnCode != SQLITE_OK){
        if(expectedTextValueRepresentation==SQLITE_UTF8||expectedTextValueRepresentation==SQLITE_ANY){
            returnCode = sqlite3_create_collation(dbConnection, [fnName UTF8String], expectedTextValueRepresentation, NULL, NULL);
        } else if(expectedTextValueRepresentation==SQLITE_UTF16||expectedTextValueRepresentation==SQLITE_UTF16BE||
                  expectedTextValueRepresentation==SQLITE_UTF16LE){
            returnCode = sqlite3_create_collation16(dbConnection, [fnName cStringUsingEncoding:NSUTF16StringEncoding], expectedTextValueRepresentation, NULL, NULL);
        }
    }
    return returnCode;
}

@end
