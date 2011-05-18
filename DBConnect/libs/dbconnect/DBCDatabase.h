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

#import <Foundation/Foundation.h>
#import "DBCError.h"
#import <sqlite3.h>

typedef enum _DBCDatabaseEncoding {
    DBCDatabaseEncodingUTF8,
    DBCDatabaseEncodingUTF16
} DBCDatabaseEncoding;

typedef enum _DBCDatabaseTransactionLock {
    DBCDatabaseAutocommitModeDeferred,
    DBCDatabaseAutocommitModeImmediate,
    DBCDatabaseAutocommitModeExclusive
} DBCDatabaseTransactionLock;

@interface DBCDatabase : NSObject {
@protected
    NSString                    *dbPath;
    NSRecursiveLock             *queryLock;
    
    int                         dbBusyRequestRetryCount;
    BOOL                        statementCachingEnabled;
    
    BOOL                        createTransactionOnSQLSequences;
    BOOL                        rollbackSQLSequenceTransactionOnError;
    DBCDatabaseTransactionLock  defaultSQLSequencesTransactinoLock;
    
    int                         recentErrorCode;
    DBCError                    *recentError;
@private
    sqlite3                     *dbConnection;
    BOOL                        dbConnectionOpened;
    int                         dbFlags;
    DBCDatabaseEncoding         dbEncoding;
    
    BOOL                        inMemoryDB;
    
    NSMutableDictionary         *cachedStatementsList;
}
@property (nonatomic, assign)int dbBusyRequestRetryCount;
@property (nonatomic, assign, getter = isStatementCachingEnabled)BOOL statementCachingEnabled;
@property (nonatomic, assign)BOOL rollbackSQLSequenceTransactionOnError;
@property (nonatomic, assign)DBCDatabaseTransactionLock defaultSQLSequencesTransactinoLock;
@property (nonatomic, assign)BOOL createTransactionOnSQLSequences;
@property (nonatomic, readonly)int recentErrorCode;
@property (nonatomic, readonly)DBCError *recentError;

+ (id)databaseWithPath:(NSString*)dbFilePath defaultEncoding:(DBCDatabaseEncoding)encoding;
+ (id)databaseFromFile:(NSString*)sqlQeryListPath atPath:(NSString*)databasePath defaultEncoding:(DBCDatabaseEncoding)encoding contineOnEvaluateErrors:(BOOL)contineOnEvaluateErrors;
- (id)initWithPath:(NSString*)dbFilePath defaultEncoding:(DBCDatabaseEncoding)encoding;
- (id)createDatabaseFromFile:(NSString*)sqlQeryListPath atPath:(NSString*)databasePath defaultEncoding:(DBCDatabaseEncoding)encoding contineOnEvaluateErrors:(BOOL)contineOnEvaluateErrors;

- (BOOL)open;
- (NSArray*)extractCommandsSequence:(NSString*)sql;
- (BOOL)openReadonly;
- (BOOL)close;

- (BOOL)evaluateUpdateWithParameters:(NSString*)sqlUpdate, ... NS_REQUIRES_NIL_TERMINATION;
- (BOOL)evaluateUpdate:(NSString*)sqlUpdate;
- (BOOL)evaluateUpdate:(NSString*)sqlUpdate parameters:(NSArray*)parameters;
- (id)evaluateQuery:(NSString*)sqlQuery;

@end


@interface DBCDatabase (advanced)

- (int)openWithFlags:(int)flags;
- (sqlite3*)database;
- (int)registerModule:(const sqlite3_module*)module moduleName:(NSString*)moduleName userData:(void*)userData cleanupFunction:(void(*)(void*))cleanupFunction;
- (int)registerScalarFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))function functionName:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData;
- (int)unRegisterScalarFunction:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation;
- (int)registerAggregationFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))stepFunction finalyzeFunction:(void(*)(sqlite3_context*))finalyzeFunction functionName:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData;
- (int)unRegisterAggregationFunction:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation;
- (int)registerCollationFunction:(int(*)(void*, int, const void*, int, const void*))function cleanupFunction:(void(*)(void*))cleanupFunction functionName:(NSString*)fnName textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData;
- (int)unRegisterCollationFunction:(NSString*)fnName textValueRepresentation:(int)expectedTextValueRepresentation;

@end


@interface DBCDatabase (extension)

- (int)getTablesCount;
- (void)setDatabaseEncoding:(DBCDatabaseEncoding)encoding;

@end


@interface DBCStatement : NSObject {
    NSString                *sqlQuery;
    sqlite3_stmt            *statement;
    DBCDatabaseEncoding     dbEncoding;
}
@property (nonatomic, copy)NSString *sqlQuery;

- (id)initWithSQLQuery:(NSString*)sql databaseEncoding:(DBCDatabaseEncoding)encoding;
- (id)initWithSQLStatement:(sqlite3_stmt*)sqlStatement databaseEncoding:(DBCDatabaseEncoding)encoding;
- (void)reset;
- (void)close;

- (void)setStatement:(sqlite3_stmt*)newStatement;
- (sqlite3_stmt*)statement;

@end