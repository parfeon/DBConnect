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
 *      DBCError **error - if an error occurs, upon return contains an DBCError  bject that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * @return whether database connection was opened with provided flags or not
 */
- (BOOL)openWithFlags:(int)flags error:(DBCError**)error {
    if(dbConnectionOpened) return dbConnectionOpened;
    dbFlags = flags;
    const char *targetDatabase = (dbPath==nil||[dbPath length]==0?NULL:[dbPath UTF8String]);
    int resultCode = sqlite3_open_v2(targetDatabase, &dbConnection, dbFlags, NULL);
    
    if(resultCode != SQLITE_OK){
        recentErrorCode = resultCode;
        *error = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:(inMemoryDB?@"in memory":dbPath)] retain];
        dbConnectionOpened = NO;
        DBCDebugLogger(@"[DBC:ERROR] %@", *error);
        sqlite3_close(dbConnection);
    } else {
        sqlite3_busy_timeout(dbConnection, 250);
        [self setDatabaseEncoding:dbEncoding error:error];
        dbConnectionOpened = YES;
    }
    return dbConnectionOpened;
}

#pragma mark SQLite database file pages

/**
 * Free unused database pages
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * WARNING: ROWID values may be reset
 * @return whether vacuum was successfull or not
 */
- (BOOL)freeUnusedPagesError:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    if([self freePagesCountInDatabase:@"main" error:error] == 0) return YES;
    if(inMemoryDB) return YES;
    return [self executeUpdate:@"VACUUM;" error:error, nil, nil];
}

/**
 * Get free pages count in database
 * @parameters
 *      NSString *databaseName - database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return free pages count in database
 */
- (int)freePagesCountInDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self executeQuery:[NSString stringWithFormat:@"PRAGMA %@.freelist_count;", databaseName] error:error, nil];
    if(result != nil) if([result count] > 0) return [[result rowAtIndex:0] intForColumn:@"freelist_count"];
    return -1;
}

/**
 * Get pages count in database (including unused)
 * @parameters
 *      NSString *databaseName - database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return pages count in database 
 */
- (int)pagesCountInDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self executeQuery:[NSString stringWithFormat:@"PRAGMA %@.page_count;", databaseName] error:error, nil];
    if(result != nil) if([result count] > 0) return [[result rowAtIndex:0] intForColumn:@"page_count"];
    return -1;
}

/**
 * Set page size in specified database
 * @parameters
 *      NSString *databaseName - database name
 *      int newPageSize        - new page size in bytes (must be a power of two)
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * WARNING: ROWID values may be reset
 * @return whether set was successfull or not
 */
- (BOOL)setPageSizeInDatabase:(NSString*)databaseName size:(int)newPageSize error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    if(databaseName == nil) databaseName = @"main";
    if(inMemoryDB) [self executeUpdate:[NSString stringWithFormat:@"PRAGMA %@.page_size = %i;", databaseName, newPageSize] error:error, nil];
    return [self executeUpdate:[NSString stringWithFormat:@"PRAGMA %@.page_size = %i; VACUUM;", databaseName, newPageSize] error:error, nil];
}

/**
 * Get page size for specific database
 * @parameters
 *      NSString *databaseName - database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return page size for specific database
 */
- (int)pageSizeInDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self executeQuery:[NSString stringWithFormat:@"PRAGMA %@.page_size;", databaseName] error:error, nil];
    if(result != nil) if([result count] > 0) return [[result rowAtIndex:0] intForColumn:@"page_size"];
    return -1;
}

/**
 * Set maximum pages count
 * @parameters
 *      NSString *databaseName    - target database name
 *      long long int newPageSize - new maximum pages count
 *      DBCError **error          - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                                  Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setMaximumPageCountForDatabase:(NSString*)databaseName size:(int)newPageCount error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    if(databaseName == nil) databaseName = @"main";
    if(newPageCount > 1073741823 || newPageCount < 0) return NO;
    return [self executeUpdate:[NSString stringWithFormat:@"PRAGMA %@.max_page_count = %d;", databaseName, newPageCount] error:error, nil];
}

/**
 * Reset maximum pages count for spicified database to it's default value
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)resetMaximumPageCountForDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    if(databaseName == nil) databaseName = @"main";
    return [self executeUpdate:[NSString stringWithFormat:@"PRAGMA %@.max_page_count = 1073741823;", databaseName] error:error, nil];
}

/**
 * Get maximum pages count for specified database
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return maximum pages count for specified database
 */
