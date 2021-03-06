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
#import "DBCDatabase.h"

@interface DBCDatabase (DBCDatabase_Aliases)

#pragma mark SQLite database misc

/**
 * Attach sqlite database from file with defined database name to current 
 * database connection
 * @parameters
 *      NSString *dbFilePath    - slqite database file path
 *      NSString *dbAttachName  - name for attached database
 *      DBCError **error        - if an error occurs, upon return contains an DBCError 
 *                                object that describes the problem. Pass NULL if you 
 *                                do not want error information.
 * @return whether attach was successfull or not
 */
- (BOOL)attachDatabase:(NSString*)dbFilePath databaseAttachName:(NSString*)dbAttachName error:(DBCError**)error;

/**
 * Detach sqlite database from current database connection
 * @parameters
 *      NSString *attachedDatabaseName  - name of attached database
 *      DBCError **error                - if an error occurs, upon return contains an DBCError 
 *                                        object that describes the problem. Pass NULL if you 
 *                                        do not want error information.
 * @return whether detach was successfull or not
 */
- (BOOL)detachDatabase:(NSString*)attachedDatabaseName error:(DBCError**)error;

/**
 * Set encoding which used by database for data encoding or store
 * @parameters
 *      NSString *dbEncoding - new encoding
 *      DBCError **error     - if an error occurs, upon return contains an DBCError 
 *                             object that describes the problem. Pass NULL if you 
 *                             do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setDatabaseEncoding:(DBCDatabaseEncoding)encoding error:(DBCError**)error;

/**
 * Get current database connection encoding
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return current database connection encoding
 */
- (DBCDatabaseEncoding)databaseEncodingError:(DBCError**)error;

/**
 * Set whether use case-sensitive behaviour of built-in LIKE expression or not
 * @parameters
 *      BOOL use         - condition flag
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @default default state is set to NO
 * @return whether set was successfull or not
 */
- (BOOL)setUseCaseSensitiveLike:(BOOL)use error:(DBCError**)error;

#pragma mark DDL and DML methods

/**
 * Drop specified table in provided database and clean up space after table
 * @parameters
 *      NSString *tableName    - table which will be removed
 *      NSString *databaseName - target database
 *      DBCError **error       - if an error occurs, upon return contains an DBCError 
 *                               object that describes the problem. Pass NULL if you 
 *                               do not want error information.
 * WARNING: ROWID values may be reset
 * @return whether table was dropped or not
 */
- (BOOL)dropTable:(NSString*)tableName inDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Drop all tables in specified database
 * @parameters
 *      NSString *databaseName - target database
 *      DBCError **error       - if an error occurs, upon return contains an DBCError 
 *                               object that describes the problem. Pass NULL if you 
 *                               do not want error information.
 * WARNING: ROWID values may be reset
 * @return whether tables was dropped or not
 */
- (BOOL)dropAllTablesInDatabase:(NSString*)databaseName error:(DBCError**)error;

#pragma mark Database information

/**
 * Get number of tables in current and attached databases
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return number of tables in current and attached databases
 */
- (int)tablesCountError:(DBCError**)error;

/**
 * Get number of tables in database by it's name
 * @parameters
 *      NSString *databaseName - database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError 
 *                               object that describes the problem. Pass NULL if you 
 *                               do not want error information.
 * @return number of tables in provided database
 */
- (int)tablesCountInDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Get list of tables for current database connection
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return list of tables stored in main database of current database connection
 */
- (NSArray*)tablesListError:(DBCError**)error;

/**
 * Get list of tables in database by it's name
 * @parameters
 *      NSString *databaseName - database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError 
 *                               object that describes the problem. Pass NULL if you 
 *                               do not want error information.
 * @return list of tables stored in provided database
 */
- (NSArray*)tablesListForDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Get list of columns information for specified table in current database connection
 * @parameters
 *      NSString *tableName - target table name
 *      DBCError **error    - if an error occurs, upon return contains an DBCError 
 *                            object that describes the problem. Pass NULL if you 
 *                            do not want error information.
 * @return list of columns information for specified table in main database of 
 * current database connection
 */
- (NSArray*)tableInformation:(NSString*)tableName error:(DBCError**)error;

/**
 * Get list of columns information for specified table in database by it's name
 * @parameters
 *      NSString *tableName    - target table name
 *      NSString *databaseName - database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError 
 *                               object that describes the problem. Pass NULL if you 
 *                               do not want error information.
 * @return list of columns information for specified table in provided database
 */
- (NSArray*)tableInformation:(NSString*)tableName forDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Get databases list
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError 
 *                         object that describes the problem. Pass NULL if you 
 *                         do not want error information.
 * @return array of databases
 */
- (NSArray*)databasesListError:(DBCError**)error;

/**
 * Get indices list
 * @parameters
 *      NSString *databaseName - target database name
 *      NSString *tableName    - target table name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError 
 *                               object that describes the problem. Pass NULL if you 
 *                               do not want error information.
 * @return array of indices for specified table
 */
- (NSArray*)indicesList:(NSString*)databaseName forTable:(NSString*)tableName error:(DBCError**)error;

/**
 * Get indexed columns list
 * @parameters
 *      NSString *databaseName - target database name
 *      NSString *indexName    - target index name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError 
 *                               object that describes the problem. Pass NULL if you 
 *                               do not want error information.
 * @return array of indexed columns for specified table
 */
- (NSArray*)indexedColumnsList:(NSString*)databaseName index:(NSString*)indexName error:(DBCError**)error;

@end
