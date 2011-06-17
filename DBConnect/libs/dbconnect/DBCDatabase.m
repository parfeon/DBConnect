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

#import "DBCDatabase.h"
#import "DBCString+Utils.h"
#import "DBCDatabase+Advanced.h"
#import "DBCDatabase+Aliases.h"
#import "DBCMacro.h"

#define PARAMETERS_LIST @"parametersList"
#define PARAMETERS_MAPPING_INFORMATION @"parametersMappingInformation"
#define PREPARED_SQL_STATEMENT @"preparedSQLStatement"
 
// SQL statement parameters token format
typedef enum _SQLStatementFromat {
    SQLStatementFromatUnknown,
    SQLStatementFromatNSStringFormat,
    SQLStatementFromatAnonymousToken,
    SQLStatementFromatIndexedToken,
    SQLStatementFromatNamedToken
} SQLStatementFromat;

@class DBCStatement;

@interface DBCDatabase (private)

#pragma mark DDL and DML methods

- (BOOL)evaluateUpdate:(NSString*)sqlUpdate withBindingMapData:(NSDictionary*)bindingMapData;
- (DBCDatabaseResult*)evaluateQuery:(NSString*)sqlQuery withBindingMapData:(NSDictionary*)bindingMapData;

- (int)bindStatement:(sqlite3_stmt*)statement accordingToBindingMapData:(NSDictionary*)bindingMapData parametersOffset:(int*)offset;
- (int)bindObject:(id)object atIndex:(int)index inStatement:(sqlite3_stmt*)statement;
- (void)addStatementToCache:(DBCStatement*)statement;
- (void)removeStatementFromChache:(DBCStatement*)statement;
- (DBCStatement*)getCachedStatementFor:(NSString*)sqlRequest;

#pragma mark DBCDatabase private getter/setter methods

- (BOOL)isDatabaseConnectionForReadOnlyMode;
- (SQLStatementFromat)getSQLStatementType:(NSString*)sqlStatement;
- (NSArray*)getSQLStatementsSequence:(NSString*)sql;
- (int)getSQLStatementParametersCount:(NSString*)sql;
- (NSDictionary*)getParametersBindingMapData:(NSString*)sqlStatement vaList:(va_list)parameters;
- (BOOL)SQLStatementsSequenceContainsTCL:(NSArray*)commandsList;
- (Class)getVAItemClass:(va_list)parameters;

@end

@implementation DBCDatabase

@synthesize dbBusyRetryCount, statementsCachingEnabled, createTransactionOnSQLSequences;
@synthesize rollbackSQLSequenceTransactionOnError, defaultSQLSequencesTransactinoLock, recentErrorCode, recentError;

#pragma mark DBCDatabase instance initialization

/**
 * Create and initiate DBCDatabase by opening database, which exists at 'dbFilePath' 
 * with default encoding (UTF-8)
 * @parameters
 *      NSString *dbFilePath         - sqlite database file path
 * @return autoreleased DBCDatabase instance
 */
+ (id)databaseWithPath:(NSString*)dbFilePath {
    return [DBCDatabase databaseWithPath:dbFilePath defaultEncoding:DBCDatabaseEncodingUTF8];
}

/**
 * Create and initiate DBCDatabase by opening database, which exists at 'dbFilePath' 
 * @parameters
 *      NSString *dbFilePath         - sqlite database file path
 *      DBCDatabaseEncoding encoding - default encoding which will be used, when 
 *                                     exists ability to use differenc C API for 
 *                                     different encodings
 * @return autoreleased DBCDatabase instance
 */
+ (id)databaseWithPath:(NSString*)dbFilePath defaultEncoding:(DBCDatabaseEncoding)encoding {
    return [[[[self class] alloc] initWithPath:dbFilePath defaultEncoding:encoding] autorelease];
}

/**
 * Create and initiate DBCDatabase from sqlite database file, which will be created at
 * specified path and SQL statements list from provided file. Will be used default encoding
 * @oarameters
 *      NSString* sqlStatementsListFilepath - path to file with list of SQL statements list
 *      NSString* databasePath              - sqlite database file target location
 *      BOOL      continueOnEvaluateErrors  - should continue creation on evaluate 
 *                                            update request error
 * WARNING: databasePath can't be same as application bundle, use application
 *          Documents folder instead
 * @return autoreleased DBCDatabase instance
 */
+ (id)databaseFromFile:(NSString*)sqlStatementsListFilepath atPath:(NSString*)databasePath continueOnEvaluateErrors:(BOOL)continueOnEvaluateErrors {
    return [DBCDatabase databaseFromFile:sqlStatementsListFilepath atPath:databasePath defaultEncoding:DBCDatabaseEncodingUTF8 continueOnEvaluateErrors:continueOnEvaluateErrors];
}

/**
 * Create and initiate DBCDatabase from sqlite database file, which will be created at
 * specified path and SQL statements list from provided file.
 * @oarameters
 *      NSString* sqlStatementsListFilepath - path to file with list of SQL statements list
 *      NSString* databasePath              - sqlite database file target location
 *      DBCDatabaseEncoding encoding        - default encoding which will be used, when 
 *                                            exists ability to use differenc C API for 
 *                                            different encodings
 *      BOOL      continueOnEvaluateErrors  - should continue creation on evaluate 
 *                                            update request error
 * WARNING: databasePath can't be same as application bundle, use application
 *          Documents folder instead
 * @return autoreleased DBCDatabase instance
 */
+ (id)databaseFromFile:(NSString*)sqlStatementsListFilepath atPath:(NSString*)databasePath defaultEncoding:(DBCDatabaseEncoding)encoding 
                                                                                   continueOnEvaluateErrors:(BOOL)continueOnEvaluateErrors {
    return [[[[self class] alloc] createDatabaseFromFile:sqlStatementsListFilepath atPath:databasePath defaultEncoding:encoding
                                 continueOnEvaluateErrors:continueOnEvaluateErrors] autorelease];
}

/**
 * Initiate DBCDatabase by opening sqlite database file, which exists at 'dbFilePath' 
 * @parameters
 *      NSString *dbFilePath         - sqlite database file path
 *      DBCDatabaseEncoding encoding - default encoding which will be used, when 
 *                                     exists ability to use differenc C API for 
 *                                     different encodings
 * @return DBCDatabase instance
 */
- (id)initWithPath:(NSString*)dbFilePath defaultEncoding:(DBCDatabaseEncoding)encoding {
    if((self = [super init])){
        [self setCreateTransactionOnSQLSequences:YES];
        [self setRollbackSQLSequenceTransactionOnError:YES];
        [self setDefaultSQLSequencesTransactinoLock:DBCDatabaseAutocommitModeDeferred];
        listOfPossibleTCLCommands = [[NSArray arrayWithObjects:@"begin", @"begin transaction", @"begin deferred transaction", @"begin immediate transaction", 
                                      @"begin exclusive transaction", @"commit", @"commit transaction",  @"end", @"end transaction",nil] retain];
        listOfNSStringFormatSpecifiers = [[NSArray arrayWithObjects:@"%@", @"%d", @"%i", @"%u", @"%f", @"%g", @"%s", @"%S",@"%c", @"%C", 
                                           @"%lld", @"%llu", @"%Lf",nil] retain];
        dbEncoding = encoding;
        statementsCachingEnabled = YES;
        dbBusyRetryCount = 5;
        recentError = nil;
        recentErrorCode = -1;
        dbConnection = NULL;
        dbPath = [dbFilePath copy];
        queryLock = [[NSRecursiveLock alloc] init];
        cachedStatementsList = [[NSMutableDictionary alloc] init];
        inMemoryDB = dbPath?[dbPath isEqualToString:@":memory:"]:YES;
    }
    return self;
}

/**
 * Initiate DBCDatabase from sqlite database file, which will be created at
 * specified path and SQL query commands list from provided file.
 * @oarameters
 *      NSString* sqlQeryListPath          - path to file with list of SQL query commands list
 *      NSString* databasePath             - sqlite database file target location
 *      DBCDatabaseEncoding encoding       - default encoding which will be used, when 
 *                                           exists ability to use differenc C API for 
 *                                           different encodings
 *      BOOL      continueOnEvaluateErrors - should continue creation on evaluate 
 *                                          update request error
 * WARNING: databasePath can't be same as application bundle, use application
 *          Documents folder instead
 * @return DBCDatabase instance
 */
