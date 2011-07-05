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

@interface DBCDatabase (DBCDatabase_Advanced)

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
- (BOOL)openWithFlags:(int)flags error:(DBCError**)error;

#pragma mark SQLite database file pages

/**
 * Free unused database pages
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * WARNING: ROWID values may be reset
 * @return whether vacuum was successfull or not
 */
- (BOOL)freeUnusedPagesError:(DBCError**)error;

/**
 * Get free pages count in database
 * @parameters
 *      NSString *databaseName - database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return free pages count in database
 */
- (int)freePagesCountInDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Get pages count in database (including unused)
 * @parameters
 *      NSString *databaseName - database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return pages count in database 
 */
- (int)pagesCountInDatabase:(NSString*)databaseName error:(DBCError**)error;

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
- (BOOL)setPageSizeInDatabase:(NSString*)databaseName size:(int)newPageSize error:(DBCError**)error;

/**
 * Get page size for specific database
 * @parameters
 *      NSString *databaseName - database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return page size for specific database
 */
- (int)pageSizeInDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Set maximum pages count
 * @parameters
 *      NSString *databaseName    - target database name
 *      long long int newPageSize - new maximum pages count
 *      DBCError **error          - if an error occurs, upon return contains an DBCError object that describes the 
 *                                  problem. Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setMaximumPageCountForDatabase:(NSString*)databaseName size:(int)newPageCount error:(DBCError**)error;

/**
 * Reset maximum pages count for spicified database to it's default value
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)resetMaximumPageCountForDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Get maximum pages count for specified database
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return maximum pages count for specified database
 */
- (int)maximumPageCountForDatabase:(NSString*)databaseName error:(DBCError**)error;

#pragma mark Database backup/restore

/**
 * Restore destination database from current connection with source database file and specified source database name
 * @parameters
 *      NSString *dstDatabaseName - destination database name in current database connection for restore
 *      NSString *srcDatabaseFile - source database file from which database restore will be performed
 *      NSString *srcDatabaseName - source database name, which will be used to restore destination database
 *      DBCError **error          - if an error occurs, upon return contains an DBCError object that describes the 
 *                                  problem. Pass NULL if you do not want error information.
 * @return whether restore was successfull or not
 */
- (BOOL)restore:(NSString*)dstDatabaseName fromFile:(NSString*)srcDatabaseFile database:(NSString*)srcDatabaseName 
          error:(DBCError**)error;

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
- (BOOL)restore:(NSString*)dstDatabaseName from:(sqlite3*)srcDatabaseConnection database:(NSString*)srcDatabaseName 
          error:(DBCError**)error;

/**
 * Backup source database from current connection to destination database file and specified destination database name
 * @parameters
 *      NSString *srcDatabaseName - source database name in current database connection for backup
 *      NSString *dstDatabaseFile - destination database file to which database backup will be performed
 *      NSString *dstDatabaseName - destination database name, which will be used to backup source database
 *      DBCError **error          - if an error occurs, upon return contains an DBCError object that describes the 
 *                                  problem. Pass NULL if you do not want error information.
 * @return whether backup was successfull or not
 */
- (BOOL)backup:(NSString*)srcDatabaseName toFile:(NSString*)dstDatabaseFile database:(NSString*)dstDatabaseName 
         error:(DBCError**)error;

/**
 * Backup source database from current connection to destination database connection and specified destination 
 * database name
 * @parameters
 *      NSString *srcDatabaseName - source database name in current database connection for backup
 *      NSString *dstDatabase     - destination database connection to which database backup will be performed
 *      NSString *dstDatabaseName - destination database name, which will be used to backup source database
 *      DBCError **error          - if an error occurs, upon return contains an DBCError object that describes the
 *                                  problem. Pass NULL if you do not want error information.
 * @return whether backup was successfull or not
 */
- (BOOL)backup:(NSString*)srcDatabaseName to:(sqlite3*)dstDatabase database:(NSString*)dstDatabaseName 
         error:(DBCError**)error;

#pragma mark Transaction journal

/**
 * Turn off transaction journaling for current database connection
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * @return whether journaling turned off on current database connection or not
 */
- (BOOL)turnOffJournalingError:(DBCError**)error;

/**
 * Turn off transaction journaling for specified database connection
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return whether journaling turned off on current database connection or not
 */
- (BOOL)turnOffJournalingForDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Turn on transaction journaling for current database connection
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * @return whether journaling turned on on current database connection or not
 */
- (BOOL)turnOnJournalingError:(DBCError**)error;

/**
 * Turn on transaction journaling for specified database connection
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return whether journaling turned on on current database connection or not
 */
- (BOOL)turnOnJournalingForDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Set new journal mode for current database connection and any newly attached 
 * databases
 * @parameters
 *      NSString *journalMode - new journalig mode
 *      DBCError **error      - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                              Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setJournalMode:(DBCDatabaseJournalingMode)journalMode error:(DBCError**)error;

