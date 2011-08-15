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

/**
 * Create and initiate DBCDatabase by opening database, which exists at 'dbFilePath' 
 * with default encoding (UTF-8)
 * @parameters
 *      NSString *dbFilePath         - sqlite database file path
 * @return autoreleased DBCDatabase instance
 */
+ (id)databaseWithPath:(NSString*)dbFilePath;

/**
 * Create and initiate DBCDatabase by opening database, which exists at 'dbFilePath' 
 * @parameters
 *      NSString *dbFilePath         - sqlite database file path
 *      DBCDatabaseEncoding encoding - default encoding which will be used, when 
 *                                     exists ability to use differenc C API for 
 *                                     different encodings
 * @return autoreleased DBCDatabase instance
 */
+ (id)databaseWithPath:(NSString*)dbFilePath defaultEncoding:(DBCDatabaseEncoding)encoding;

/**
 * Create and initiate DBCDatabase from sqlite database file, which will be created at
 * specified path and SQL statements list from provided file. Will be used default encoding
 * @oarameters
 *      NSString *sqlStatementsListFilepath - path to file with list of SQL statements list
 *      NSString *dbFilePath                - sqlite database file target location
 *      BOOL      continueOnExecutionErrors - should continue creation on execution 
 *                                            update request error
 *      DBCError **error                    - if an error occurs, upon return contains an DBCError 
 *                                            object that describes the problem. Pass NULL if you 
 *                                            do not want error information.
 * WARNING: databasePath can't be same as application bundle, use application
 *          Documents folder instead
 * @return autoreleased DBCDatabase instance
 */
+ (id)databaseFromFile:(NSString*)sqlStatementsListFilepath atPath:(NSString*)databasePath 
continueOnExecutionErrors:(BOOL)continueOnExecutionErrors error:(DBCError**)error;

/**
 * Create and initiate DBCDatabase from sqlite database file, which will be created at
 * specified path and SQL statements list from provided file.
 * @oarameters
 *      NSString *sqlStatementsListFilepath - path to file with list of SQL statements list
 *      NSString *dbFilePath                - sqlite database file target location
 *      DBCDatabaseEncoding encoding        - default encoding which will be used, when 
 *                                            exists ability to use differenc C API for 
 *                                            different encodings
 *      BOOL     continueOnExecutionErrors  - should continue creation on execution 
 *                                            update request error
 *      DBCError **error                    - if an error occurs, upon return contains an DBCError 
 *                                            object that describes the problem. Pass NULL if you 
 *                                            do not want error information.
 * WARNING: databasePath can't be same as application bundle, use application
 *          Documents folder instead
 * @return autoreleased DBCDatabase instance
 */
+ (id)databaseFromFile:(NSString*)sqlStatementsListFilepath atPath:(NSString*)databasePath 
       defaultEncoding:(DBCDatabaseEncoding)encoding continueOnExecutionErrors:(BOOL)continueOnExecutionErrors 
                 error:(DBCError**)error;

/**
 * Initiate DBCDatabase by opening sqlite database file, which exists at 'dbFilePath' 
 * @parameters
 *      NSString *dbFilePath         - sqlite database file path
 *      DBCDatabaseEncoding encoding - default encoding which will be used, when 
 *                                     exists ability to use differenc C API for 
 *                                     different encodings
 * @return DBCDatabase instance
 */
- (id)initWithPath:(NSString*)dbFilePath defaultEncoding:(DBCDatabaseEncoding)encoding;

/**
 * Initiate DBCDatabase from sqlite database file, which will be created at
 * specified path and SQL query commands list from provided file.
 * @oarameters
 *      NSString *sqlQeryListPath          - path to file with list of SQL query commands list
 *      NSString *dbFilePath               - sqlite database file target location
 *      DBCDatabaseEncoding encoding       - default encoding which will be used, when 
 *                                           exists ability to use differenc C API for 
 *                                           different encodings
 *      BOOL     continueOnExecutionErrors - should continue creation on execution 
 *                                           update request error
 *      DBCError **error                   - if an error occurs, upon return contains an DBCError 
 *                                           object that describes the problem. Pass NULL if you 
 *                                           do not want error information.
 * WARNING: databasePath can't be same as application bundle, use application
 *          Documents folder instead
 * @return DBCDatabase instance
 */
