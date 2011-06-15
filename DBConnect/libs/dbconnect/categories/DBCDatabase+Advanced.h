//
//  DBCDatabase+Advanced.h
//  DBConnect
//
//  Created by Sergey Mamontov on 6/11/11.
//  Copyright 2011 Tattooed Orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBCDatabase.h"

@interface DBCDatabase (DBCDatabase_Advanced)

#pragma mark DBCDatabase instance initialization

- (BOOL)openWithFlags:(int)flags;

#pragma mark SQLite database file pages

- (BOOL)freeUnusedPages;
- (int)freePagesCountInDatabase:(NSString*)databaseName;
- (int)pagesCountInDatabase:(NSString*)databaseName;
- (BOOL)setPageSizeInDatabase:(NSString*)databaseName size:(int)newPageSize;
- (int)pageSizeInDatabase:(NSString*)databaseName;
- (BOOL)setMaximumPageCountForDatabase:(NSString*)databaseName size:(int)newPageCount;
- (BOOL)resetMaximumPageCountForDatabase:(NSString*)databaseName;
- (int)maximumPageCountForDatabase:(NSString*)databaseName;

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
- (DBCDatabaseJournalingMode)journalModeForTable:(NSString*)databaseName;
- (BOOL)setJournalSizeLimitForDatabase:(NSString*)databaseName size:(long long int)newJournalSizeLimit;
- (long long int)journalSizeLimitForDatabase:(NSString*)databaseName;

#pragma mark Database locking

- (BOOL)setLockingMode:(DBCDatabaseLockingMode)lockingMode;
- (DBCDatabaseLockingMode)lockingMode;
- (BOOL)setLockingMode:(DBCDatabaseLockingMode)lockingMode forDatabase:(NSString*)databaseName;
- (DBCDatabaseLockingMode)lockingModeForTable:(NSString*)databaseName;
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
