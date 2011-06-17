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
#import "DBCDatabaseIndexedColumnInfo.h"
#import "DBCDatabaseTableColumnInfo.h"
#import "DBCAdditionalErrorCodes.h"
#import "DBCDatabaseIndexInfo.h"
#import "DBCDatabaseResult.h"
#import "DBCDatabaseInfo.h"
#import "DBCDatabaseRow.h"
#import "DBCStatement.h"
#import "DBCError.h"
#import "sqlite3lib.h"
#import <sqlite3.h>

@class DBCDatabaseResult;

@interface DBCDatabase : NSObject {
@protected
    NSString                    *dbPath;
    NSRecursiveLock             *queryLock;
    
    int                         dbBusyRetryCount;
    BOOL                        statementsCachingEnabled;
    
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
    
    NSArray                     *listOfPossibleTCLCommands;
    NSArray                     *listOfNSStringFormatSpecifiers;
}
@property (nonatomic, assign)int dbBusyRetryCount;
@property (nonatomic, assign)DBCDatabaseTransactionLock defaultSQLSequencesTransactinoLock;
@property (nonatomic, assign, getter = isStatementsCachingEnabled)BOOL statementsCachingEnabled;
@property (nonatomic, assign)BOOL rollbackSQLSequenceTransactionOnError;
@property (nonatomic, assign)BOOL createTransactionOnSQLSequences;
@property (nonatomic, readonly)int recentErrorCode;
@property (nonatomic, readonly)DBCError *recentError;


#pragma mark DBCDatabase instance initialization
+ (id)databaseWithPath:(NSString*)dbFilePath;
+ (id)databaseWithPath:(NSString*)dbFilePath defaultEncoding:(DBCDatabaseEncoding)encoding;
+ (id)databaseFromFile:(NSString*)sqlStatementsListFilepath atPath:(NSString*)databasePath continueOnEvaluateErrors:(BOOL)continueOnEvaluateErrors;
+ (id)databaseFromFile:(NSString*)sqlStatementsListFilepath atPath:(NSString*)databasePath defaultEncoding:(DBCDatabaseEncoding)encoding continueOnEvaluateErrors:(BOOL)continueOnEvaluateErrors;
- (id)initWithPath:(NSString*)dbFilePath defaultEncoding:(DBCDatabaseEncoding)encoding;
- (id)createDatabaseFromFile:(NSString*)sqlQeryListPath atPath:(NSString*)databasePath defaultEncoding:(DBCDatabaseEncoding)encoding continueOnEvaluateErrors:(BOOL)continueOnEvaluateErrors;

#pragma mark Database open and close

- (BOOL)open;
- (BOOL)openReadonly;
- (BOOL)makeMutableAt:(NSString*)mutableDatabaseStoreDestination;
- (BOOL)close;

#pragma mark DDL and DML methods

- (BOOL)evaluateUpdate:(NSString*)sqlUpdate, ... NS_REQUIRES_NIL_TERMINATION;
- (BOOL)evaluateStatementsFromFile:(NSString*)statementsFilePath continueOnEvaluateErrors:(BOOL)continueOnEvaluateErrors;
- (DBCDatabaseResult*)evaluateQuery:(NSString*)sqlQuery, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark TCL methods

- (BOOL)beginTransaction;
- (BOOL)beginDeferredTransaction;
- (BOOL)beginImmediateTransaction;
- (BOOL)beginExclusiveTransaction;
- (BOOL)commitTransaction;
- (BOOL)rollbackTransaction;

#pragma mark DBCDatabase getter/setter methods

- (sqlite3*)database;

@end