- (id)createDatabaseFromFile:(NSString*)sqlQeryListPath atPath:(NSString*)databasePath defaultEncoding:(DBCDatabaseEncoding)encoding continueOnEvaluateErrors:(BOOL)continueOnEvaluateErrors {
    if ((self = [self initWithPath:databasePath defaultEncoding:encoding])) {
        [self open];
        if(dbConnectionOpened && sqlQeryListPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:sqlQeryListPath]){
            struct sqlite3lib_error execError = {"", -1, -1};
            if(dbEncoding==DBCDatabaseEncodingUTF8) 
                evaluateQueryFromFile(dbConnection, [sqlQeryListPath UTF8String], continueOnEvaluateErrors, &execError);
            else if(dbEncoding==DBCDatabaseEncodingUTF16)
                evaluateQueryFromFile(dbConnection, [sqlQeryListPath cStringUsingEncoding:NSUTF16StringEncoding], continueOnEvaluateErrors, &execError);
            if(execError.errorCode != -1 && !continueOnEvaluateErrors){
                if([[NSFileManager defaultManager] fileExistsAtPath:databasePath]){
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:databasePath error:&error];
                    if(error!=nil) DBCDebugLogger(@"[DBC:ERROR] %@", error);
                }
                [self release];
                return nil;
            } else if(execError.errorCode != -1){
                recentErrorCode = execError.errorCode;
                DBCReleaseObject(recentError);
                recentError = [[DBCError errorWithErrorCode:execError.errorCode forFilePath:sqlQeryListPath
                                      additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                DBCDebugLogger(@"[DBC:ERROR] %@", recentError);
            }
        }
    }
    return self;
}

#pragma mark Database open and close

/**
 * Open new database connection to sqlite database file at path, which was 
 * provided in init
 * Connection will be opened with 'readwrite|create' right
 * @return whether database connection was successfully opened or not
 */
- (BOOL)open {
    return [self openWithFlags:SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE];
 }

/**
 * Open new database connection to sqlite database file at path, which was 
 * provided in init
 * Connection will be opened with 'readonly' rights
 * @return whether database connection was successfully opened or not
 */
- (BOOL)openReadonly {
    BOOL opened = [self openWithFlags:SQLITE_OPEN_READONLY];
    if(opened){
        [self setJournalMode:DBCDatabaseJournalingModeOff];
    }
    return opened;
}


/**
 * Copy currently opened sqlite database file to provided location assuming what
 * it is outside of application bundle and reopen connection with 'read-write' rights
 * @parameters
 *      NSString *mutableDatabaseStoreDestination - database file copy destination
 */
- (BOOL)makeMutableAt:(NSString*)mutableDatabaseStoreDestination {
    if(mutableDatabaseStoreDestination == nil)
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        mutableDatabaseStoreDestination = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[dbPath lastPathComponent]];
#else 
    return NO;
#endif
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *dirCreationError = nil;
    if(![fileManager fileExistsAtPath:[mutableDatabaseStoreDestination stringByDeletingLastPathComponent]
                          isDirectory:NULL]){
        [fileManager createDirectoryAtPath:[mutableDatabaseStoreDestination stringByDeletingLastPathComponent]
               withIntermediateDirectories:YES attributes:nil 
                                     error:&dirCreationError];
        if(dirCreationError != nil){
            recentErrorCode = DBC_CANT_CREATE_FOLDER_FOR_MUTABLE_DATABASE; 
            DBCReleaseObject(recentError);
            recentError = [[DBCError errorWithErrorCode:recentErrorCode 
                                            forFilePath:[mutableDatabaseStoreDestination stringByDeletingLastPathComponent] 
                                  additionalInformation:[dirCreationError description]] retain];
            DBCDebugLogger(@"[DBC:ERROR] Can't create mutable database copy due to error: %@", recentError);
            dirCreationError = nil;
            return NO;
        }
    }
    NSError *databaseCopyError = nil;
    [fileManager copyItemAtPath:dbPath toPath:mutableDatabaseStoreDestination error:&databaseCopyError];
    if(databaseCopyError != nil){
        recentErrorCode = DBC_CANT_COPY_DATABASE_FILE_TO_NEW_LOCATION;
        DBCReleaseObject(recentError);
        recentError = [[DBCError errorWithErrorCode:recentErrorCode 
                                        forFilePath:[mutableDatabaseStoreDestination stringByDeletingLastPathComponent] 
                              additionalInformation:[databaseCopyError description]] retain];
        DBCDebugLogger(@"[DBC:ERROR] Can't create mutable database copy due to error: %@", recentError);
        databaseCopyError = nil;
        return NO;
    }
    
    if(![self close]) return NO;
    DBCReleaseObject(dbPath);
    dbPath = [mutableDatabaseStoreDestination copy];
    
    return [self open];
}

/**
 * Close database connection to sqlite database file if it was opened
 * @return whether database connection was successfully closed or not
 */
- (BOOL)close {
    DBCLockLogger(@"[DBC:close] Waiting for Lock (Line: %d)", __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:close] Lock acquired (Line: %d)", __LINE__);
    [cachedStatementsList removeAllObjects];
    if(dbConnection==NULL){
        dbConnectionOpened = NO;
        [queryLock unlock];
        DBCLockLogger(@"[DBC:close] Relinquished from previously acquired lock (Line: %d)", __LINE__);
        return YES;
    }
    int retryCount = 0;
    BOOL shouldRetry = NO;
    int returnCode = SQLITE_OK;
    do {
        shouldRetry = NO;
        returnCode = sqlite3_close(dbConnection);
        if(returnCode == SQLITE_LOCKED || returnCode == SQLITE_BUSY){
            if(dbBusyRetryCount && retryCount < dbBusyRetryCount){
                shouldRetry = YES;
                sqlite3_sleep(150);
            } else {
                recentErrorCode = returnCode;
                DBCReleaseObject(recentError);
                recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                      additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                DBCDebugLogger(@"[DBC:ERROR] Database can't be closed due to error: %@", recentError);
            }
        }
    } while (shouldRetry);
    
    if(returnCode==SQLITE_OK){
        dbConnection = NULL;
        dbConnectionOpened = NO;
    } else {
        recentErrorCode = returnCode;
        DBCReleaseObject(recentError);
        recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                              additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
        DBCDebugLogger(@"[DBC:ERROR] Database can't be closed due to error: %@", recentError);
    }
    [queryLock unlock];
    DBCLockLogger(@"[DBC:close] Relinquished from previously acquired lock (Line: %d)", __LINE__);
    return !dbConnectionOpened;
}

#pragma mark DDL and DML methods

/**
 * Evaluate prepared SQL statement on current database connection
 * @parameters
 *      NSString *sqlUpdate - SQL query command
 *               ...        - list of binding parameters
 * @return whether update request was successfully evaluated or not
 */
- (BOOL)evaluateUpdate:(NSString*)sqlUpdate, ... {
    va_list parameters;
    va_start(parameters, sqlUpdate);
    NSDictionary *parametersBindingMap = [self getParametersBindingMapData:sqlUpdate vaList:parameters];
    va_end(parameters);
    if(parametersBindingMap == nil) {
        recentErrorCode = DBC_WRONG_BINDING_PARMETERS_COUNT;
        DBCReleaseObject(recentError);
        recentError = [[DBCError errorWithErrorCode:recentErrorCode] retain];
        DBCDebugLogger(@"[DBC:ERROR] Wrong number of binding parameters: %@", recentError);
        return NO;
    }
    return [self evaluateUpdate:sqlUpdate withBindingMapData:parametersBindingMap];
}

/**
 * Evaluate prepared SQL statement on current database connection
 * @parameters
 *      NSString *sqlQuery  - SQL query command
 *               ...        - list of binding parameters
 * @return query resultts if evaluated successfull or nil in case of error
 */