- (int)maximumPageCountForDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self executeQuery:[NSString stringWithFormat:@"PRAGMA %@.max_page_count;", databaseName] error:error, nil];
    if([result count] > 0){
        return [[result rowAtIndex:0] intForColumn:@"max_page_count"];
    }
    return -1;
}

#pragma mark Database backup/restore

/**
 * Restore destination database from current connection with source database file and specified source database name
 * @parameters
 *      NSString *dstDatabaseName - destination database name in current database connection for restore
 *      NSString *srcDatabaseFile - source database file from which database restore will be performed
 *      NSString *srcDatabaseName - source database name, which will be used to restore destination database
 *      DBCError **error          - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                                  Pass NULL if you do not want error information.
 * @return whether restore was successfull or not
 */
- (BOOL)restore:(NSString*)dstDatabaseName fromFile:(NSString*)srcDatabaseFile database:(NSString*)srcDatabaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    int resultCode = SQLITE_OK;
    DBCLockLogger(@"[DBC:Restore] Waiting for Lock (Line: %d)", __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:Restore] Lock acquired (Line: %d)", __LINE__);
    sqlite3 *sourceDBConnection = NULL;
    int retryCount = 0;
    BOOL shouldRetry = NO;
    const char *targetDatabase = (srcDatabaseFile==nil||[srcDatabaseFile length]==0?NULL:[srcDatabaseFile UTF8String]);
    do {
        shouldRetry = NO;
        resultCode = sqlite3_open_v2(targetDatabase, &sourceDBConnection, SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE, NULL);
        if(resultCode == SQLITE_LOCKED || resultCode == SQLITE_BUSY){
            if(executionRetryCount && retryCount < executionRetryCount){
                shouldRetry = YES;
                sqlite3_sleep(150);
            } else {
                recentErrorCode = resultCode;
                *error = [DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)];
                DBCDebugLogger(@"[DBC:Restore] Can't restore database due to error: %@", *error);
                sqlite3_close(sourceDBConnection);
                sourceDBConnection = NULL;
                [queryLock unlock];
                DBCLockLogger(@"[DBC:Restore] Relinquished from previously acquired lock (Line: %d)", __LINE__);
                return NO;
            }
        }
    } while (shouldRetry);
    
    BOOL restoreSuccessfull = [self restore:dstDatabaseName from:sourceDBConnection database:srcDatabaseName error:error];
    
    sqlite3_close(sourceDBConnection);
    sourceDBConnection = NULL;
    [queryLock unlock];
    DBCLockLogger(@"[DBC:Restore] Relinquished from previously acquired lock (Line: %d)", __LINE__);
    
    return restoreSuccessfull;
}

/**
 * Restore destination database from current connection with source database connection and specified source database name
 * @parameters
 *      NSString *dstDatabaseName       - destination database name in current database connection for restore
 *      NSString *srcDatabaseConnection - source database connection from which database restore will be performed
 *      NSString *srcDatabaseName       - source database name, which will be used to restore destination database
 *      DBCError **error                - if an error occurs, upon return contains an DBCError object that describes the 
 *                                        problem. Pass NULL if you do not want error information.
 * @return whether restore was successfull or not
 */
