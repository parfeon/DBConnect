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
#import "sqlite3lib.h"

#define DBCUseDebugLogger 1
#define DBCUseLockLogger 1

#define DBCReleaseObject(__OBJECT__) if(__OBJECT__!=nil){[__OBJECT__ release], __OBJECT__ = nil; }
#define DBCDatabaseTransactionLockNameFromEnum(__LOCK_ENUM__) ({\
    NSString *lockName = nil;\
    if(__LOCK_ENUM__==DBCDatabaseAutocommitModeDeferred) lockName=@"DEFERRED";\
    if(__LOCK_ENUM__==DBCDatabaseAutocommitModeImmediate) lockName=@"IMMEDIATE";\
    if(__LOCK_ENUM__==DBCDatabaseAutocommitModeExclusive) lockName=@"EXCLUSIVE";\
    lockName;\
})

#define DBCDatabaseEncodedSQLiteError(__ENCODING__)({\
    const char *cErrorMsg = __ENCODING__==DBCDatabaseEncodingUTF16?sqlite3_errmsg16(dbConnection):sqlite3_errmsg(dbConnection);\
    NSString *errorMsg = nil;\
    if(cErrorMsg!=NULL)\
        errorMsg = [NSString stringWithCString:cErrorMsg \
                                      encoding:(dbEncoding==DBCDatabaseEncodingUTF16?NSUTF16StringEncoding:NSUTF8StringEncoding)];\
    errorMsg;\
})

#if DBCUseDebugLogger
#define DBCDebugLogger(...) NSLog(__VA_ARGS__)
#else
#define DBCDebugLogger(...)
#endif

#if DBCUseLockLogger
#define DBCLockLogger(...) NSLog(__VA_ARGS__)
#else
#define DBCLockLogger(...)
#endif

//
#define VAListToNSArray(LAST_PARAMETER)({\
    NSMutableArray *array = [NSMutableArray array];\
    id object;\
    char *charObject;\
    int intObject;\
    va_list args;\
    va_list charsArgs;\
    va_list intArgs;\
    va_start(args, LAST_PARAMETER);\
    va_copy(charsArgs, args);\
    va_copy(intArgs, args);\
    while((object = va_arg(args, id))) [array addObject:object];\
    va_end(args);\
    [NSArray arrayWithArray:array];\
})

@interface DBCDatabase (private)

- (BOOL)isDatabaseConnectionForReadOnlyMode;

- (BOOL)containsNSStringFormatSpecifier:(NSString*)testString;

- (NSArray*)extractCommandsSequence:(NSString*)sql;
- (NSArray*)extractCommandParametersMap:(NSString*)sql;
- (NSArray*)extractBindParametersFrom:(NSString*)sql andVAList:(va_list)parameters;
- (BOOL)commandSequenceContainsTCL:(NSArray*)commandsList;

- (NSArray*)parametersBindMapFromNSStringFormat:(NSString*)format vaParameters:(va_list)vaParametersList;
- (BOOL)bindStatement:(sqlite3_stmt*)statement toParameters:(NSArray*)parameters;
- (int)bindObject:(id)object atIndex:(int)index inStatement:(sqlite3_stmt*)statement;
- (void)addStatementToCache:(DBCStatement*)statement;
- (void)removeStatementFromChache:(DBCStatement*)statement;
- (DBCStatement*)getCachedStatementFor:(NSString*)sqlRequest;

@end

/// int sqlite3_data_count(sqlite3_stmt *pStmt); - использовать для того, что-бы убедится что данных больше не вернул запрос
/// const char *sqlite3_sql(sqlite3_stmt *pStmt); - можно использовать для получения SQL запроса из скомпилированного запроса
/*  int sqlite3_stmt_status(sqlite3_stmt*, int op,int resetFlg); - использовать вместе с флагами, что-бы проанализировать работу запроса
 SQLITE_STMTSTATUS_FULLSCAN_STEP
 This is the number of times that SQLite has stepped forward in a table as part of a full table scan. Large numbers for this counter may indicate opportunities for performance improvement through careful use of indices.
 SQLITE_STMTSTATUS_SORT
 This is the number of sort operations that have occurred. A non-zero value in this counter may indicate an opportunity to improvement performance through careful use of indices.
 SQLITE_STMTSTATUS_AUTOINDEX
 This is the number of rows inserted into transient indices that were created automatically in order to help joins run faster. A non-zero value in this counter may indicate an opportunity to improvement performance by adding permanent indices that do not need to be reinitialized each time the statement is run.
 */