- (DBCDatabaseResult*)evaluateQuery:(NSString*)sqlQuery, ... {
    va_list parameters;
    va_start(parameters, sqlQuery);
    NSDictionary *parametersBindingMap = [self getParametersBindingMapData:sqlQuery vaList:parameters];
    va_end(parameters);
    if(parametersBindingMap == nil) {
        recentErrorCode = DBC_WRONG_BINDING_PARMETERS_COUNT;
        DBCReleaseObject(recentError);
        recentError = [[DBCError errorWithErrorCode:recentErrorCode] retain];
        DBCDebugLogger(@"[DBC:ERROR] Wrong number of binding parameters: %@", recentError);
        return nil;
    }
    return [self evaluateQuery:sqlQuery withBindingMapData:parametersBindingMap];
}

/**
 * Evaluate statements list from external file on current database connection
 * @parameters
 *      NSString *statementsFilePath  - sqlite database file path
 *      BOOL continueOnEvaluateErrors - should continue statements evaluation on errors
 * @return whether eavluate was successfull or not (always YES if set continueOnEvaluateErrors)
 */
- (BOOL)evaluateStatementsFromFile:(NSString*)statementsFilePath continueOnEvaluateErrors:(BOOL)continueOnEvaluateErrors {
    if(statementsFilePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:statementsFilePath]){
        struct sqlite3lib_error execError = {"", -1, -1};
        if(dbEncoding==DBCDatabaseEncodingUTF8) 
            evaluateQueryFromFile(dbConnection, [statementsFilePath UTF8String], continueOnEvaluateErrors, &execError);
        else if(dbEncoding==DBCDatabaseEncodingUTF16)
            evaluateQueryFromFile(dbConnection, [statementsFilePath cStringUsingEncoding:NSUTF16StringEncoding], continueOnEvaluateErrors, &execError);
        if(execError.errorCode != -1 && !continueOnEvaluateErrors){
            if([[NSFileManager defaultManager] fileExistsAtPath:statementsFilePath]){
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:statementsFilePath error:&error];
                if(error!=nil) DBCDebugLogger(@"[DBC:ERROR] %@", error);
            }
            [self release];
            return NO;
        } else if(execError.errorCode != -1){
            recentErrorCode = execError.errorCode;
            DBCReleaseObject(recentError);
            recentError = [[DBCError errorWithErrorCode:execError.errorCode forFilePath:statementsFilePath
                                  additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
            DBCDebugLogger(@"[DBC:ERROR] %@", recentError);
        }
        return continueOnEvaluateErrors||execError.errorCode==-1&&!continueOnEvaluateErrors;
    }
    return NO;
}

#pragma mark TCL methods

/**
 * Move database connection from 'autocommit' mode and begin default transaction
 * @return whether transaction was started or not
 */
- (BOOL)beginTransaction {
    return [self evaluateUpdate:[NSString stringWithFormat:@"BEGIN %@ TRANSACTION;",
                                 (DBCDatabaseTransactionLockNameFromEnum(defaultSQLSequencesTransactinoLock)!=nil?DBCDatabaseTransactionLockNameFromEnum(defaultSQLSequencesTransactinoLock):@"DEFERRED")], nil];
}

/**
 * Move database connection from 'autocommit' mode and begin deferred transaction
 * @return whether transaction was started or not
 */
- (BOOL)beginDeferredTransaction {
    return [self evaluateUpdate:@"BEGIN DEFERRED TRANSACTION;", nil];
}

/**
 * Move database connection from 'autocommit' mode and begin immediate transaction
 * @return whether transaction was started or not
 */
- (BOOL)beginImmediateTransaction {
    return [self evaluateUpdate:@"BEGIN IMMEDIATE TRANSACTION;", nil];
}

/**
 * Move database connection from 'autocommit' mode and begin exclusive transaction
 * @return whether transaction was started or not
 */
- (BOOL)beginExclusiveTransaction {
    return [self evaluateUpdate:@"BEGIN EXCLUSIVE TRANSACTION;", nil];
}

/**
 * Move database connection back to 'autocommit' mode and commit all changes made in 
 * transaction
 * @return whether transactoin changes commit was successfull or not
 */
- (BOOL)commitTransaction {
    return [self evaluateUpdate:@"COMMIT TRANSACTION;", nil];
}

/**
 * Try rollback current transaction
 * @return whether rollback was successfull or not
 */
- (BOOL)rollbackTransaction {
    return [self evaluateUpdate:@"ROLLBACK TRANSACTION;", nil];
}

#pragma mark DBCDatabase getter/setter methods

/**
 * Reloaded statement caching enable method
 * @parameters
 *      BOOL sCacheStatements - caching flag
 */
- (void)setStatementsCachingEnabled:(BOOL)sCacheStatements {
    DBCLockLogger(@"[DBC:StatementCache] Waiting for Lock (Line: %d)", __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:StatementCache] Lock acquired (Line: %d)", __LINE__);
    if(!sCacheStatements && cachedStatementsList) {
        DBCReleaseObject(cachedStatementsList);
    } else if(sCacheStatements && cachedStatementsList==nil) cachedStatementsList = [[NSMutableDictionary alloc] init];
    statementsCachingEnabled = sCacheStatements;
    [queryLock unlock];
    DBCLockLogger(@"[DBC:StatementCache] Relinquished from previously acquired lock (Line: %d)", __LINE__);
}

/**
 * Retrieve reference on opened dstabase connection handler instance
 * @return reference on opened database connection handler instance
 */
- (sqlite3*)database {
    if(!dbConnectionOpened) return NULL;
    return dbConnection;
}

#pragma mark DBCDatabase memory management

- (void)dealloc {
    [self close];
    dbConnection = NULL;
    DBCReleaseObject(dbPath);
    DBCReleaseObject(queryLock);
    DBCReleaseObject(recentError);
    DBCReleaseObject(cachedStatementsList);
    DBCReleaseObject(listOfPossibleTCLCommands);
    DBCReleaseObject(listOfNSStringFormatSpecifiers);
    [super dealloc];
}

@end

#pragma mark DBCDatabase private functionality

@implementation DBCDatabase (private)

#pragma mark DDL and DML methods

/**
 * Evaluate prepared update SQL statement on current database connection
 * @parameters
 *      NSString *sqlUpdate - SQL udpdate command
 *      NSArray *parameters - list of binding parameters
 * @return update request evaluate result
 */