- (BOOL)restore:(NSString*)dstDatabaseName from:(sqlite3*)srcDatabaseConnection database:(NSString*)srcDatabaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    int resultCode = SQLITE_OK;
    DBCLockLogger(@"[DBC:Restore] Waiting for Lock (Line: %d)", __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:Restore] Lock acquired (Line: %d)", __LINE__);
    int retryCount = 0;
    BOOL shouldRetry = NO;
    
    int sourcePageSize = -1;
    sqlite3_stmt *sourcePageSizeStatement = NULL;
    const char *sourcePageSizeSQL =  [[NSString stringWithFormat:@"PRAGMA %@.page_size;", srcDatabaseName] UTF8String];
    do {
        shouldRetry = NO;
        resultCode = sqlite3_prepare_v2(srcDatabaseConnection, sourcePageSizeSQL, -1, &sourcePageSizeStatement, NULL);
        if(resultCode == SQLITE_LOCKED || resultCode == SQLITE_BUSY){
            if(executionRetryCount && retryCount++ < executionRetryCount){
                shouldRetry = YES;
                sqlite3_sleep(150);
            }
        }
    } while (shouldRetry);
    if(resultCode == SQLITE_OK){
        do {
            shouldRetry = NO;
            resultCode = sqlite3_step(sourcePageSizeStatement);
            if(resultCode == SQLITE_LOCKED || resultCode == SQLITE_BUSY){
                if(executionRetryCount && retryCount++ < executionRetryCount){
                    shouldRetry = YES;
                    sqlite3_sleep(150);
                }
            } else if(resultCode == SQLITE_ROW) sourcePageSize = sqlite3_column_int(sourcePageSizeStatement, 0);
        } while (shouldRetry);
    }
    if(sourcePageSize > 0) {
        int destinationPageSize = [self pageSizeInDatabase:dstDatabaseName error:NULL];
        if(sourcePageSize != destinationPageSize && destinationPageSize > 0)
            [self setPageSizeInDatabase:dstDatabaseName size:sourcePageSize error:NULL];
    }
    
    if (dstDatabaseName == nil) dstDatabaseName = @"main";
    if (srcDatabaseName == nil) srcDatabaseName = @"main";
    sqlite3_backup *backup = sqlite3_backup_init(dbConnection, [dstDatabaseName UTF8String], srcDatabaseConnection, [srcDatabaseName UTF8String]);
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
                *error = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                      additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                DBCDebugLogger(@"[DBC:Restore] Can't restore database due to error: %@", *error);
                [queryLock unlock];
                DBCLockLogger(@"[DBC:Restore] Relinquished from previously acquired lock (Line: %d)", __LINE__);
                return NO;
            }
        } while (shouldRetry);
        sqlite3_backup_finish(backup);
    }
    [queryLock unlock];
    DBCLockLogger(@"[DBC:Restore] Relinquished from previously acquired lock (Line: %d)", __LINE__);
    return resultCode==SQLITE_OK;
}

/**
 * Backup source database from current connection to destination database file and specified destination database name
 * @parameters
 *      NSString *srcDatabaseName - source database name in current database connection for backup
 *      NSString *dstDatabaseFile - destination database file to which database backup will be performed
 *      NSString *dstDatabaseName - destination database name, which will be used to backup source database
 *      DBCError **error          - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                                  Pass NULL if you do not want error information.
 * @return whether backup was successfull or not
 */
- (BOOL)backup:(NSString*)srcDatabaseName toFile:(NSString*)dstDatabaseFile database:(NSString*)dstDatabaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    int resultCode = SQLITE_OK;
    DBCLockLogger(@"[DBC:Backup] Waiting for Lock (Line: %d)", __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:Backup] Lock acquired (Line: %d)", __LINE__);
    sqlite3 *dstDBConnection = NULL;
    int retryCount = 0;
    BOOL shouldRetry = NO;
    const char *targetDatabase = (dstDatabaseFile==nil||[dstDatabaseFile length]==0?NULL:[dstDatabaseFile UTF8String]);
    do {
        shouldRetry = NO;
        resultCode = sqlite3_open_v2(targetDatabase, &dstDBConnection, SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE, NULL);
        if(resultCode == SQLITE_LOCKED || resultCode == SQLITE_BUSY){
            if(executionRetryCount && retryCount < executionRetryCount){
                shouldRetry = YES;
                sqlite3_sleep(150);
            } else {
                recentErrorCode = resultCode;
                *error = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                      additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                DBCDebugLogger(@"[DBC:Backup] Can't restore database due to error: %@", *error);
                sqlite3_close(dstDBConnection);
                dstDBConnection = NULL;
                [queryLock unlock];
                DBCLockLogger(@"[DBC:Backup] Relinquished from previously acquired lock (Line: %d)", __LINE__);
                return NO;
            }
        }
    } while (shouldRetry);
    
    BOOL backupSuccessfull = [self backup:srcDatabaseName to:dstDBConnection database:dstDatabaseName error:error];
    
    sqlite3_close(dstDBConnection);
    dstDBConnection = NULL;
    [queryLock unlock];
    DBCLockLogger(@"[DBC:Restore] Relinquished from previously acquired lock (Line: %d)", __LINE__);
    
    return backupSuccessfull;
}