- (id)createDatabaseFromFile:(NSString*)sqlQeryListPath atPath:(NSString*)databasePath 
             defaultEncoding:(DBCDatabaseEncoding)encoding continueOnExecutionErrors:(BOOL)continueOnExecutionErrors 
                       error:(DBCError**)error;

#pragma mark Database open and close

/**
 * Open new database connection to sqlite database file at path, which was 
 * provided in init
 * Connection will be opened with 'readwrite|create' right
 * @oarameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return whether database connection was successfully opened or not
 */
- (BOOL)openError:(DBCError**)error;

/**
 * Open new database connection to sqlite database file at path, which was 
 * provided in init
 * Connection will be opened with 'readonly' rights
 * @oarameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return whether database connection was successfully opened or not
 */
- (BOOL)openReadonlyError:(DBCError**)error;

/**
 * Copy currently opened sqlite database file to provided location assuming what
 * it is outside of application bundle and reopen connection with 'read-write' rights
 * @parameters
 *      NSString *mutableDatabaseStoreDestination - database file copy destination
 *      BOOL shouldRewriteExistingFile            - YES if should rewrite existing, otherwise NO
 *      DBCError **error                          - if an error occurs, upon return contains an DBCError 
 *                                                  object that describes the problem. Pass NULL if you 
 *                                                  do not want error information.
 */
- (BOOL)makeMutableAt:(NSString*)mutableDatabaseStoreDestination rewriteExisting:(BOOL)shouldRewriteExistingFile 
                error:(DBCError**)error;

/**
 * Close database connection to sqlite database file if it was opened
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return whether database connection was successfully closed or not
 */
- (BOOL)closeError:(DBCError**)error;

#pragma mark DDL and DML methods

/**
 * Execute prepared SQL statement on current database connection
 * @parameters
 *      NSString *sqlUpdate - SQL query command
 *      DBCError **error    - if an error occurs, upon return contains an DBCError 
 *                            object that describes the problem. Pass NULL if you 
 *                            do not want error information.
 *               ...        - list of binding parameters
 * @return whether update request was successfully execution or not
 */
- (BOOL)executeUpdate:(NSString*)sqlUpdate error:(DBCError**)error, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * Execute prepared SQL statement on current database connection
 * @parameters
 *      NSString *sqlQuery  - SQL query command
 *      DBCError **error    - if an error occurs, upon return contains an DBCError 
 *                            object that describes the problem. Pass NULL if you 
 *                            do not want error information.
 *               ...        - list of binding parameters
 * @return query resultts if execution successfull or nil in case of error
 */
- (DBCDatabaseResult*)executeQuery:(NSString*)sqlQuery error:(DBCError**)error, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * Execute statements list from external file on current database connection
 * @parameters
 *      NSString *statementsFilePath   - sqlite database file path
 *      BOOL continueOnExecutionErrors - should continue statements execution on errors
 *      DBCError **error               - if an error occurs, upon return contains an DBCError 
 *                                       object that describes the problem. Pass NULL if you 
 *                                       do not want error information.
 * @return whether eavluate was successfull or not (always YES if set continueOnExecutionErrors)
 */
- (BOOL)executeStatementsFromFile:(NSString*)statementsFilePath continueOnExecutionErrors:(BOOL)continueOnExecutionErrors 
                            error:(DBCError**)error;

#pragma mark TCL methods

/**
 * Move database connection from 'autocommit' mode and begin default transaction
 * @parameters
 *      DBCError **error    - if an error occurs, upon return contains an DBCError 
 *                            object that describes the problem. Pass NULL if you 
 *                            do not want error information.
 * @return whether transaction was started or not
 */
- (BOOL)beginTransactionError:(DBCError**)error;

/**
 * Move database connection from 'autocommit' mode and begin deferred transaction
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return whether transaction was started or not
 */
- (BOOL)beginDeferredTransactionError:(DBCError**)error;

/**
 * Move database connection from 'autocommit' mode and begin immediate transaction
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return whether transaction was started or not
 */
- (BOOL)beginImmediateTransactionError:(DBCError**)error;

