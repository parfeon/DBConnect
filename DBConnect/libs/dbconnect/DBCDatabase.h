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
    
    int                         executionRetryCount;
    BOOL                        statementsCachingEnabled;
    
    BOOL                        createTransactionOnSQLSequences;
    BOOL                        rollbackSQLSequenceTransactionOnError;
    DBCDatabaseTransactionLock  defaultSQLSequencesTransactionLock;
@private
    sqlite3                     *dbConnection;
    BOOL                        dbConnectionOpened;
    int                         dbFlags;
    DBCDatabaseEncoding         dbEncoding;
    
    BOOL                        inMemoryDB;
    
    NSMutableDictionary         *cachedStatementsList;
    
    NSArray                     *listOfPossibleTCLCommands;
    NSArray                     *listOfDMLCommands;
    NSArray                     *listOfNSStringFormatSpecifiers;
    
    int                         recentErrorCode;
} 
@property (nonatomic)int executionRetryCount;
@property (nonatomic)DBCDatabaseTransactionLock defaultSQLSequencesTransactionLock;
@property (nonatomic, getter = isStatementsCachingEnabled)BOOL statementsCachingEnabled;
@property (nonatomic)BOOL rollbackSQLSequenceTransactionOnError;
@property (nonatomic)BOOL createTransactionOnSQLSequences;
@property (nonatomic, readonly, getter = database)sqlite3 *dbConnection;


#pragma mark DBCDatabase instance initialization

+ (id)databaseWithPath:(NSString*)dbFilePath;
+ (id)databaseWithPath:(NSString*)dbFilePath defaultEncoding:(DBCDatabaseEncoding)encoding;
+ (id)databaseFromFile:(NSString*)sqlStatementsListFilepath atPath:(NSString*)databasePath 
continueOnExecutionErrors:(BOOL)continueOnExecutionErrors error:(DBCError**)error;
+ (id)databaseFromFile:(NSString*)sqlStatementsListFilepath atPath:(NSString*)databasePath 
       defaultEncoding:(DBCDatabaseEncoding)encoding continueOnExecutionErrors:(BOOL)continueOnExecutionErrors 
                 error:(DBCError**)error;
- (id)initWithPath:(NSString*)dbFilePath defaultEncoding:(DBCDatabaseEncoding)encoding;
- (id)createDatabaseFromFile:(NSString*)sqlQeryListPath atPath:(NSString*)databasePath 
             defaultEncoding:(DBCDatabaseEncoding)encoding continueOnExecutionErrors:(BOOL)continueOnExecutionErrors 
                       error:(DBCError**)error;

#pragma mark Database open and close

- (BOOL)openError:(DBCError**)error;
- (BOOL)openReadonlyError:(DBCError**)error;
- (BOOL)makeMutableAt:(NSString*)mutableDatabaseStoreDestination error:(DBCError**)error;
- (BOOL)closeError:(DBCError**)error;

#pragma mark DDL and DML methods

- (BOOL)executeUpdate:(NSString*)sqlUpdate error:(DBCError**)error, ... NS_REQUIRES_NIL_TERMINATION;
- (DBCDatabaseResult*)executeQuery:(NSString*)sqlQuery error:(DBCError**)error, ... NS_REQUIRES_NIL_TERMINATION;
- (BOOL)executeStatementsFromFile:(NSString*)statementsFilePath continueOnExecutionErrors:(BOOL)continueOnExecutionErrors 
                            error:(DBCError**)error;

#pragma mark TCL methods

- (BOOL)beginTransactionError:(DBCError**)error;
- (BOOL)beginDeferredTransactionError:(DBCError**)error;
- (BOOL)beginImmediateTransactionError:(DBCError**)error;
- (BOOL)beginExclusiveTransactionError:(DBCError**)error;
- (BOOL)commitTransactionError:(DBCError**)error;
- (BOOL)rollbackTransactionError:(DBCError**)error;

@end