/**
 * Backup source database from current connection to destination database connection and specified destination 
 * database name
 * @parameters
 *      NSString *srcDatabaseName - source database name in current database connection for backup
 *      NSString *dstDatabase     - destination database connection to which database backup will be performed
 *      NSString *dstDatabaseName - destination database name, which will be used to backup source database
 *      DBCError **error          - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                                  Pass NULL if you do not want error information.
 * @return whether backup was successfull or not
 */
- (BOOL)backup:(NSString*)srcDatabaseName to:(sqlite3*)dstDatabase database:(NSString*)dstDatabaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    int resultCode = SQLITE_OK;
    DBCLockLogger(@"[DBC:Backup] Waiting for Lock (Line: %d)", __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:Backup] Lock acquired (Line: %d)", __LINE__);
    int retryCount = 0;
    BOOL shouldRetry = NO;
    
    int sourcePageSize = [self pageSizeInDatabase:srcDatabaseName error:NULL];
    if(sourcePageSize > 0){
        sqlite3_stmt *dstPageSizeChangeStatement = NULL;
        sqlite3_stmt *dstVacuumStatement = NULL;
        const char *dstPageSizeChangeSQL = [[NSString stringWithFormat:@"PRAGMA %@.page_size = %i;", dstDatabase, sourcePageSize] UTF8String];
        const char *dstVacuumSQL = "VACUUM;";
        do {
            shouldRetry = NO;
            resultCode = sqlite3_prepare_v2(dstDatabase, dstPageSizeChangeSQL, -1, &dstPageSizeChangeStatement, NULL);
            if(resultCode == SQLITE_LOCKED || resultCode == SQLITE_BUSY){
                if(executionRetryCount && retryCount++ < executionRetryCount){
                    shouldRetry = YES;
                    sqlite3_sleep(150);
                }
            }
        } while (shouldRetry);
        if(resultCode == SQLITE_OK){
            do {
                shouldRetry = NO;
                resultCode = sqlite3_step(dstPageSizeChangeStatement);
                if(resultCode == SQLITE_LOCKED || resultCode == SQLITE_BUSY){
                    if(executionRetryCount && retryCount++ < executionRetryCount){
                        shouldRetry = YES;
                        sqlite3_sleep(150);
                    }
                }
            } while (shouldRetry);
        }
        if(resultCode == SQLITE_OK){
            do {
                shouldRetry = NO;
                resultCode = sqlite3_prepare_v2(dstDatabase, dstVacuumSQL, -1, &dstVacuumStatement, NULL);
                if(resultCode == SQLITE_LOCKED || resultCode == SQLITE_BUSY){
                    if(executionRetryCount && retryCount++ < executionRetryCount){
                        shouldRetry = YES;
                        sqlite3_sleep(150);
                    }
                }
            } while (shouldRetry);
            if(resultCode == SQLITE_OK){
                do {
                    shouldRetry = NO;
                    resultCode = sqlite3_step(dstVacuumStatement);
                    if(resultCode == SQLITE_LOCKED || resultCode == SQLITE_BUSY){
                        if(executionRetryCount && retryCount++ < executionRetryCount){
                            shouldRetry = YES;
                            sqlite3_sleep(150);
                        }
                    }
                } while (shouldRetry);
            }
        }
    }
    
    if (dstDatabaseName == nil) dstDatabaseName = @"main";
    if (srcDatabaseName == nil) srcDatabaseName = @"main";
    sqlite3_backup *backup = sqlite3_backup_init(dstDatabase, [dstDatabaseName UTF8String], dbConnection, [srcDatabaseName UTF8String]);
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
    [queryLock unlock];
    DBCLockLogger(@"[DBC:Backup] Relinquished from previously acquired lock (Line: %d)", __LINE__);
    return resultCode==SQLITE_OK;
}