/**
 * Get current database connection journaling mode
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * @return journaling mode for current database connection
 */
- (DBCDatabaseJournalingMode)journalModeError:(DBCError**)error;

/**
 * Set new journal mode for specified database
 * @parameters
 *      NSString *journalMode  - new journalig mode
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setJournalMode:(DBCDatabaseJournalingMode)journalMode forDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Get specified database connection journaling mode
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return journaling mode for specified database connection
 */
- (DBCDatabaseJournalingMode)journalModeForDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Set default journal size limit for specified database
 * @parameters
 *      NSString *databaseName            - target database name
 *      long long int newJournalSizeLimit - new journal size in bytes
 *      DBCError **error                  - if an error occurs, upon return contains an DBCError object that describes the 
 *                                          problem. Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setJournalSizeLimitForDatabase:(NSString*)databaseName size:(long long int)newJournalSizeLimit 
                                 error:(DBCError**)error;

/**
 * Get journal size for specified database
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return journal size in bytes for specified database
 */
- (long long int)journalSizeLimitForDatabase:(NSString*)databaseName error:(DBCError**)error;

#pragma mark Database locking

/**
 * Set default locking mode for current cdatabase connection and any newly 
 * attached databases
 * @parameters
 *      DBCDatabaseLockingMode lockingMode - new locking mode
 *      DBCError **error                   - if an error occurs, upon return contains an DBCError object that describes 
 *                                           the problem. Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setLockingMode:(DBCDatabaseLockingMode)lockingMode error:(DBCError**)error;

/**
 * Get current database connection locking mode
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * @return current database connection locking mode
 */
- (DBCDatabaseLockingMode)lockingModeError:(DBCError**)error;

/**
 * Set default locking mode for specified database name
 * attached databases
 * @parameters
 *      NSString *databaseName             - target database name
 *      DBCDatabaseLockingMode lockingMode - new locking mode
 *      DBCError **error                   - if an error occurs, upon return contains an DBCError object that describes 
 *                                           the problem. Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setLockingMode:(DBCDatabaseLockingMode)lockingMode forDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Get specified database locking mode
 * @parameters
 *      NSString *databaseName - target database name
 *      DBCError **error       - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                               Pass NULL if you do not want error information.
 * @return specified database locking mode
 */
- (DBCDatabaseLockingMode)lockingModeForDatabase:(NSString*)databaseName error:(DBCError**)error;

/**
 * Set read locks state 
 * @parameters
 *      BOOL omit        - should omit read lock or not
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * @return whether set was successfull or not
 */
- (BOOL)setOmitReadlockLike:(BOOL)omit error:(DBCError**)error;

/**
 * Get whether omit read lock flag or not
 * @parameters
 *      DBCError **error - if an error occurs, upon return contains an DBCError object that describes the problem. 
 *                         Pass NULL if you do not want error information.
 * @return whether omit read lock flag or not
 */
- (BOOL)omitReadlockError:(DBCError**)error;

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
- (BOOL)registerModule:(const sqlite3_module*)module moduleName:(NSString*)moduleName userData:(void*)userData 
       cleanupFunction:(void(*)(void*))cleanupFunction error:(DBCError**)error;

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
- (BOOL)registerScalarFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))function functionName:(NSString*)fnName 
               parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation 
                      userData:(void*)fnUserData error:(DBCError**)error;

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
- (BOOL)unRegisterScalarFunction:(NSString*)fnName parametersCount:(int)fnParametersCount 
         textValueRepresentation:(int)expectedTextValueRepresentation error:(DBCError**)error;

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
- (BOOL)registerAggregationFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))stepFunction 
                   finalizeFunction:(void(*)(sqlite3_context*))finalizeFunction functionName:(NSString*)fnName 
                    parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation 
                           userData:(void*)fnUserData error:(DBCError**)error;

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
- (BOOL)unRegisterAggregationFunction:(NSString*)fnName parametersCount:(int)fnParametersCount 
              textValueRepresentation:(int)expectedTextValueRepresentation error:(DBCError**)error;

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
- (BOOL)registerCollationFunction:(int(*)(void*, int, const void*, int, const void*))function 
                  cleanupFunction:(void(*)(void*))cleanupFunction functionName:(NSString*)fnName 
          textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData error:(DBCError**)error;

/**
 * Unregister collation function. Should be used same function parameteres, which was used to register it
 * @parameters
 *      NSString* fnName                                       - registered function name
 *      int expectedTextValueRepresentation                    - expected passed text value representation
 *                                                               SQLITE_UTF8, SQLITE_UTF16, SQLITE_UTF16BE, 
 *                                                               SQLITE_UTF16LE, SQLITE_UTF16_ALIGNED, or SQLITE_ANY
 *  @return return code which indicate was function unregistered or not
 */
- (BOOL)unRegisterCollationFunction:(NSString*)fnName textValueRepresentation:(int)expectedTextValueRepresentation 
                              error:(DBCError**)error;

@end