@implementation DBCDatabase

@synthesize dbBusyRequestRetryCount, statementCachingEnabled, createTransactionOnSQLSequences;
@synthesize rollbackSQLSequenceTransactionOnError, defaultSQLSequencesTransactinoLock, recentErrorCode, recentError;

#pragma mark DBCDatabase instance initialization

/**
 * Initiate DBCDatabase by opening database, which exists at 'dbFilePath' 
 * @parameters
 *      NSString *dbFilePath - database file path
 * @return autoreleased DBCDatabase instance
 */
+ (id)databaseWithPath:(NSString*)dbFilePath defaultEncoding:(DBCDatabaseEncoding)encoding {
    return [[[[self class] alloc] initWithPath:dbFilePath defaultEncoding:encoding] autorelease];
}

/**
 * Create and initiate DBCDatabase from database, which will be created at
 * specified path and SQL query commands list from provided file. Database will
 * be created only if this is new file
 * @oarameters
 *      NSString* sqlQeryListPath         - path to file with list of SQL query commands list
 *      NSString* databasePath            - database target location
 *      BOOL      contineOnEvaluateErrors - should continue creation on evaluate 
 *                                          update request error
 * WARNING: databasePath can't be same as application bundle, use application
 *          Documents folder instead
 * @return autoreleased DBCDatabase instance
 */
+ (id)databaseFromFile:(NSString*)sqlQeryListPath atPath:(NSString*)databasePath defaultEncoding:(DBCDatabaseEncoding)encoding contineOnEvaluateErrors:(BOOL)contineOnEvaluateErrors {
    return [[[[self class] alloc] createDatabaseFromFile:sqlQeryListPath atPath:databasePath defaultEncoding:encoding
                                 contineOnEvaluateErrors:contineOnEvaluateErrors] autorelease];
}

/**
 * Initiate DBCDatabase by opening database, which exists at 'dbFilePath' 
 * @parameters
 *      NSString *dbFilePath - database file path
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
        statementCachingEnabled = YES;
        dbBusyRequestRetryCount = 0;
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
 * Create and initiate DBCDatabase from database, which will be created at
 * specified path and SQL query commands list from provided file. Database will
 * be created only if this is new file
 * @oarameters
 *      NSString* sqlQeryListPath         - path to file with list of SQL query commands list
 *      NSString* databasePath            - database target location
 *      BOOL      contineOnEvaluateErrors - should continue creation on evaluate 
 *                                          update request error
 * WARNING: databasePath can't be same as application bundle, use application
 *          Documents folder instead
 * @return DBCDatabase instance
 */
- (id)createDatabaseFromFile:(NSString*)sqlQeryListPath atPath:(NSString*)databasePath defaultEncoding:(DBCDatabaseEncoding)encoding contineOnEvaluateErrors:(BOOL)contineOnEvaluateErrors {
    if ((self = [self initWithPath:databasePath defaultEncoding:encoding])) {
        [self open];
        if(dbConnectionOpened && sqlQeryListPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:sqlQeryListPath]){
            NSLog(@"PATH TO SQL QUERY LIST FILE: %@", sqlQeryListPath);
            struct sqlite3lib_error execError = {"", -1, -1};
            if(dbEncoding==DBCDatabaseEncodingUTF8) 
                evaluateQueryFromFile(dbConnection, [sqlQeryListPath UTF8String], contineOnEvaluateErrors, &execError);
            else if(dbEncoding==DBCDatabaseEncodingUTF16)
                evaluateQueryFromFile(dbConnection, [sqlQeryListPath cStringUsingEncoding:NSUTF16StringEncoding], contineOnEvaluateErrors, &execError);
            if(execError.errorCode != -1 && !contineOnEvaluateErrors){
                if([[NSFileManager defaultManager] fileExistsAtPath:databasePath]){
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:databasePath error:&error];
                    if(error!=nil) DBCDebugLogger(@"[DBC:ERROR] %@", error);
                }
                [self release];
                return nil;
            } else if(execError.errorCode != -1){
                DBCReleaseObject(recentError);
                recentErrorCode = execError.errorCode;
                recentError = [[DBCError errorWithErrorCode:execError.errorCode forFilePath:sqlQeryListPath
                                      additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                DBCDebugLogger(@"[DBC:ERROR] %@", recentError);
            }
        }
    }
    return self;
}