#pragma mark Transaction journal

/**
 * Turn off transaction journaling for current database connection
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * @return whether journaling turned off on current database connection or not
 */
- (BOOL)turnOffJournalingError:(DBCError**)error {
    return [self setJournalMode:DBCDatabaseJournalingModeOff error:error];
}

/**
 * Turn off transaction journaling for specified database connection
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return whether journaling turned off on current database connection or not
 */
- (BOOL)turnOffJournalingForDatabase:(NSString*)databaseName error:(DBCError**)error {
    return [self setJournalMode:DBCDatabaseJournalingModeOff forDatabase:databaseName error:error];
}

/**
 * Turn on transaction journaling for current database connection
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * @return whether journaling turned on on current database connection or not
 */
- (BOOL)turnOnJournalingError:(DBCError**)error {
    return [self setJournalMode:DBCDatabaseJournalingModeDelete error:error];
}

/**
 * Turn on transaction journaling for specified database connection
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return whether journaling turned on on current database connection or not
 */
- (BOOL)turnOnJournalingForDatabase:(NSString*)databaseName error:(DBCError**)error {
    return [self setJournalMode:DBCDatabaseJournalingModeDelete forDatabase:databaseName error:error];
}

/**
 * Set new journal mode for current database connection and any newly attached 
 * databases
 * @parameters
 *      NSString *journalMode - new journalig mode
 *      DBCError **error      - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                              Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setJournalMode:(DBCDatabaseJournalingMode)journalMode error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    NSArray *allowedModes = [NSArray arrayWithObjects:@"delete", @"truncate", @"persist", @"memory", @"off", nil];
    if((int)journalMode < 0 || (int)journalMode >= [allowedModes count]) return NO;
    return [self executeUpdate:[NSString stringWithFormat:@"PRAGMA journal_mode = %@;", [allowedModes objectAtIndex:journalMode]] error:error, nil];
}

/**
 * Get current database connection journaling mode
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * @return journaling mode for current database connection
 */
- (DBCDatabaseJournalingMode)journalModeError:(DBCError**)error {
    if(!dbConnectionOpened) return -1;
    NSArray *allowedModes = [NSArray arrayWithObjects:@"delete", @"truncate", @"persist", @"memory", @"off", nil];
    DBCDatabaseResult *result = [self executeQuery:@"PRAGMA journal_mode;" error:error, nil];
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
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setJournalMode:(DBCDatabaseJournalingMode)journalMode forDatabase:(NSString*)databaseName error:(DBCError**)error {
    NSArray *allowedModes = [NSArray arrayWithObjects:@"delete", @"truncate", @"persist", @"memory", @"off", nil];
    if((int)journalMode < 0 || (int)journalMode >= [allowedModes count]) return NO;
    if(databaseName == nil) databaseName = @"main";
    return [self executeUpdate:[NSString stringWithFormat:@"PRAGMA %@.journal_mode = %@;", databaseName, [allowedModes objectAtIndex:journalMode]] error:error, nil];
}

/**
 * Get specified database connection journaling mode
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return journaling mode for specified database connection
 */
- (DBCDatabaseJournalingMode)journalModeForDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    NSArray *allowedModes = [NSArray arrayWithObjects:@"delete", @"truncate", @"persist", @"memory", @"off", nil];
    DBCDatabaseResult *result = [self executeQuery:[NSString stringWithFormat:@"PRAGMA %@.journal_mode;", databaseName] error:error, nil];
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
 *      DBCError **error                  - if an error occurs, upon return contains an DBCError object that describes the 
 *                                          problem. Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setJournalSizeLimitForDatabase:(NSString*)databaseName size:(long long int)newJournalSizeLimit error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    if(databaseName == nil) databaseName = @"main";
    return [self executeUpdate:[NSString stringWithFormat:@"PRAGMA %@.journal_size_limit = %lld;", databaseName, newJournalSizeLimit] error:error, nil];
}