- (BOOL)evaluateUpdate:(NSString*)sqlUpdate withBindingMapData:(NSDictionary*)bindingMapData {
    DBCDebugLogger(@"[DBC:Update] Binding map data: %@", bindingMapData);
    if([self isDatabaseConnectionForReadOnlyMode]) return NO;
    DBCLockLogger(@"[DBC:Update] Waiting for Lock: %@ (Line: %d)", [sqlUpdate md5], __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:Update] Lock acquired: %@ (Line: %d)", [sqlUpdate md5], __LINE__);
    
    if(![self open]){
        DBCLockLogger(@"[DBC:Update] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlUpdate md5], __LINE__);
        [queryLock unlock];
        return NO;
    }
    
    int retryCount = 0;
    int returnCode = SQLITE_OK;
    int bindedParametersOffset = 0;
    int errorLine = -1;
    BOOL shouldRetry = NO;
    BOOL transactionUsed = NO;
    BOOL sqlError = NO;
    DBCStatement *dbcStatement = nil;
    NSString *statementCacheKey = nil;
    sqlite3_stmt *statement = NULL;
    NSMutableArray *updateCommandsList = [NSMutableArray arrayWithArray:[self getSQLStatementsSequence:sqlUpdate]];
    NSMutableArray *preparedCommandsList = [NSMutableArray arrayWithArray:[self getSQLStatementsSequence:[bindingMapData valueForKey:PREPARED_SQL_STATEMENT]]];
    // Injecting TRANSACTION if required by flag
    if(createTransactionOnSQLSequences && [updateCommandsList count] > 1){
        transactionUsed = YES;
        if (![self SQLStatementsSequenceContainsTCL:updateCommandsList]) {
            [preparedCommandsList insertObject:[NSString stringWithFormat:@"BEGIN %@ TRANSACTION;",
                                                (DBCDatabaseTransactionLockNameFromEnum(defaultSQLSequencesTransactinoLock)!=nil?DBCDatabaseTransactionLockNameFromEnum(defaultSQLSequencesTransactinoLock):@"DEFERRED")] 
                                       atIndex:0];
            [updateCommandsList insertObject:[NSString stringWithFormat:@"BEGIN %@ TRANSACTION;",
                                              (DBCDatabaseTransactionLockNameFromEnum(defaultSQLSequencesTransactinoLock)!=nil?DBCDatabaseTransactionLockNameFromEnum(defaultSQLSequencesTransactinoLock):@"DEFERRED")] 
                                     atIndex:0];
            [preparedCommandsList addObject:@"COMMIT TRANSACTION;"];
            [updateCommandsList addObject:@"COMMIT TRANSACTION;"];
        }
    } else if ([self SQLStatementsSequenceContainsTCL:updateCommandsList] && [updateCommandsList count] > 1) transactionUsed = YES;
    int i, count = [preparedCommandsList count];
    for (i = 0; i < count; i++) {
        NSString *sql = [preparedCommandsList objectAtIndex:i];
        if(statementsCachingEnabled){
            statementCacheKey = [[updateCommandsList objectAtIndex:[preparedCommandsList indexOfObject:sql]] md5];
            dbcStatement = [self getCachedStatementFor:statementCacheKey];
            if(dbcStatement) [dbcStatement reset];
            statement = dbcStatement?[dbcStatement statement]:NULL;
        }
        
        if(statement==NULL){
            do {
                shouldRetry = NO;
                if (dbEncoding==DBCDatabaseEncodingUTF8) 
                    returnCode = sqlite3_prepare_v2(dbConnection, [sql UTF8String], -1, &statement, NULL);
                else if(dbEncoding==DBCDatabaseEncodingUTF16) 
                    returnCode = sqlite3_prepare16_v2(dbConnection, [sql cStringUsingEncoding:NSUTF16StringEncoding], -1, &statement, NULL);
                if(returnCode == SQLITE_LOCKED || returnCode == SQLITE_BUSY){
                    if(dbBusyRetryCount && retryCount++ < dbBusyRetryCount){
                        shouldRetry = YES;
                        sqlite3_sleep(150);
                    } else {
                        errorLine = __LINE__;
                        sqlError = YES;
                    }
                } else if(returnCode != SQLITE_OK){
                    errorLine = __LINE__;
                    sqlError = YES;
                }
            } while (shouldRetry);
            if(sqlError){
                recentErrorCode = returnCode;
                DBCReleaseObject(recentError);
                recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                      additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                sqlite3_finalize(statement);
                [queryLock unlock];
                DBCLockLogger(@"[DBC:Update] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlUpdate md5], errorLine);
                return NO;
            }
        }
        returnCode = [self bindStatement:statement accordingToBindingMapData:bindingMapData parametersOffset:&bindedParametersOffset];
        if(returnCode != SQLITE_OK){
            recentErrorCode = returnCode;
            DBCReleaseObject(recentError);
            recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                  additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
            if(i > 0 && transactionUsed && rollbackSQLSequenceTransactionOnError) [self rollbackTransaction];
            sqlite3_finalize(statement);
            [queryLock unlock];
            DBCLockLogger(@"[DBC:Update] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlUpdate md5], __LINE__);
            return NO;
        } else {
            retryCount = 0;
            do {
                shouldRetry = NO;
                returnCode = sqlite3_step(statement);
                if(returnCode == SQLITE_LOCKED || returnCode == SQLITE_BUSY){
                    if(dbBusyRetryCount && retryCount++ < dbBusyRetryCount){
                        shouldRetry = YES;
                        sqlite3_sleep(150);
                    } else {
                        errorLine = __LINE__;
                        sqlError = YES;
                    }
                } else if(returnCode != SQLITE_DONE && returnCode != SQLITE_ROW){
                    errorLine = __LINE__;
                    sqlError = YES;
                }
            } while (shouldRetry);
            if(sqlError){
                recentErrorCode = returnCode;
                DBCReleaseObject(recentError);
                recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                      additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                if(i > 0 && transactionUsed && rollbackSQLSequenceTransactionOnError) [self rollbackTransaction];
                sqlite3_finalize(statement);
                [queryLock unlock];
                DBCLockLogger(@"[DBC:Update] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlUpdate md5], errorLine);
                return NO;
            }
        }
        if(statementsCachingEnabled && dbcStatement == nil){
            dbcStatement = [[DBCStatement alloc] initWithSQLQuery:statementCacheKey];
            [dbcStatement setStatement:statement];
            [self addStatementToCache:dbcStatement];
            DBCReleaseObject(dbcStatement);
        } else if(!statementsCachingEnabled) sqlite3_finalize(statement);
    }
    [queryLock unlock];
    DBCLockLogger(@"[DBC:Update] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlUpdate md5], __LINE__);
    return returnCode==SQLITE_OK;
}

/**
 * Evaluate prepared query SQL statement on current database connection
 * @parameters
 *      NSString *sqlUpdate - SQL query command
 *      NSArray *parameters - list of binding parameters
 * @return query resultts if evaluated successfull or nil in case of error
 */
- (DBCDatabaseResult*)evaluateQuery:(NSString*)sqlQuery withBindingMapData:(NSDictionary*)bindingMapData {
    DBCDebugLogger(@"[DBC:Query] Binding map data: %@", bindingMapData);
    DBCDatabaseResult *result = nil;
    DBCLockLogger(@"[DBC:Query] Waiting for Lock: %@ (Line: %d)", [sqlQuery md5], __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:Query] Lock acquired: %@ (Line: %d)", [sqlQuery md5], __LINE__);
    
    if(![self open]){
        [queryLock unlock];
        DBCLockLogger(@"[DBC:Query] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlQuery md5], __LINE__);
        return result;
    }
    
    int retryCount = 0;
    int returnCode = SQLITE_OK;
    int bindedParametersOffset = 0;
    int errorLine = -1;
    BOOL shouldRetry = NO;
    BOOL transactionUsed = NO;
    BOOL sqlError = NO;
    DBCStatement *dbcStatement = nil;
    NSString *statementCacheKey = nil;
    sqlite3_stmt *statement = NULL;
    NSMutableArray *updateCommandsList = [NSMutableArray arrayWithArray:[self getSQLStatementsSequence:sqlQuery]];
    NSMutableArray *preparedCommandsList = [NSMutableArray arrayWithArray:[self getSQLStatementsSequence:[bindingMapData valueForKey:PREPARED_SQL_STATEMENT]]];
    int i, count = [preparedCommandsList count];
    for (i = 0; i < count; i++) {
        NSString *sql = [preparedCommandsList objectAtIndex:i];
        if(statementsCachingEnabled){
            statementCacheKey = [[updateCommandsList objectAtIndex:[preparedCommandsList indexOfObject:sql]] md5];
            dbcStatement = [self getCachedStatementFor:statementCacheKey];
            if(dbcStatement) [dbcStatement reset];
            statement = dbcStatement?[dbcStatement statement]:NULL;
        }
        if(statement==NULL){
            do {
                shouldRetry = NO;
                if (dbEncoding==DBCDatabaseEncodingUTF8) 
                    returnCode = sqlite3_prepare_v2(dbConnection, [sql UTF8String], -1, &statement, NULL);
                else if(dbEncoding==DBCDatabaseEncodingUTF16) 
                    returnCode = sqlite3_prepare16_v2(dbConnection, [sql cStringUsingEncoding:NSUTF16StringEncoding], -1, &statement, NULL);
                if(returnCode == SQLITE_LOCKED || returnCode == SQLITE_BUSY){
                    if(dbBusyRetryCount && retryCount++ < dbBusyRetryCount){
                        shouldRetry = YES;
                        sqlite3_sleep(150);
                    } else {
                        errorLine = __LINE__;
                        sqlError = YES;
                    }
                } else if(returnCode != SQLITE_OK){
                    errorLine = __LINE__;
                    sqlError = YES;
                }
            } while (shouldRetry);
            if(sqlError){
                recentErrorCode = returnCode;
                DBCReleaseObject(recentError);
                recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                      additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                sqlite3_finalize(statement);
                [queryLock unlock];
                DBCLockLogger(@"[DBC:Query] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlQuery md5], errorLine);
                return NO;
            }
        }
        returnCode = [self bindStatement:statement accordingToBindingMapData:bindingMapData parametersOffset:&bindedParametersOffset];
        if(returnCode != SQLITE_OK){
            recentErrorCode = returnCode;
            DBCReleaseObject(recentError);
            recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                  additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
            if(i > 0 && transactionUsed && rollbackSQLSequenceTransactionOnError) [self rollbackTransaction];
            sqlite3_finalize(statement);
            [queryLock unlock];
            DBCLockLogger(@"[DBC:Query] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlQuery md5], __LINE__);
            return NO;
        } else {
            result = [DBCDatabaseResult resultWithPreparedStatement:statement encoding:dbEncoding];
            BOOL shouldStep = NO;
            retryCount = 0;
            do {
                shouldStep = NO;
                shouldRetry = NO;
                returnCode = sqlite3_step(statement);
                if(returnCode == SQLITE_LOCKED || returnCode == SQLITE_BUSY){
                    if(dbBusyRetryCount && retryCount++ < dbBusyRetryCount){
                        shouldRetry = YES;
                        sqlite3_sleep(150);
                    } else {
                        errorLine = __LINE__;
                        sqlError = YES;
                    }
                } else if(returnCode == SQLITE_ROW){
                    shouldStep = YES;
                    [result addRowFromStatement:statement];
                } else if(returnCode != SQLITE_DONE){
                    errorLine = __LINE__;
                    sqlError = YES;
                }
            } while (shouldRetry || shouldStep);
            if(sqlError){
                recentErrorCode = returnCode;
                DBCReleaseObject(recentError);
                recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                      additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                if(i > 0 && transactionUsed && rollbackSQLSequenceTransactionOnError) [self rollbackTransaction];
                sqlite3_finalize(statement);
                [queryLock unlock];
                DBCLockLogger(@"[DBC:Query] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlQuery md5], errorLine);
                return NO;
            }
        }
        if(statementsCachingEnabled && dbcStatement == nil){
            dbcStatement = [[DBCStatement alloc] initWithSQLQuery:statementCacheKey];
            [dbcStatement setStatement:statement];
            [self addStatementToCache:dbcStatement];
            DBCReleaseObject(dbcStatement);
        } else if(!statementsCachingEnabled) sqlite3_finalize(statement);
    }
    [queryLock unlock];
    DBCLockLogger(@"[DBC:Query] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlQuery md5], __LINE__);
    DBCDebugLogger(@"[DBC:Query] Total result count: %i", [result count]);
    return result;
}

/**
 * Bind statement to parameters list
 * @parameters
 *      sqlite3_stmt *statement - statement which will be bound to parameters
 *      NSArray *parameters     - list of parameters for binding
 * @return binding result code
 */
- (int)bindStatement:(sqlite3_stmt*)statement accordingToBindingMapData:(NSDictionary*)bindingMapData parametersOffset:(int*)offset {
    int returnCode = SQLITE_OK;
    int statementBindParametersCount = 0;
    NSString *sql = nil;
    const char *statementSQL = sqlite3_sql(statement);
    if(statementSQL != NULL){
        sql = [NSString stringWithUTF8String:statementSQL];
        if(sql) statementBindParametersCount = [self getSQLStatementParametersCount:sql];
    }
    for (int i = 0; i < statementBindParametersCount; i++) {
        int bindingIndex = *offset;
        id bindingValue = [[bindingMapData valueForKey:PARAMETERS_LIST] objectAtIndex:[[[bindingMapData valueForKey:PARAMETERS_MAPPING_INFORMATION] objectAtIndex:bindingIndex] intValue]];
        returnCode = [self bindObject:bindingValue atIndex:(i+1) inStatement:statement];
        if(returnCode == SQLITE_OK) *offset = *offset+1;
        else return returnCode;
    }
    return returnCode;
}

/**
 * Bind object at specific index for provided statement
 * @parameters
 *      id object               - object what should be bound to statement
 *      int index               - object bind index
 *      sqlite3_stmt *statement - statement which will be bound to object
 * @return binding result code
 */
- (int)bindObject:(id)object atIndex:(int)index inStatement:(sqlite3_stmt*)statement {
    int returnCode = SQLITE_OK;
    if(!object || [object isMemberOfClass:[NSNull class]]){
        returnCode = sqlite3_bind_null(statement, index);
    } else if([object isMemberOfClass:[NSData class]]){
        returnCode = sqlite3_bind_blob(statement, index, [object bytes], [object length], SQLITE_STATIC);
    } else if([object isMemberOfClass:[UIImage class]]){
        NSData *imageData = UIImagePNGRepresentation(object);
        if(imageData) returnCode = sqlite3_bind_blob(statement, index, [imageData bytes], [imageData length], SQLITE_STATIC);
        else returnCode = sqlite3_bind_null(statement, index);
    } else if([object isMemberOfClass:[NSDate class]]){
        returnCode = sqlite3_bind_double(statement, index, [object timeIntervalSince1970]);
    } else if([object isMemberOfClass:[NSString class]]){
        returnCode = sqlite3_bind_text(statement, index, [object UTF8String], -1, SQLITE_STATIC);
    } else if([object isMemberOfClass:[NSNumber class]]){
        const char *dataType = [object objCType];
        if(strcmp(dataType, @encode(BOOL)) == 0){
            if(isdigit([object charValue]==0)) {
                if(dbEncoding==DBCDatabaseEncodingUTF8)
                    returnCode = sqlite3_bind_text(statement, index, [[object stringValue] UTF8String], -1, SQLITE_STATIC);
                else if(dbEncoding==DBCDatabaseEncodingUTF16) 
                    returnCode = sqlite3_bind_text16(statement, index, [[object stringValue] cStringUsingEncoding:NSUTF16StringEncoding], -1, SQLITE_STATIC);
            } else if([object intValue] > 1) {
                if(dbEncoding==DBCDatabaseEncodingUTF8)
                    returnCode = sqlite3_bind_text(statement, index, [[object stringValue] UTF8String], -1, SQLITE_STATIC);
                else if(dbEncoding==DBCDatabaseEncodingUTF16) 
                    returnCode = sqlite3_bind_text16(statement, index, [[object stringValue] cStringUsingEncoding:NSUTF16StringEncoding], -1, SQLITE_STATIC);
            } else returnCode = sqlite3_bind_int(statement, index, [object boolValue]?1:0);
        } else if(strcmp(dataType, @encode(double)) == 0){
            returnCode = sqlite3_bind_double(statement, index, [object doubleValue]);
        } else if(strcmp(dataType, @encode(float)) == 0){
            returnCode = sqlite3_bind_double(statement, index, [object floatValue]);
        } else if(strcmp(dataType, @encode(int)) == 0 || strcmp(dataType, @encode(long)) == 0 || 
                  strcmp(dataType, @encode(short)) == 0){
            int64_t dataValue = [object longLongValue];
            if(dataValue >= INT32_MIN && dataValue <= INT32_MAX) 
                returnCode = sqlite3_bind_int(statement, index, dataValue);
            else returnCode = sqlite3_bind_int64(statement, index, dataValue);
        } else if(strcmp(dataType, @encode(long long)) == 0 || strcmp(dataType, @encode(unsigned int)) == 0 || 
                  strcmp(dataType, @encode(unsigned long)) == 0 || strcmp(dataType, @encode(unsigned long long)) == 0){
            int64_t dataValue = [object longLongValue];
            if(dataValue >= INT32_MIN && dataValue <= INT32_MAX) 
                returnCode = sqlite3_bind_int(statement, index, dataValue);
            else returnCode = sqlite3_bind_int64(statement, index, dataValue);
        } else {
            returnCode = sqlite3_bind_text(statement, index, [[object description] UTF8String], -1, SQLITE_STATIC);
        }
    } else {
        returnCode = sqlite3_bind_text(statement, index, [[object description] UTF8String], -1, SQLITE_STATIC);
    }
    return returnCode;
}

#pragma mark Statements caching

/**
 * Add statement into the statements cache
 * @parameters
 *      DBCStatement *statement - initialized and configured DBCStatement instance
 */
- (void)addStatementToCache:(DBCStatement*)statement  {
    const char *cSQL = sqlite3_sql([statement statement]);
    if(cSQL != NULL) {
        NSString *sql = [NSString stringWithCString:cSQL encoding:NSUTF8StringEncoding];
        if(sql && [self isStatementsCachingEnabled]) [cachedStatementsList setValue:statement forKey:[sql md5]];
    }
}

/**
 * Remove DBCSatement from statements cache
 * @parameters
 *      DBCStatement *statement - initialized and configured DBCStatement instance
 */
- (void)removeStatementFromChache:(DBCStatement*)statement {
    const char *cSQL = sqlite3_sql([statement statement]);
    if(cSQL != NULL && cachedStatementsList != nil) {
        NSString *sql = [NSString stringWithCString:cSQL encoding:NSUTF8StringEncoding];
        DBCLockLogger(@"[DBC:StatementCache] Waiting for Lock: %@ (Line: %d)", [sql md5], __LINE__);
        [queryLock lock];
        DBCLockLogger(@"[DBC:StatementCache] Lock acquired: %@ (Line: %d)", [sql md5], __LINE__);
        if(cachedStatementsList) [cachedStatementsList removeObjectForKey:[sql md5]];
        [queryLock unlock];
        DBCLockLogger(@"[DBC:StatementCache] Relinquished from previously acquired lock: %@ (Line: %d)", [sql md5], __LINE__);
    }
}

/**
 * Retrieve cached statement for specific SQL query
 * @return cached DBCStatement if it was added before
 */
- (DBCStatement*)getCachedStatementFor:(NSString*)sqlRequest {
    if(sqlRequest==nil || cachedStatementsList == nil) return nil;
    DBCLockLogger(@"[DBC:StatementCache] Waiting for Lock: %@ (Line: %d)", [sqlRequest md5], __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:StatementCache] Lock acquired: %@ (Line: %d)", [sqlRequest md5], __LINE__);
    DBCStatement *statement = [cachedStatementsList valueForKey:[sqlRequest md5]];
    [queryLock unlock];
    DBCLockLogger(@"[DBC:StatementCache] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlRequest md5], __LINE__);
    return statement;
}

#pragma mark DBCDatabase private getter/setter methods

/**
 * Get whether current database connection opened in read-only mode or not
 * @return YES if database connection opened in 'read-only' mode in other case NO
 */
- (BOOL)isDatabaseConnectionForReadOnlyMode {
    return dbFlags&SQLITE_OPEN_READONLY;
}

/**
 * Get SQL statement format style
 * @parameters
 *      NSString *sqlStatement - SQL statement
 * @return SQL statement format style
 */
- (SQLStatementFromat)getSQLStatementType:(NSString*)sqlStatement {
    SQLStatementFromat format = SQLStatementFromatUnknown;
    if(sqlStatement == nil) return format;
    int i, sqlStatementLength = [sqlStatement length];
    unichar lastChar = '\0';
    BOOL isLiteral = NO;
    BOOL isNamed = NO;
    for (i = 0; i < sqlStatementLength; i++) {
        unichar currentChar = [sqlStatement characterAtIndex:i];
        if(!isLiteral && !isNamed && (lastChar==':' || lastChar=='@' || lastChar=='$') && currentChar!=' ' && !isdigit(currentChar)) isNamed = YES;
        else if(isNamed && currentChar==' ') isNamed = NO;
        if(!isLiteral && currentChar=='\'') isLiteral = YES;
        else if(isLiteral && currentChar=='\'') isLiteral = NO;
        if (!isLiteral && lastChar == '%') {
            if(currentChar=='@'||currentChar=='d'||currentChar=='i'||currentChar=='u'||currentChar=='f'||currentChar=='g'||currentChar=='s'||
               currentChar=='S'||currentChar=='c'||currentChar=='C') {
                format = SQLStatementFromatNSStringFormat;
            } else if(currentChar=='l') {
                if(i+2<sqlStatementLength && [sqlStatement characterAtIndex:(i+1)]=='l' && ([sqlStatement characterAtIndex:(i+2)]=='d' || [sqlStatement characterAtIndex:(i+2)]=='u'))
                    format = SQLStatementFromatNSStringFormat;
            }
        } else if (!isLiteral && lastChar == '?') {
            if(currentChar==' ' || !isdigit(currentChar)) format = SQLStatementFromatAnonymousToken;
            else if(isdigit(currentChar)) format = SQLStatementFromatIndexedToken;
        } else if (!isLiteral && isNamed) format = SQLStatementFromatNamedToken;
        if(format != SQLStatementFromatUnknown) break;
        lastChar = currentChar;
    }
    return format;
}

/**
 * Extract statements list from SQL statement
 * @parameters
 *      NSString *sql - SQL query string
 * @return commands list
 */
- (NSArray*)getSQLStatementsSequence:(NSString*)sql {
    NSMutableArray *commandsList = [NSMutableArray array];
    NSArray *splittedCommands = [sql componentsSeparatedByString:@";"];
    int i, count = [splittedCommands count];
    for (i=0; i<count; i++) {
        if([[[splittedCommands objectAtIndex:i] trimmedString] length] < 5) continue;
        [commandsList addObject:[[[splittedCommands objectAtIndex:i] trimmedString] stringByAppendingString:@";"]];
    }
    return commandsList;
}

/**
 * Get parameters token count in SQL statement
 * @parameters
 *      NSString* sql - SQL statement
 * @return count of parameters token
 */
- (int)getSQLStatementParametersCount:(NSString*)sql {
    int tokensCount = 0;
    unichar lastChar = '\0';
    BOOL isLiteral = NO;
    int i, count = [sql length];
    SQLStatementFromat sqlStatementFormat = [self getSQLStatementType:sql];
    if(sqlStatementFormat==SQLStatementFromatIndexedToken){
        for (i = 0; i < count; i++) {
            unichar currentChar = [sql characterAtIndex:i];
            if(!isLiteral && currentChar=='\'') isLiteral = YES;
            else if(isLiteral && currentChar=='\'') isLiteral = NO;
            if (!isLiteral && lastChar == '?' && currentChar != ' ' && isdigit(currentChar)) tokensCount++;
            lastChar = currentChar;
        }
    }
    return tokensCount;
}

/**
 * Get parameters mapping information (values and mapping indices)
 * @parameters
 *      NSString *sqlStatement - SQL statement
 *      va_list parameters     - list of parameters
 * @return parameters mapping data
 */
- (NSDictionary*)getParametersBindingMapData:(NSString*)sqlStatement vaList:(va_list)parameters {
    NSMutableDictionary *mappingData = [NSMutableDictionary dictionary];
    NSMutableString *newSQLStatement = [NSMutableString string];
    NSMutableArray *parsedParameters = [NSMutableArray array];
    NSMutableArray *parsedParametersMap = [NSMutableArray array];
    SQLStatementFromat sqlStatementFormat = [self getSQLStatementType:sqlStatement];
    int i, count = [sqlStatement length];
    int tokensCount = 0;
    int charToIgnore = 0;
    int countOfRequiredBindingParameters = 0;
    unichar lastChar = '\0';
    BOOL isLiteral = NO;
    BOOL foundToken = NO;
    BOOL shouldParseValues = YES;
    BOOL shouldReadDataFromVA = YES;
    NSRange tokenRange = NSMakeRange(NSNotFound, 0);
    NSCharacterSet *tokenTerminatorsCharset = [NSCharacterSet characterSetWithCharactersInString:@", );"];
    if(sqlStatementFormat==SQLStatementFromatNSStringFormat){
        for (i = 0; i < count; i++) {
            unichar currentChar = [sqlStatement characterAtIndex:i];
            if(!isLiteral && currentChar=='\'') isLiteral = YES;
            else if(isLiteral && currentChar=='\'') isLiteral = NO;
            foundToken = NO;
            if (!isLiteral && lastChar == '%') {
                NSRange tokenTerminationCharRange = [sqlStatement rangeOfCharacterFromSet:tokenTerminatorsCharset options:NSCaseInsensitiveSearch
                                                                                    range:NSMakeRange(i, count-i)];
                tokenRange.location = i-1;
                if(tokenTerminationCharRange.location != NSNotFound)
                    tokenRange.length = (tokenTerminationCharRange.location-i+1);
                else tokenRange.length = (count-i+1);
                if(currentChar=='@'||currentChar=='p') {
                    id object = nil;
                    Class itemClass = nil;
                    if(tokensCount == 0) itemClass = [self getVAItemClass:parameters];
                    if(itemClass != nil){
                        if([itemClass isSubclassOfClass:[NSArray class]]){
                            object = va_arg(parameters, NSArray*);
                            shouldParseValues = NO;
                            [parsedParameters addObjectsFromArray:object];
                        } else object = va_arg(parameters, id);
                    } else object = va_arg(parameters, id);
                    foundToken = YES;
                    if(object != nil && shouldParseValues) [parsedParameters addObject:object];
                } else if(currentChar=='d'||currentChar=='i') {
                    foundToken = YES;
                    if(shouldParseValues) [parsedParameters addObject:[NSNumber numberWithInt:va_arg(parameters, int)]];
                } else if(currentChar=='u') {
                    foundToken = YES;
                    if(shouldParseValues) [parsedParameters addObject:[NSNumber numberWithUnsignedInt:va_arg(parameters, unsigned int)]];
                } else if(currentChar=='f'||currentChar=='g') {
                    foundToken = YES;
                    if(shouldParseValues) [parsedParameters addObject:[NSNumber numberWithDouble:va_arg(parameters, double)]];
                } else if(currentChar=='s') {
                    foundToken = YES;
                    if(shouldParseValues) [parsedParameters addObject:[NSString stringWithCString:va_arg(parameters, char*) encoding:NSUTF8StringEncoding]];
                } else if(currentChar=='S') {
                    foundToken = YES;
                    if(shouldParseValues) [parsedParameters addObject:[NSString stringWithFormat:@"%C", va_arg(parameters, int)]];
                } else if(currentChar=='c') {
                    foundToken = YES;
                    if(shouldParseValues) [parsedParameters addObject:[NSString stringWithFormat:@"%c", va_arg(parameters, int)]]; 
                } else if(currentChar=='C') {
                    foundToken = YES;
                    if(shouldParseValues) [parsedParameters addObject:[NSString stringWithFormat:@"%C", va_arg(parameters, int)]]; 
                } else if(currentChar=='h'){
                    if(i+1<count && ([sqlStatement characterAtIndex:(i+1)]=='i' || [sqlStatement characterAtIndex:(i+1)]=='x') || 
                       [sqlStatement characterAtIndex:(i+1)]=='o') {
                        foundToken = YES;
                        if(shouldParseValues) [parsedParameters addObject:[NSNumber numberWithShort:va_arg(parameters, int)]];
                    } else if(i+1<count && [sqlStatement characterAtIndex:(i+1)]=='u'){
                        foundToken = YES;
                        if(shouldParseValues) [parsedParameters addObject:[NSNumber numberWithUnsignedShort:va_arg(parameters, unsigned int)]];
                    }
                } else if(currentChar=='l'){
                    if(i+1<count && [sqlStatement characterAtIndex:(i+1)]=='i'){
                        foundToken = YES;
                        if(shouldParseValues) [parsedParameters addObject:[NSNumber numberWithLong:va_arg(parameters, long int)]];
                    } else if(i+2<count && [sqlStatement characterAtIndex:(i+1)]=='l' && [sqlStatement characterAtIndex:(i+2)]=='d') {
                        foundToken = YES;
                        if(shouldParseValues) [parsedParameters addObject:[NSNumber numberWithLongLong:va_arg(parameters, long long)]];
                    } else if(i+2<count && [sqlStatement characterAtIndex:(i+1)]=='l' && [sqlStatement characterAtIndex:(i+2)]=='u') {
                        foundToken = YES;
                        if(shouldParseValues) [parsedParameters addObject:[NSNumber numberWithUnsignedLongLong:va_arg(parameters, unsigned long long)]];
                    }
                }
                if(foundToken){
                    tokensCount++;
                    NSNumber *index = [NSNumber numberWithInt:[parsedParameters indexOfObject:[parsedParameters lastObject]]];
                    if (![parsedParametersMap containsObject:index]) countOfRequiredBindingParameters++;
                    [parsedParametersMap addObject:index];
                    NSString *tokenReplacement = [NSString stringWithFormat:@"?%i", tokensCount];
                    charToIgnore = tokenRange.length>[tokenReplacement length]?(tokenRange.length-([tokenReplacement length]>1?[tokenReplacement length]-1:[tokenReplacement length])):0;
                    [newSQLStatement replaceCharactersInRange:NSMakeRange([newSQLStatement length]-1, 1) withString:tokenReplacement];
                }
            } else {
                if(charToIgnore == 0) [newSQLStatement appendFormat:@"%c", currentChar];
                if(charToIgnore > 0) charToIgnore--;
            }
            lastChar = currentChar;
        }
        if([parsedParametersMap count] < countOfRequiredBindingParameters) return nil;
    } else if(sqlStatementFormat==SQLStatementFromatAnonymousToken){
        for (i = 0; i < count; i++) {
            unichar currentChar = [sqlStatement characterAtIndex:i];
            if(!isLiteral && currentChar=='\'') isLiteral = YES;
            else if(isLiteral && currentChar=='\'') isLiteral = NO;
            foundToken = NO;
            if (!isLiteral && lastChar == '?' && (currentChar == ',' || currentChar == ' ' || currentChar == ')' || currentChar == ';')) {
                id object = nil;
                Class itemClass = nil;
                if(tokensCount == 0) itemClass = [self getVAItemClass:parameters];
                if(itemClass != nil){
                    if([itemClass isSubclassOfClass:[NSArray class]]){
                        object = va_arg(parameters, NSArray*);
                        shouldParseValues = NO;
                        [parsedParameters addObjectsFromArray:object];
                    } else if(shouldReadDataFromVA) object = va_arg(parameters, id);
                } else if(shouldReadDataFromVA) object = va_arg(parameters, id);
                if(object == nil) shouldReadDataFromVA = NO;
                if(object != nil && shouldParseValues) [parsedParameters addObject:object];
                tokensCount++;
                NSString *tokenReplacement = [NSString stringWithFormat:@"?%i", tokensCount];
                [newSQLStatement replaceCharactersInRange:NSMakeRange([newSQLStatement length]-1, 1) withString:tokenReplacement];
                NSNumber *index = [NSNumber numberWithInt:[parsedParameters indexOfObject:[parsedParameters lastObject]]];
                if (![parsedParametersMap containsObject:index]) countOfRequiredBindingParameters++;
                [parsedParametersMap addObject:index];
            } else {
                if(charToIgnore == 0) [newSQLStatement appendFormat:@"%c", currentChar];
                if(charToIgnore > 0) charToIgnore--;
            }
            lastChar = currentChar;
        }
        if([parsedParameters count] < countOfRequiredBindingParameters)  return nil;
    } else if(sqlStatementFormat==SQLStatementFromatIndexedToken){
        [newSQLStatement appendString:sqlStatement];
        for (i = 0; i < count; i++) {
            unichar currentChar = [sqlStatement characterAtIndex:i];
            if(!isLiteral && currentChar=='\'') isLiteral = YES;
            else if(isLiteral && currentChar=='\'') isLiteral = NO;
            foundToken = NO;
            if (!isLiteral && lastChar == '?' && currentChar != ' ' && isdigit(currentChar)) {
                id object = nil;
                Class itemClass = nil;
                if(tokensCount == 0) itemClass = [self getVAItemClass:parameters];
                if(itemClass != nil){
                    if([itemClass isSubclassOfClass:[NSArray class]]){
                        object = va_arg(parameters, NSArray*);
                        shouldParseValues = NO;
                        [parsedParameters addObjectsFromArray:object];
                    } else if(shouldReadDataFromVA) object = va_arg(parameters, id);
                } else if(shouldReadDataFromVA) object = va_arg(parameters, id);
                if(object == nil) shouldReadDataFromVA = NO;
                if(object != nil && shouldParseValues) [parsedParameters addObject:object];
                NSRange tokenTerminationCharRange = [sqlStatement rangeOfCharacterFromSet:tokenTerminatorsCharset options:NSCaseInsensitiveSearch
                                                                                    range:NSMakeRange(i, count-i)];
                int bindingValueIndex = -1;
                if(tokenTerminationCharRange.location != NSNotFound)
                    bindingValueIndex = [[sqlStatement substringWithRange:NSMakeRange(i, tokenTerminationCharRange.location-i)] intValue]-1;
                else bindingValueIndex = [[sqlStatement substringWithRange:NSMakeRange(i, count-i)] intValue]-1;
                if (![parsedParametersMap containsObject:[NSNumber numberWithInt:bindingValueIndex]]) countOfRequiredBindingParameters++;
                [parsedParametersMap addObject:[NSNumber numberWithInt:bindingValueIndex]];
                tokensCount++;
            }
            lastChar = currentChar;
        }
        if([parsedParameters count] < countOfRequiredBindingParameters)  return nil;
    } else if(sqlStatementFormat==SQLStatementFromatNamedToken){
        NSMutableDictionary *namesToIndicesMap = [NSMutableDictionary dictionary];
        BOOL parsingFromVA = NO;
        for (i = 0; i < count; i++) {
            unichar currentChar = [sqlStatement characterAtIndex:i];
            if(!isLiteral && currentChar=='\'') isLiteral = YES;
            else if(isLiteral && currentChar=='\'') isLiteral = NO;
            foundToken = NO;
            if (!isLiteral && (lastChar == ':' || lastChar == '@' || lastChar == '$') && !isdigit(currentChar) && 
                (currentChar != ',' && currentChar != ' ' && currentChar != ')' && currentChar != ';' && currentChar != '\'')) {
                id object = nil;
                Class itemClass = nil;
                if(tokensCount == 0) itemClass = [self getVAItemClass:parameters];
                if(itemClass != nil){
                    if([itemClass isSubclassOfClass:[NSArray class]]){
                        object = va_arg(parameters, NSArray*);
                        if([object count]%2!=0) return nil;
                        int k, count2 = [object count];
                        for (k=1; k<count2; k+=2) {
                            NSString *key = [object objectAtIndex:k];
                            id value = [object objectAtIndex:(k-1)];
                            [parsedParameters addObject:value];
                            [namesToIndicesMap setValue:[NSNumber numberWithInt:[parsedParameters indexOfObject:value]] forKey:key];
                        }
                    } else if([itemClass isSubclassOfClass:[NSDictionary class]]){
                        object = va_arg(parameters, NSDictionary*);
                        NSArray *listOfKeys = [object allKeys];
                        int k, count2 = [listOfKeys count];
                        for (k=0; k<count2; k++) {
                            NSString *key = [listOfKeys objectAtIndex:k];
                            id value = [object valueForKey:key];
                            [parsedParameters addObject:value];
                            [namesToIndicesMap setValue:[NSNumber numberWithInt:[parsedParameters indexOfObject:value]] forKey:key];
                        }
                    } else parsingFromVA = YES;
                } else if(tokensCount == 0) parsingFromVA = YES;
                if(parsingFromVA){
                    parsingFromVA = NO;
                    va_list params;
                    va_copy(params, parameters);
                    NSMutableArray *parametersList = [NSMutableArray array];
                    for (id param = sqlStatement; shouldReadDataFromVA && param != nil; param = va_arg(params, id)){
                        if(param == nil) shouldReadDataFromVA = NO;
                        if(shouldReadDataFromVA && param != nil) [parametersList addObject:param];
                    }
                    va_end(params);
                    [parametersList removeObjectAtIndex:0];
                    if([parametersList count]%2!=0) return nil;
                    int k, count2 = [parametersList count];
                    for (k=1; k<count2; k+=2) {
                        NSString *key = [parametersList objectAtIndex:k];
                        id value = [parametersList objectAtIndex:(k-1)];
                        [parsedParameters addObject:value];
                        [namesToIndicesMap setValue:[NSNumber numberWithInt:[parsedParameters indexOfObject:value]] forKey:key];
                    }
                }
                tokensCount++;
                NSRange tokenTerminationCharRange = [sqlStatement rangeOfCharacterFromSet:tokenTerminatorsCharset options:NSCaseInsensitiveSearch
                                                                                    range:NSMakeRange(i, count-i)];
                NSString *tokenName = nil;
                if(tokenTerminationCharRange.location != NSNotFound)
                    tokenName = [sqlStatement substringWithRange:NSMakeRange(i, tokenTerminationCharRange.location-i)];
                else tokenName = [sqlStatement substringWithRange:NSMakeRange(i, count-i)];
                int bindingValueIndex = [[namesToIndicesMap valueForKey:tokenName] intValue];
                tokenRange.length = [tokenName length];
                NSString *tokenReplacement = [NSString stringWithFormat:@"?%i", (bindingValueIndex+1)];
                charToIgnore = tokenRange.length>[tokenReplacement length]?(tokenRange.length-([tokenReplacement length]>1?[tokenReplacement length]-1:[tokenReplacement length])):0;
                [newSQLStatement replaceCharactersInRange:NSMakeRange([newSQLStatement length]-1, 1) withString:tokenReplacement];
                if (![parsedParametersMap containsObject:[NSNumber numberWithInt:bindingValueIndex]]) countOfRequiredBindingParameters++;
                [parsedParametersMap addObject:[NSNumber numberWithInt:bindingValueIndex]];
            } else {
                if(charToIgnore == 0) [newSQLStatement appendFormat:@"%c", currentChar];
                if(charToIgnore > 0) charToIgnore--;
            }
            lastChar = currentChar;
        }
        if([parsedParameters count] < countOfRequiredBindingParameters)  return nil;
    }
    [mappingData setValue:([newSQLStatement length]==0?sqlStatement:newSQLStatement) forKey:PREPARED_SQL_STATEMENT];
    [mappingData setValue:parsedParameters forKey:PARAMETERS_LIST];
    [mappingData setValue:parsedParametersMap forKey:PARAMETERS_MAPPING_INFORMATION];
    return mappingData;
}

/**
 * Get whether statements list contains at least one of TCL commands
 * @return whether statements list contains TCL commands or not
 */
- (BOOL)SQLStatementsSequenceContainsTCL:(NSArray*)commandsList {
    if(!commandsList) return NO;
    if([commandsList count] == 0) return NO;
    BOOL containsTCL = NO;
    int i, count = [commandsList count];
    for (i=0; i<count; i++) {
        NSString *lowerCasedCommand = [[[[commandsList objectAtIndex:i] lowercaseString] stringByReplacingOccurrencesOfString:@";" withString:@""] trimmedString];
        if([listOfPossibleTCLCommands containsObject:lowerCasedCommand]){
            containsTCL = YES;
            break;
        }
    }
    return containsTCL;
}

/**
 * Get class of current item in variable list
 * @return class of parameter stored in variable list
 */
- (Class)getVAItemClass:(va_list)parameters {
    Class class = nil;
    va_list parametersCopy;
    va_copy(parametersCopy, parameters);
    id object = va_arg(parametersCopy, id);
    if([object respondsToSelector:@selector(initWithArray:)]) class = [NSArray class];
    if([object respondsToSelector:@selector(setArray:)]) class = [NSMutableArray class];
    if([object respondsToSelector:@selector(initWithDictionary:)]) class = [NSDictionary class];
    if([object respondsToSelector:@selector(setDictionary:)]) class = [NSMutableDictionary class];
    if([object respondsToSelector:@selector(initWithString:)]) class = [NSString class];
    va_end(parametersCopy);
    return class;
}

@end