/**
 * Move database connection from 'autocommit' mode and begin exclusive transaction
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return whether transaction was started or not
 */
- (BOOL)beginExclusiveTransactionError:(DBCError**)error;

/**
 * Move database connection back to 'autocommit' mode and commit all changes made in 
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * transaction
 * @return whether transactoin changes commit was successfull or not
 */
- (BOOL)commitTransactionError:(DBCError**)error;

/**
 * Try rollback current transaction
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return whether rollback was successfull or not
 */
- (BOOL)rollbackTransactionError:(DBCError**)error;

#pragma mark DBCDatabase misc methods

/**
 * Retrieve main database version
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return main database version
 */
- (int)databaseVersionError:(DBCError**)error;

/**
 * Retrieve specific database version
 * @parameters
 *      NSString *databaseName - target database name 
 *      DBCError **error       - if an error occurs, upon return contains an DBCError 
 *                               object that describes the problem. Pass NULL if you 
 *                               do not want error information.
 * @return specific database version
 */
- (int)databaseVersionFor:(NSString*)databaseName error:(DBCError**)error;

/**
 * Change main database version
 * @parameters
 *      int version      - new database version 
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return whether version was successfull changed or not
 */
- (BOOL)changeDatabaseVersion:(int)version error:(DBCError**)error;

/**
 * Change specific database version
 * @parameters
 *      int version            - new database version 
 *      NSString *databaseName - target database name 
 *      DBCError **error       - if an error occurs, upon return contains an DBCError 
 *                               object that describes the problem. Pass NULL if you 
 *                               do not want error information.
 * @return whether version was successfull changed or not
 */
- (BOOL)changeDatabaseVersion:(int)version forDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Perform self-checking on main database structure and data 
 * @parameters
 *      DBCError **error       - if an error occurs, upon return contains an DBCError 
 *                               object that describes the problem. Pass NULL if you 
 *                               do not want error information.
 * @return whether database structure passed validation or not
 */
- (BOOL)isDatabaseStructureValidError:(DBCError**)error;

/**
 * Perform self-checking on main database structure and data 
 * @parameters
 *      numberOfErrorsBeforValidationFail - number of errors which may occure before validation will be terminated 
 *      DBCError **error                  - if an error occurs, upon return contains an DBCError 
 *                                          object that describes the problem. Pass NULL if you 
 *                                          do not want error information.
 * @return whether database structure passed validation or not
 */
- (BOOL)isDatabaseStructureValidWithErrorCountBeforeAbort:(int)numberOfErrorsBeforValidationFail error:(DBCError**)error;

/**
 * Perform self-checking on specific database structure and data 
 * @parameters
 *      NSString *databaseName - target database name 
 *      DBCError **error       - if an error occurs, upon return contains an DBCError 
 *                               object that describes the problem. Pass NULL if you 
 *                               do not want error information.
 * @return whether database structure passed validation or not
 */
- (BOOL)isDatabaseStructureValidFor:(NSString*)databaseName error:(DBCError**)error;

/**
 * Perform self-checking on specific database structure and data 
 * @parameters
 *      NSString *databaseName            - target database name 
 *      numberOfErrorsBeforValidationFail - number of errors which may occure before validation will be terminated 
 *      DBCError **error                  - if an error occurs, upon return contains an DBCError 
 *                                          object that describes the problem. Pass NULL if you 
 *                                          do not want error information.
 * @return whether database structure passed validation or not
 */
- (BOOL)isDatabaseStructureValidFor:(NSString*)databaseName errorCountBeforeAbort:(int)numberOfErrorsBeforValidationFail
                              error:(DBCError**)error;

#pragma mark DBCDatabase getter/setter methods

/**
 * Reloaded statement caching enable method
 * @parameters
 *      BOOL sCacheStatements - caching flag
 */
- (void)setStatementsCachingEnabled:(BOOL)sCacheStatements;

/**
 * Retrieve reference on opened dstabase connection handler instance
 * @return reference on opened database connection handler instance
 */
- (sqlite3*)database;

#pragma mark DBCDatabase memory management

/**
 * Deallocate DBCDatabase close connection and release all retained memory
 */
- (void)dealloc;


@end