/**
 * Get journal size for specified database
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return journal size in bytes for specified database
 */
- (long long int)journalSizeLimitForDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    DBCDatabaseResult *result = [self executeQuery:[NSString stringWithFormat:@"PRAGMA %@.journal_size_limit;", databaseName] error:error, nil];
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
 *      DBCError **error                   - if an error occurs, upon return contains an DBCError object that describes the 
 *                                           problem. Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setLockingMode:(DBCDatabaseLockingMode)lockingMode error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    NSArray *allowedModes = [NSArray arrayWithObjects:@"normal", @"exclusive", nil];
    if((int)lockingMode < 0 || (int)lockingMode >= [allowedModes count]) return NO;
    return [self executeUpdate:[NSString stringWithFormat:@"PRAGMA locking_mode = %@;", [allowedModes objectAtIndex:lockingMode]] error:error, nil];
}

/**
 * Get current database connection locking mode
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * @return current database connection locking mode
 */
- (DBCDatabaseLockingMode)lockingModeError:(DBCError**)error {
    if(!dbConnectionOpened) return -1;
    NSArray *allowedModes = [NSArray arrayWithObjects:@"normal", @"exclusive", nil];
    DBCDatabaseResult *result = [self executeQuery:@"PRAGMA locking_mode;" error:error, nil];
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
 *      DBCError **error                   - if an error occurs, upon return contains an DBCError object that describes the 
 *                                           problem. 
 *                                           Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setLockingMode:(DBCDatabaseLockingMode)lockingMode forDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    if(databaseName == nil) databaseName = @"main";
    NSArray *allowedModes = [NSArray arrayWithObjects:@"normal", @"exclusive", nil];
    if((int)lockingMode < 0 || (int)lockingMode >= [allowedModes count]) return NO;
    return [self executeUpdate:[NSString stringWithFormat:@"PRAGMA %@.locking_mode = %@;", 
                                 databaseName, [allowedModes objectAtIndex:lockingMode]] error:error, nil];
}

/**
 * Get specified database locking mode
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return specified database locking mode
 */
- (DBCDatabaseLockingMode)lockingModeForDatabase:(NSString*)databaseName error:(DBCError**)error {
    if(!dbConnectionOpened) return -1;
    if(databaseName == nil) databaseName = @"main";
    NSArray *allowedModes = [NSArray arrayWithObjects:@"normal", @"exclusive", nil];
    DBCDatabaseResult *result = [self executeQuery:[NSString stringWithFormat:@"PRAGMA %@.locking_mode;", databaseName] error:error, nil];
    if([result count] > 0){
        return [allowedModes indexOfObject:[[[result rowAtIndex:0] stringForColumn:@"locking_mode"] lowercaseString]];
    }
    return -1;
}

/**
 * Set read locks state 
 * @parameters
 *      BOOL omit        - should omit read lock or not
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setOmitReadlockLike:(BOOL)omit error:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    return [self executeUpdate:@"PRAGMA omit_readlock = %d;" error:error, (omit?1:0), nil];
}

/**
 * Get whether omit read lock flag or not
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * @return whether omit read lock flag or not
 */
