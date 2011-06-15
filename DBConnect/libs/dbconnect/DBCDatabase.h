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
#import "DBCDatabaseResult.h"
#import "DBCDatabaseRow.h"
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
+ (id)databaseWithPath:(NSString*)dbFilePath defaultEncoding:(DBCDatabaseEncoding)encoding;
+ (id)databaseFromFile:(NSString*)sqlStatementsListFilepath atPath:(NSString*)databasePath defaultEncoding:(DBCDatabaseEncoding)encoding continueOnEvaluateErrors:(BOOL)continueOnEvaluateErrors;
- (id)initWithPath:(NSString*)dbFilePath defaultEncoding:(DBCDatabaseEncoding)encoding;
- (id)createDatabaseFromFile:(NSString*)sqlQeryListPath atPath:(NSString*)databasePath defaultEncoding:(DBCDatabaseEncoding)encoding continueOnEvaluateErrors:(BOOL)continueOnEvaluateErrors;

#pragma mark Database open and close

- (BOOL)open;
- (BOOL)openReadonly;
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

@interface DBCDatabaseInfo : NSObject {
    int         dbSeqNumber;
    NSString    *dbName;
    NSString    *dbFilePath;
}
@property (nonatomic, readonly, getter = numberInSequence)int dbSeqNumber;
@property (nonatomic, readonly, getter = name)NSString *dbName;
@property (nonatomic, readonly, getter = filePath)NSString *dbFilePath;
+ (id)databaseInfoWithSequence:(int)sequenceNumber name:(NSString*)databaseName filePath:(NSString*)pathToDatabaseFile;
- (id)initDatabaseInfoWithSequence:(int)sequenceNumber name:(NSString*)databaseName filePath:(NSString*)pathToDatabaseFile;

@end


@interface DBCStatement : NSObject {
    NSString                *sqlQuery;
    sqlite3_stmt            *statement;
}
@property (nonatomic, copy)NSString *sqlQuery;

- (id)initWithSQLQuery:(NSString*)sql;
- (void)reset;
- (void)close;

- (void)setStatement:(sqlite3_stmt*)newStatement;
- (sqlite3_stmt*)statement;

@end

@interface DBCDatabaseIndexInfo : NSObject {
    int         idxSeqNumber;
    NSString    *idxName;
    BOOL        idxUnique;
}
@property (nonatomic, readonly, getter = numberInSequence)int idxSeqNumber;
@property (nonatomic, readonly, getter = name)NSString *idxName;
@property (nonatomic, readonly, getter = isUnique)BOOL idxUnique;
+ (id)indexInfoWithSequence:(int)sequenceNumber name:(NSString*)indexName unique:(BOOL)isUnique;
- (id)initIndexInfoWithSequence:(int)sequenceNumber name:(NSString*)indexName unique:(BOOL)isUnique;

@end

@interface DBCDatabaseIndexedColumnInfo : NSObject {
    int         colIdxInIndex;
    int         colIdxInTable;
    NSString    *colName;
}
@property (nonatomic, readonly, getter = indexInIndex)int colIdxInIndex;
@property (nonatomic, readonly, getter = indexInTable)int colIdxInTable;
@property (nonatomic, readonly, getter = name)NSString *colName;
+ (id)indexedColumnInfoWithSequence:(int)columnIndexInIndex inTableSequenceNumber:(int)columnIndexInTable name:(NSString*)columnName;
- (id)initIndexedColumnInfoWithSequence:(int)columnIndexInIndex inTableSequenceNumber:(int)columnIndexInTable name:(NSString*)columnName;

@end

@interface DBCDatabaseTableColumnInfo : NSObject {
    int         colIdx;
    NSString    *colName;
    NSString    *colType;
    BOOL        colNotNull;
    NSString    *colDefValue;
    BOOL        colIsPartOfPK;
}
@property (nonatomic, readonly, getter = numberInSequence)int colIdx;
@property (nonatomic, readonly, getter = name)NSString *colName;
@property (nonatomic, readonly, getter = type)NSString *colType;
@property (nonatomic, readonly, getter = isNotNull)BOOL colNotNull;
@property (nonatomic, readonly, getter = defaultValue)NSString *colDefValue;
@property (nonatomic, readonly, getter = isPartOfThePrimaryKey)BOOL colIsPartOfPK;
+ (id)columnInfoWithSequence:(int)columnNumber columnName:(NSString*)columnName columnDataType:(NSString*)columnDataType isNotNull:(BOOL)isNotNull defaultValue:(NSString*)defaultVallue isPartOfThePrimaryKey:(BOOL)isPartOfThePrimaryKey;
- (id)initolumnInfoWithSequence:(int)columnNumber columnName:(NSString*)columnName columnDataType:(NSString*)columnDataType isNotNull:(BOOL)isNotNull defaultValue:(NSString*)defaultVallue isPartOfThePrimaryKey:(BOOL)isPartOfThePrimaryKey;

@end