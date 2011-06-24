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

- (BOOL)openWithFlags:(int)flags error:(DBCError**)error;

#pragma mark SQLite database file pages

- (BOOL)freeUnusedPagesError:(DBCError**)error;
- (int)freePagesCountInDatabase:(NSString*)databaseName error:(DBCError**)error;
- (int)pagesCountInDatabase:(NSString*)databaseName error:(DBCError**)error;
- (BOOL)setPageSizeInDatabase:(NSString*)databaseName size:(int)newPageSize error:(DBCError**)error;
- (int)pageSizeInDatabase:(NSString*)databaseName error:(DBCError**)error;
- (BOOL)setMaximumPageCountForDatabase:(NSString*)databaseName size:(int)newPageCount error:(DBCError**)error;
- (BOOL)resetMaximumPageCountForDatabase:(NSString*)databaseName error:(DBCError**)error;
- (int)maximumPageCountForDatabase:(NSString*)databaseName error:(DBCError**)error;

#pragma mark Database backup/restore

- (BOOL)restore:(NSString*)dstDatabaseName fromFile:(NSString*)srcDatabaseFile database:(NSString*)srcDatabaseName error:(DBCError**)error;
- (BOOL)restore:(NSString*)dstDatabaseName from:(sqlite3*)srcDatabaseConnection database:(NSString*)srcDatabaseName error:(DBCError**)error;
- (BOOL)backup:(NSString*)srcDatabaseName toFile:(NSString*)dstDatabaseFile database:(NSString*)dstDatabaseName error:(DBCError**)error;
- (BOOL)backup:(NSString*)srcDatabaseName to:(sqlite3*)dstDatabase database:(NSString*)dstDatabaseName error:(DBCError**)error;

#pragma mark Transaction journal

- (BOOL)turnOffJournalingError:(DBCError**)error;
- (BOOL)turnOffJournalingForDatabase:(NSString*)databaseName error:(DBCError**)error;
- (BOOL)turnOnJournalingError:(DBCError**)error;
- (BOOL)turnOnJournalingForDatabase:(NSString*)databaseName error:(DBCError**)error;
- (BOOL)setJournalMode:(DBCDatabaseJournalingMode)journalMode error:(DBCError**)error;
- (DBCDatabaseJournalingMode)journalModeError:(DBCError**)error;
- (BOOL)setJournalMode:(DBCDatabaseJournalingMode)journalMode forDatabase:(NSString*)databaseName error:(DBCError**)error;
- (DBCDatabaseJournalingMode)journalModeForDatabase:(NSString*)databaseName error:(DBCError**)error;
- (BOOL)setJournalSizeLimitForDatabase:(NSString*)databaseName size:(long long int)newJournalSizeLimit error:(DBCError**)error;
- (long long int)journalSizeLimitForDatabase:(NSString*)databaseName error:(DBCError**)error;

#pragma mark Database locking

- (BOOL)setLockingMode:(DBCDatabaseLockingMode)lockingMode error:(DBCError**)error;
- (DBCDatabaseLockingMode)lockingModeError:(DBCError**)error;
- (BOOL)setLockingMode:(DBCDatabaseLockingMode)lockingMode forDatabase:(NSString*)databaseName error:(DBCError**)error;
- (DBCDatabaseLockingMode)lockingModeForDatabase:(NSString*)databaseName error:(DBCError**)error;
- (BOOL)setOmitReadlockLike:(BOOL)omit error:(DBCError**)error;
- (BOOL)omitReadlockError:(DBCError**)error;

#pragma mark Database virtual table (module) registration

- (BOOL)registerModule:(const sqlite3_module*)module moduleName:(NSString*)moduleName userData:(void*)userData cleanupFunction:(void(*)(void*))cleanupFunction error:(DBCError**)error;

#pragma mark Database functions registration/unregistration

- (BOOL)registerScalarFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))function functionName:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData error:(DBCError**)error;
- (BOOL)unRegisterScalarFunction:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation error:(DBCError**)error;
- (BOOL)registerAggregationFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))stepFunction finalizeFunction:(void(*)(sqlite3_context*))finalizeFunction functionName:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData error:(DBCError**)error;
- (BOOL)unRegisterAggregationFunction:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation error:(DBCError**)error;
- (BOOL)registerCollationFunction:(int(*)(void*, int, const void*, int, const void*))function cleanupFunction:(void(*)(void*))cleanupFunction functionName:(NSString*)fnName textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData error:(DBCError**)error;
- (BOOL)unRegisterCollationFunction:(NSString*)fnName textValueRepresentation:(int)expectedTextValueRepresentation error:(DBCError**)error;

@end