#pragma mark DBCDatabase getter/setter methods

/**
 * Reloaded statement caching enable method
 * @parameters
 *      BOOL sCacheStatements - caching flag
 */
- (void)setStatementCachingEnabled:(BOOL)sCacheStatements {
    DBCLockLogger(@"[DBC:StatementCache] Waiting for Lock (Line: %d)", __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:Update] Lock acquired (Line: %d)", __LINE__);
    if(!sCacheStatements && cachedStatementsList) {
        DBCReleaseObject(cachedStatementsList);
    } else if(sCacheStatements && cachedStatementsList==nil) cachedStatementsList = [[NSMutableDictionary alloc] init];
    statementCachingEnabled = sCacheStatements;
    [queryLock unlock];
    DBCLockLogger(@"[DBC:Query] Relinquished from previously acquired lock (Line: %d)", __LINE__);
}

#pragma mark Database open and close

/**
 * Open new database connection to database file at path, which was provided in init
 * Connection will be opened with 'readwrite|create' right
 */
- (BOOL)open {
    return [self openWithFlags:SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE];
 }

/**
 * Open new database connection to database file at path, which was provided in init
 * Connection will be opened with 'readonly' rights
 */
- (BOOL)openReadonly {
    return [self openWithFlags:SQLITE_OPEN_READONLY];
}

/**
 * Close database connection to databse file if it was opened
 * @return whether database connection was successfully closed or not
 */
- (BOOL)close {
    if(dbConnection==NULL){
        dbConnectionOpened = NO;
        return YES;
    }
    int retryCount = 0;
    BOOL shouldRetry = NO;
    int returnCode = SQLITE_OK;
    do {
        shouldRetry = NO;
        returnCode = sqlite3_close(dbConnection);
        if(returnCode == SQLITE_LOCKED || returnCode == SQLITE_BUSY){
            if(dbBusyRequestRetryCount && retryCount < dbBusyRequestRetryCount){
                shouldRetry = YES;
                sqlite3_sleep(150);
            } else {
                DBCReleaseObject(recentError);
                recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                      additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                DBCDebugLogger(@"[DBC:ERROR] Database can't be closed due error: %@", recentError);
            }
        }
    } while (shouldRetry);
    
    if(returnCode==SQLITE_OK){
        dbConnection = NULL;
        dbConnectionOpened = NO;
    } else {
        DBCReleaseObject(recentError);
        recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                              additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
        DBCDebugLogger(@"[DBC:ERROR] Database can't be closed due error: %@", recentError);
    }
    return !dbConnectionOpened;
}

#pragma mark Query and update evaluate

/**
 * Evaluate prepared SQL statement on current database connection
 * @parameters
 *      NSString *sqlUpdate - SQL query command
 *               ...        - list of binding parameters
 * @return update request evaluate result
 */
- (BOOL)evaluateUpdateWithParameters:(NSString*)sqlUpdate, ... {
    NSLog(@"CONTAINS FORMAT SPECIFIER? %@", [self containsNSStringFormatSpecifier:sqlUpdate]?@"YES":@"NO");
    NSArray *parametersList = VAListToNSArray(sqlUpdate);
    return [self evaluateUpdate:sqlUpdate parameters:parametersList];
}

/**
 * Evaluate prepared SQL statement on current database connection
 * @parameters
 *      NSString *sqlUpdate - SQL query command
 * @return update request evaluate result
 */
- (BOOL)evaluateUpdate:(NSString*)sqlUpdate {
    return [self evaluateUpdate:sqlUpdate parameters:nil];
}