- (BOOL)omitReadlockError:(DBCError**)error {
    if(!dbConnectionOpened) return NO;
    DBCDatabaseResult *result = [self executeQuery:@"PRAGMA max_page_count;" error:error, nil];
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
 *      DBCError **error               - if an error occurs, upon return contains an DBCError object that describes the 
 *                                       problem. Pass NULL if you do not want error information.
 *  @return return code which indicate was module registered or not
 */
- (BOOL)registerModule:(const sqlite3_module*)module moduleName:(NSString*)moduleName userData:(void*)userData cleanupFunction:(void(*)(void*))cleanupFunction error:(DBCError**)error{
    int returnCode = SQLITE_ERROR;
    if(!dbConnectionOpened) return returnCode;
    if(cleanupFunction != NULL) returnCode = sqlite3_create_module_v2(dbConnection, [moduleName UTF8String], module, userData, cleanupFunction);
    returnCode = sqlite3_create_module(dbConnection, [moduleName UTF8String], module, userData);
    if(returnCode != SQLITE_OK){
        recentErrorCode = returnCode;
        *error = [[[DBCError alloc] initWithErrorCode:recentErrorCode errorDomain:kDBCErrorDomain forFilePath:nil additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] autorelease];
        DBCDebugLogger(@"[DBC:Module] Can't register module due to error: %@", *error);
    }
    return returnCode==SQLITE_OK;
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
- (BOOL)registerScalarFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))function functionName:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData error:(DBCError**)error {
    int returnCode = SQLITE_ERROR;
    if(!dbConnectionOpened) return returnCode;
    if(expectedTextValueRepresentation==SQLITE_UTF8||expectedTextValueRepresentation==SQLITE_ANY){
        returnCode = sqlite3_create_function(dbConnection, [fnName UTF8String], fnParametersCount, expectedTextValueRepresentation, fnUserData, function, NULL, NULL);
    } else if(expectedTextValueRepresentation==SQLITE_UTF16||expectedTextValueRepresentation==SQLITE_UTF16BE||
              expectedTextValueRepresentation==SQLITE_UTF16LE){
        returnCode = sqlite3_create_function16(dbConnection, [fnName cStringUsingEncoding:NSUTF16StringEncoding], fnParametersCount, expectedTextValueRepresentation, fnUserData, function, NULL, NULL);
    }
    if(returnCode != SQLITE_OK){
        recentErrorCode = returnCode;
        *error = [[[DBCError alloc] initWithErrorCode:recentErrorCode errorDomain:kDBCErrorDomain forFilePath:nil additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] autorelease];
        DBCDebugLogger(@"[DBC:Module] Can't register module due to error: %@", *error);
    }
    return returnCode==SQLITE_OK;
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
- (BOOL)unRegisterScalarFunction:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation error:(DBCError**)error {
    int returnCode = SQLITE_ERROR;
    if(expectedTextValueRepresentation==SQLITE_UTF8||expectedTextValueRepresentation==SQLITE_ANY){
        returnCode = sqlite3_create_function(dbConnection, [fnName UTF8String], fnParametersCount, expectedTextValueRepresentation, NULL, NULL, NULL, NULL);
    } else if(expectedTextValueRepresentation==SQLITE_UTF16||expectedTextValueRepresentation==SQLITE_UTF16BE||
              expectedTextValueRepresentation==SQLITE_UTF16LE){
        returnCode = sqlite3_create_function16(dbConnection, [fnName cStringUsingEncoding:NSUTF16StringEncoding], fnParametersCount, expectedTextValueRepresentation, NULL, NULL, NULL, NULL);
    }
    if(returnCode != SQLITE_OK){
        recentErrorCode = returnCode;
        *error = [[[DBCError alloc] initWithErrorCode:recentErrorCode errorDomain:kDBCErrorDomain forFilePath:nil additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] autorelease];
        DBCDebugLogger(@"[DBC:Module] Can't register module due to error: %@", *error);
    }
    return returnCode==SQLITE_OK;
}

/**
 * Register aggregation function
 * @parameters
 *      void(*)(sqlite3_context*, int, sqlite3_value) stepFunction - registered step function with defined
 *                                                                   signature
 *      void(*)(sqlite3_context*) finalizeFunction                 - registered finalyzed function with defined
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
- (BOOL)registerAggregationFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))stepFunction finalizeFunction:(void(*)(sqlite3_context*))finalizeFunction functionName:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData error:(DBCError**)error {
    int returnCode = SQLITE_ERROR;
    if(!dbConnectionOpened) return returnCode;
    if(expectedTextValueRepresentation==SQLITE_UTF8||expectedTextValueRepresentation==SQLITE_ANY){
        returnCode = sqlite3_create_function(dbConnection, [fnName UTF8String], fnParametersCount, expectedTextValueRepresentation, fnUserData, NULL, stepFunction, finalizeFunction);
    } else if(expectedTextValueRepresentation==SQLITE_UTF16||expectedTextValueRepresentation==SQLITE_UTF16BE||
              expectedTextValueRepresentation==SQLITE_UTF16LE){
        returnCode = sqlite3_create_function16(dbConnection, [fnName cStringUsingEncoding:NSUTF16StringEncoding], fnParametersCount, expectedTextValueRepresentation, fnUserData, NULL, stepFunction, finalizeFunction);
    }
    if(returnCode != SQLITE_OK){
        recentErrorCode = returnCode;
        *error = [[[DBCError alloc] initWithErrorCode:recentErrorCode errorDomain:kDBCErrorDomain forFilePath:nil additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] autorelease];
        DBCDebugLogger(@"[DBC:Module] Can't register module due to error: %@", *error);
    }
    return returnCode==SQLITE_OK;
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
- (BOOL)unRegisterAggregationFunction:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation error:(DBCError**)error {
    int returnCode = SQLITE_ERROR;
    if(expectedTextValueRepresentation==SQLITE_UTF8||expectedTextValueRepresentation==SQLITE_ANY){
        returnCode = sqlite3_create_function(dbConnection, [fnName UTF8String], fnParametersCount, expectedTextValueRepresentation, NULL, NULL, NULL, NULL);
    } else if(expectedTextValueRepresentation==SQLITE_UTF16||expectedTextValueRepresentation==SQLITE_UTF16BE||
              expectedTextValueRepresentation==SQLITE_UTF16LE){
        returnCode = sqlite3_create_function16(dbConnection, [fnName cStringUsingEncoding:NSUTF16StringEncoding], fnParametersCount, expectedTextValueRepresentation, NULL, NULL, NULL, NULL);
    }
    if(returnCode != SQLITE_OK){
        recentErrorCode = returnCode;
        *error = [[[DBCError alloc] initWithErrorCode:recentErrorCode errorDomain:kDBCErrorDomain forFilePath:nil additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] autorelease];
        DBCDebugLogger(@"[DBC:Module] Can't register module due to error: %@", *error);
    }
    return returnCode==SQLITE_OK;
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
- (BOOL)registerCollationFunction:(int(*)(void*, int, const void*, int, const void*))function cleanupFunction:(void(*)(void*))cleanupFunction functionName:(NSString*)fnName textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData error:(DBCError**)error {
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
    if(returnCode != SQLITE_OK){
        recentErrorCode = returnCode;
        *error = [[[DBCError alloc] initWithErrorCode:recentErrorCode errorDomain:kDBCErrorDomain forFilePath:nil additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] autorelease];
        DBCDebugLogger(@"[DBC:Module] Can't register module due to error: %@", *error);
    }
    return returnCode==SQLITE_OK;
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
- (BOOL)unRegisterCollationFunction:(NSString*)fnName textValueRepresentation:(int)expectedTextValueRepresentation error:(DBCError**)error {
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
    if(returnCode != SQLITE_OK){
        recentErrorCode = returnCode;
        *error = [[[DBCError alloc] initWithErrorCode:recentErrorCode errorDomain:kDBCErrorDomain forFilePath:nil additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] autorelease];
        DBCDebugLogger(@"[DBC:Module] Can't register module due to error: %@", *error);
    }
    return returnCode==SQLITE_OK;
}

@end
