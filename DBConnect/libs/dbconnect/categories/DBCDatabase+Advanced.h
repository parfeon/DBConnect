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

- (BOOL)restoreDatabaseFromFile:(NSString*)dbFilePath;
- (BOOL)restoreDatabaseFromFile:(NSString*)dbFilePath database:(NSString*)databaseName;
- (BOOL)backupDatabaseToFile:(NSString*)dbFileStorePath;
- (BOOL)backupDatabaseToFile:(NSString*)dbFileStorePath fromDatabase:(NSString*)databaseName;

#pragma mark Transaction journal

- (BOOL)turnOffJournaling;
- (BOOL)turnOffJournalingForDatabase:(NSString*)databaseName;
- (BOOL)turnOnJournaling;
- (BOOL)turnOnJournalingForDatabase:(NSString*)databaseName;
- (BOOL)setJournalMode:(DBCDatabaseJournalingMode)journalMode;
- (DBCDatabaseJournalingMode)journalMode;
- (BOOL)setJournalMode:(DBCDatabaseJournalingMode)journalMode forDatabase:(NSString*)databaseName;
- (DBCDatabaseJournalingMode)journalModeForDatabase:(NSString*)databaseName;
- (BOOL)setJournalSizeLimitForDatabase:(NSString*)databaseName size:(long long int)newJournalSizeLimit;
- (long long int)journalSizeLimitForDatabase:(NSString*)databaseName;

#pragma mark Database locking

- (BOOL)setLockingMode:(DBCDatabaseLockingMode)lockingMode;
- (DBCDatabaseLockingMode)lockingMode;
- (BOOL)setLockingMode:(DBCDatabaseLockingMode)lockingMode forDatabase:(NSString*)databaseName;
- (DBCDatabaseLockingMode)lockingModeForDatabase:(NSString*)databaseName;
- (BOOL)setOmitReadlockLike:(BOOL)omit;
- (BOOL)omitReadlock;

#pragma mark Database virtual table (module) registration

- (int)registerModule:(const sqlite3_module*)module moduleName:(NSString*)moduleName userData:(void*)userData cleanupFunction:(void(*)(void*))cleanupFunction;

#pragma mark Database functions registration/unregistration

- (int)registerScalarFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))function functionName:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData;
- (int)unRegisterScalarFunction:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation;
- (int)registerAggregationFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))stepFunction finalyzeFunction:(void(*)(sqlite3_context*))finalyzeFunction functionName:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData;
- (int)unRegisterAggregationFunction:(NSString*)fnName parametersCount:(int)fnParametersCount textValueRepresentation:(int)expectedTextValueRepresentation;
- (int)registerCollationFunction:(int(*)(void*, int, const void*, int, const void*))function cleanupFunction:(void(*)(void*))cleanupFunction functionName:(NSString*)fnName textValueRepresentation:(int)expectedTextValueRepresentation userData:(void*)fnUserData;
- (int)unRegisterCollationFunction:(NSString*)fnName textValueRepresentation:(int)expectedTextValueRepresentation;

@end