/**
 * Evaluate prepared SQL statement on current database connection
 * @parameters
 *      NSString *sqlUpdate - SQL query command
 *      NSArray *parameters - list of binding parameters
 * @return update request evaluate result
 */
- (BOOL)evaluateUpdate:(NSString*)sqlUpdate parameters:(NSArray*)parameters {
    NSLog(@"PARAMETERS: %@", parameters);
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
    BOOL shouldRetry = NO;
    int returnCode = SQLITE_OK;
    BOOL transactionUsed = NO;
    DBCStatement *dbcStatement = nil;
    sqlite3_stmt *statement = NULL;
    NSMutableArray *updateCommandsList = [[self extractCommandsSequence:sqlUpdate] mutableCopy];
    // Injecting TRANSACTION if required by flag
    if(createTransactionOnSQLSequences && [updateCommandsList count] > 1){
        transactionUsed = YES;
        if (![self commandSequenceContainsTCL:updateCommandsList]) {
            [updateCommandsList insertObject:[NSString stringWithFormat:@"BEGIN %@ TRANSACTION;",
                                              (DBCDatabaseTransactionLockNameFromEnum(defaultSQLSequencesTransactinoLock)!=nil?DBCDatabaseTransactionLockNameFromEnum(defaultSQLSequencesTransactinoLock):@"DEFERRED")] 
                                                                atIndex:0];
            [updateCommandsList addObject:@"COMMIT TRANSACTION;"];
        }
    }
    for (NSString *sql in updateCommandsList) {
        if(statementCachingEnabled){
            dbcStatement = [self getCachedStatementFor:sql];
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
                    if(dbBusyRequestRetryCount && retryCount < dbBusyRequestRetryCount){
                        shouldRetry = YES;
                        sqlite3_sleep(150);
                    } else {
                        DBCReleaseObject(recentError);
                        recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:nil 
                                              additionalInformation:DBCDatabaseEncodedSQLiteError(dbEncoding)] retain];
                        DBCLockLogger(@"[DBC:Update] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlUpdate md5], __LINE__);
                        sqlite3_finalize(statement);
                        [queryLock unlock];
                        return NO;
                    }
                }
            } while (shouldRetry);
            
            
        }
    }
    int queryParametersCount = sqlite3_bind_parameter_count(statement);
    int userDefinedParametersCount = [parameters count];
    if(queryParametersCount > userDefinedParametersCount){
        if(dbcStatement) [self removeStatementFromChache:dbcStatement];
        DBCDebugLogger(@"[DBC:ERROR] Update statement have parameters count different from provided by user: %@ (Line: %d)", sqlUpdate, __LINE__);
        DBCLockLogger(@"[DBC:Update] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlUpdate md5], __LINE__);
        [queryLock unlock];
        return NO;
    }
    
    [queryLock unlock];
    DBCLockLogger(@"[DBC:Update] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlUpdate md5], __LINE__);
}

/**
 * Evaluate prepared SQL statement on current database connection
 * @parameters
 *      NSString *sqlQuery - SQL query string
 */
- (id)evaluateQuery:(NSString*)sqlQuery {
    DBCLockLogger(@"[DBC:Query] Waiting for Lock: %@ (Line: %d)", [sqlQuery md5], __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:Query] Lock acquired: %@ (Line: %d)", [sqlQuery md5], __LINE__);
    
    if(!dbConnectionOpened && ![self open]){
        DBCLockLogger(@"[DBCDatabase:Query] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlQuery md5], __LINE__);
        [queryLock unlock];
        return nil;
    }
    
    [queryLock unlock];
    DBCLockLogger(@"[DBC:Query] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlQuery md5], __LINE__);
    return nil;
}

#pragma mark DBCDatabase memory management

- (void)dealloc {
    [self close];
    NSLog(@"DEALLOC");
    DBCReleaseObject(recentError);
    DBCReleaseObject(dbPath);
    DBCReleaseObject(queryLock);
    DBCReleaseObject(cachedStatementsList);
    DBCReleaseObject(listOfPossibleTCLCommands);
    DBCReleaseObject(listOfNSStringFormatSpecifiers);
    [super dealloc];
}

@end

#pragma mark DBCDatabase private functionality

@implementation DBCDatabase (private)

/**
 * Check whether current database connection opened in read-only mode or not
 * @return YES if database connection opened in 'read-only' mode in other case NO
 */
- (BOOL)isDatabaseConnectionForReadOnlyMode {
    return dbFlags&SQLITE_OPEN_READONLY;
}

/**
 * Check whether tested strgin containt NSString format specifiers or not
 * @return test result
 */
- (BOOL)containsNSStringFormatSpecifier:(NSString*)testString {
    BOOL testResult = NO;
    if(testString == nil) return testResult;
    int i, testStringLength = [testString length];
    unichar lastChar = '\0';
    BOOL isLiteral = NO;
    for (i = 0; i < testStringLength; i++) {
        unichar currentChar = [testString characterAtIndex:i];
        if(!isLiteral && currentChar=='\'') isLiteral = YES;
        else if(isLiteral && currentChar=='\'') isLiteral = NO;
        if (!isLiteral && lastChar == '%') {
            if(currentChar=='@'||currentChar=='d'||currentChar=='i'||currentChar=='u'||currentChar=='f'||currentChar=='g'||currentChar=='s'||
               currentChar=='S'||currentChar=='c'||currentChar=='C') {
                testResult = YES;
            } else if(currentChar=='l') {
                if(i+2<testStringLength && [testString characterAtIndex:(i+1)]=='l' && ([testString characterAtIndex:(i+2)]=='d' || [testString characterAtIndex:(i+2)]=='u'))
                    testResult = YES;
            } else if(currentChar=='L') if(i+1 < testStringLength && [testString characterAtIndex:(i+1)] == 'f') testResult = YES;
        }
        if(testResult) break;
        lastChar = currentChar;
    }
    return testResult;
}

/**
 * Extract commands list from SQL query string
 * @parameters
 *      NSString *sql - SQL query string
 * @return commands list
 */
- (NSArray*)extractCommandsSequence:(NSString*)sql {
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
 * Extract SQL command parameters placement map
 */
- (NSArray*)extractCommandParametersMap:(NSString*)sql {
    
}

/**
 * Extract parameters or binding from provided va_list based on SQL query string
 * @parameters
 *      NSString *sql      - SQL query string
 *      va_list parameters - list of parameters
 * @return extracted parameters
 */
- (NSArray*)extractBindParametersFrom:(NSString*)sql andVAList:(va_list)parameters {
    //NSMutableArray *extractedParameters = [NSMuta]
}

/**
 * Check whether list contains at least one of TCL commands
 */
- (BOOL)commandSequenceContainsTCL:(NSArray*)commandsList {
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
 * Build parameters bind map based on NSString format specifiers and based on them 
 * items data type
 * @parameters
 *      NSString *format         - formated string
 *      va_list vaParametersList - variable list of parameters
 * @return mapped parameters
 */
- (NSArray*)parametersBindMapFromNSStringFormat:(NSString*)format vaParameters:(va_list)vaParametersList {
    NSMutableArray *parametersBindMap = [NSMutableArray array];
    /*if(format == nil) return parametersBindMap;
    int i, formarStringLength = [format length];
    unichar lastChar = '\0';
    BOOL isLiteral = NO;
    for (i = 0; i < formarStringLength; i++) {
        id parameter = nil;
        unichar currentChar = [format characterAtIndex:i];
        if(!isLiteral && currentChar=='\'') isLiteral = YES;
        else if(isLiteral && currentChar=='\'') isLiteral = NO;
        if (!isLiteral && lastChar == '%') {
            if(currentChar=='@'||currentChar=='d'||currentChar=='i'||currentChar=='u'||currentChar=='f'||currentChar=='g'||currentChar=='s'||
               currentChar=='S'||currentChar=='c'||currentChar=='C') {
                testResult = YES;
            } else if(currentChar=='l') {
                if(i+2<formarStringLength && [format characterAtIndex:(i+1)]=='l' && ([format characterAtIndex:(i+2)]=='d' || [format characterAtIndex:(i+2)]=='u')){
                    testResult = YES;
                }
            } else if(currentChar=='L') if(i+1 < formarStringLength && [format characterAtIndex:(i+1)] == 'f') testResult = YES;
        }
        if(testResult) break;
        lastChar = currentChar;
    }*/
    return parametersBindMap;
}

/**
 * Bind statement to parameters list
 * @parameters
 *      sqlite3_stmt *statement - statement which will be bound parameters
 *      NSArray *parameters     - list of parameters for binding
 */
- (BOOL)bindStatement:(sqlite3_stmt*)statement toParameters:(NSArray*)parameters {
    
}

/**
 * Bind object at specific index for provided statement
 * @parameters
 *      id object               - object what should be bound to statement
 *      int index               - object bind index
 *      sqlite3_stmt *statement - statement to which object should be bound
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

/**
 * Add statement into the statements cache
 * @parameters
 *      DBCStatement *statement - initialized and configured DBCStatement instance
 */
- (void)addStatementToCache:(DBCStatement*)statement  {
    const char *cSQL = sqlite3_sql([statement statement]);
    if(cSQL) {
        NSString *sql = [NSString stringWithCString:cSQL encoding:NSUTF8StringEncoding];
        if(sql && [self isStatementCachingEnabled]) [cachedStatementsList setValue:statement forKey:[sql md5]];
    }
}

/**
 * Remove DBCSatement from statements cache
 */
- (void)removeStatementFromChache:(DBCStatement*)statement {
    const char *cSQL = sqlite3_sql([statement statement]);
    if(cSQL) {
        NSString *sql = [NSString stringWithCString:cSQL encoding:NSUTF8StringEncoding];
        DBCLockLogger(@"[DBC:StatementCache] Waiting for Lock: %@ (Line: %d)", [sql md5], __LINE__);
        [queryLock lock];
        DBCLockLogger(@"[DBC:StatementCache] Lock acquired: %@ (Line: %d)", [sql md5], __LINE__);
        if(cachedStatementsList) [cachedStatementsList removeObjectForKey:[sql md5]];
        DBCLockLogger(@"[DBC:StatementCache] Relinquished from previously acquired lock: %@ (Line: %d)", [sql md5], __LINE__);
        [queryLock unlock];
    }
}

/**
 * Retrieve cached statement for specific SQL query
 * @return cached DBCStatement if it was added before
 */
- (DBCStatement*)getCachedStatementFor:(NSString*)sqlRequest {
    if(sqlRequest==nil) return nil;
    DBCLockLogger(@"[DBC:StatementCache] Waiting for Lock: %@ (Line: %d)", [sqlRequest md5], __LINE__);
    [queryLock lock];
    DBCLockLogger(@"[DBC:StatementCache] Lock acquired: %@ (Line: %d)", [sqlRequest md5], __LINE__);
    DBCStatement *statement = [cachedStatementsList valueForKey:[sqlRequest md5]];
    DBCLockLogger(@"[DBC:StatementCache] Relinquished from previously acquired lock: %@ (Line: %d)", [sqlRequest md5], __LINE__);
    [queryLock unlock];
    return statement;
}

@end


#pragma mark DBCDatabase advanced functionality


@implementation DBCDatabase (advanced)

#pragma mark DBCDatabase instance initialization

/**
 * Open new database connection to database file at path, provided in init
 * Connection will be opened with flags passed to SQLite API
 * @parameters
 *      int flags - database connection bit-field flags
 */
- (int)openWithFlags:(int)flags {
    if(dbConnectionOpened) return dbConnectionOpened;
    dbFlags = flags;
    int resultCode = sqlite3_open_v2([dbPath UTF8String], &dbConnection, dbFlags, NULL);
    
    if(resultCode != SQLITE_OK){
        recentErrorCode = resultCode;
        DBCReleaseObject(recentError);
        recentError = [[DBCError errorWithErrorCode:recentErrorCode forFilePath:(inMemoryDB?@"in memory":dbPath)] retain];
        dbConnectionOpened = NO;
        DBCDebugLogger(@"[DBC:ERROR] %@", recentError);
        sqlite3_close(dbConnection);
    } else {
        sqlite3_busy_timeout(dbConnection, 250);
        [self setDatabaseEncoding:dbEncoding];
        dbConnectionOpened = YES;
    }
    return dbConnectionOpened;
}

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

#pragma mark DBCDatabase advcance getter/setter methods

/**
 * Retrieve reference on opened dstabase connection handler instance
 * @return reference on opened database connection handler instance
 */
- (sqlite3*)database {
    if(!dbConnectionOpened) return NULL;
    return dbConnection;
}

@end


#pragma mark DBCDatabase extended functionality (aliases)


@implementation DBCDatabase (extension)

/**
 * Get number of tables in current database
 */
- (int)getTablesCount {
    if(!dbConnectionOpened) return -1;
    //SELECT count(*) FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';
    return -1;
}

/**
 * Change encoding which used by database for data encoding or store
 * @parameters
 *      NSString *dbEncoding - new encoding
 */
- (void)setDatabaseEncoding:(DBCDatabaseEncoding)encoding {
    if(!dbConnectionOpened) return;
    /*[self evaluateUpdate:[NSString stringWithFormat:@"PRAGMA encoding = '%@'", 
                          encoding==DBCDatabaseEncodingUTF8?@"UTF-8":encoding==DBCDatabaseEncodingUTF16?@"UTF-16":@"UTF-8"]];*/
}

@end


#pragma mark DBCStatement lifecycle methods

@implementation DBCStatement

@synthesize sqlQuery;

/**
 * Initiate DBCStatement instance
 * @return initialized DBCStatement instance
 */
- (id)init {
    return [self initWithSQLQuery:nil  databaseEncoding:DBCDatabaseEncodingUTF8];
}

/**
 * Initiate DBCStatement instance with SQL query request
 * @parameters
 *      NSString *sql - SQL query for statement
 * @return initialized DBCStatement instance
 */
- (id)initWithSQLQuery:(NSString*)sql databaseEncoding:(DBCDatabaseEncoding)encoding {
    if((self = [super init])){
        dbEncoding = encoding;
        [self setSqlQuery:sql];
        statement = NULL;
    }
    return self;
}

/**
 * Initiate DBCStatement instance with SQL statement
 * @parameters
 *      sqlite3_stmt *sqlStatement - prepared SQL statement
 * @return initialized DBCStatement instance
 */
- (id)initWithSQLStatement:(sqlite3_stmt*)sqlStatement databaseEncoding:(DBCDatabaseEncoding)encoding {
    if((self = [super init])){
        dbEncoding = encoding;
        [self setStatement:sqlStatement];
    }
    return self;
}

/**
 * Reset prepared statement to it's initial state
 */
- (void)reset {
    if(statement == NULL) return;
    sqlite3_reset(statement);
    sqlite3_clear_bindings(statement);
}

/**
 * Close prepared statement and release it
 */
- (void)close {
    if(statement == NULL) return;
    sqlite3_finalize(statement);
    statement = NULL;
}

/**
 * Set new prepared statement
 * @parameters
 *      sqlite3_stmt *newStatement - new statement to store
 */
- (void)setStatement:(sqlite3_stmt*)newStatement {
    if(statement != NULL) sqlite3_finalize(statement);
    statement = newStatement;
    const char *sql = sqlite3_sql(statement);
    if(sql) {
        NSString *query = nil;
        if(dbEncoding==DBCDatabaseEncodingUTF8)
            query = [NSString stringWithCString:sql encoding:NSUTF8StringEncoding];
        else if(dbEncoding==DBCDatabaseEncodingUTF16)
            query = [NSString stringWithCString:sql encoding:NSUTF16StringEncoding];
        [self setSqlQuery:query];
    }
}

/**
 * Retrieve stored statement
 * @return stored statement
 */
- (sqlite3_stmt*)statement {
    return statement;
}

#pragma mark DBCStatement memory management

/**
 * Deallocating DBCStatement instance and release all retained memory
 */
- (void)dealloc {
    [self close];
    [self setSqlQuery:nil];
    [super dealloc];
}

@end
