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

#import "DBCError.h"

@implementation DBCError

+ (NSString*)errorDescriptionByCode:(int)errorCode {
    if(errorCode == SQLITE_ERROR)
        return @"SQL error or missing database.";
    if(errorCode == SQLITE_INTERNAL)
        return @"Internal logic error in SQLite.";
    if(errorCode == SQLITE_PERM)
        return @"Access permission denied.";
    if(errorCode == SQLITE_ABORT)
        return @"Callback routine requested an abort.";
    if(errorCode == SQLITE_BUSY)
        return @"The database file is locked.";
    if(errorCode == SQLITE_LOCKED)
        return @"A table in the database is locked.";
    if(errorCode == SQLITE_NOMEM)
        return @"A malloc() failed.";
    if(errorCode == SQLITE_READONLY)
        return @"Attempt to write a readonly database.";
    if(errorCode == SQLITE_INTERRUPT)
        return @"Operation terminated by sqlite3_interrupt().";
    if(errorCode == SQLITE_IOERR)
        return @"Some kind of disk I/O error occurred.";
    if(errorCode == SQLITE_CORRUPT)
        return @"The database disk image is malformed.";
    if(errorCode == SQLITE_NOTFOUND)
        return @"Table or record not found.";
    if(errorCode == SQLITE_FULL)
        return @"Insertion failed because database is full.";
    if(errorCode == SQLITE_CANTOPEN)
        return @"Unable to open the database file.";
    if(errorCode == SQLITE_PROTOCOL)
        return @"Database lock protocol error.";
    if(errorCode == SQLITE_EMPTY)
        return @"Database is empty.";
    if(errorCode == SQLITE_SCHEMA)
        return @"The database schema changed.";
    if(errorCode == SQLITE_TOOBIG)
        return @"String or BLOB exceeds size limit.";
    if(errorCode == SQLITE_CONSTRAINT)
        return @"Abort due to constraint violation.";
    if(errorCode == SQLITE_MISMATCH)
        return @"Data type mismatch.";
    if(errorCode == SQLITE_MISUSE)
        return @"Library used incorrectly.";
    if(errorCode == SQLITE_NOLFS)
        return @"Uses OS features not supported on host.";
    if(errorCode == SQLITE_AUTH)
        return @"Authorization denied.";
    if(errorCode == SQLITE_FORMAT)
        return @"Auxiliary database format error.";
    if(errorCode == SQLITE_RANGE)
        return @"2nd parameter to sqlite3_bind out of range.";
    if(errorCode == SQLITE_NOTADB)
        return @"File opened that is not a database file.";
    if(errorCode == SQLITE_OOM)
        return @"Out of memory.";
    
    if(errorCode == SQLITE_SYNTAX_ERROR)
        return @"SQL syntax error.";
    if(errorCode == SQLITE_INCOMPLETE_REQUEST)
        return @"Incomplete SQL query.";
    if(errorCode == SQLITE_GENERAL_PROCESSING_ERROR)
        return @"SQL Error.";
    if(errorCode == DBC_TARGET_FILE_MISSED)
        return @"File not exists on provided path.";
    if(errorCode == DBC_WRONG_BINDING_PARMETERS_COUNT)
        return @"Not enough binding parameters was passed to statement";
    if(errorCode == DBC_CANT_CREATE_FOLDER_FOR_MUTABLE_DATABASE)
        return @"Can't create folder for mutable database file on storage";
    if(errorCode == DBC_CANT_COPY_DATABASE_FILE_TO_NEW_LOCATION)
        return @"Can't copy database file to new location";
    if(errorCode == DBC_CANT_REMOVE_CREATED_CORRUPTED_DATABASE_FILE)
        return @"Can't remove corrupted database file because of some file manager error";
    if(errorCode == DBC_DATABASE_PATH_NOT_SPECIFIED)
        return @"SQLite database filepath not specified";
    if(errorCode == DBC_SPECIFIED_FILE_NOT_FOUND)
        return @"Specified file not found";
    
    return @"Unknown";
}

#pragma mark DBCError instance initialization

+ (id)errorWithErrorCode:(NSInteger)code {
    return [[[[self class] alloc] initWithErrorCode:code forFilePath:nil additionalInformation:nil] autorelease];
}

+ (id)errorWithErrorCode:(NSInteger)code forFilePath:(NSString*)filePath {
    return [[[[self class] alloc] initWithErrorCode:code forFilePath:filePath additionalInformation:nil] autorelease];
}

+ (id)errorWithErrorCode:(NSInteger)code forFilePath:(NSString*)filePath 
   additionalInformation:(NSString*)additionalInformation {
    return [[[[self class] alloc] initWithErrorCode:code forFilePath:filePath 
                              additionalInformation:additionalInformation] autorelease];
}

- (id)initWithErrorCode:(NSInteger)code {
    if((self = [self initWithErrorCode:code forFilePath:nil additionalInformation:nil])){
        
    }
    return self;
}

- (id)initWithErrorCode:(NSInteger)code forFilePath:(NSString*)filePath {
    if((self = [self initWithErrorCode:code forFilePath:filePath additionalInformation:nil])){
        
    }
    return self;
}

- (id)initWithErrorCode:(NSInteger)code forFilePath:(NSString*)filePath 
  additionalInformation:(NSString*)additionalInformation {
    if((self = [self initWithErrorCode:code errorDomain:kSQLiteErrorDomain forFilePath:filePath 
                 additionalInformation:additionalInformation])) {
    }
    return self;
}

- (id)initWithErrorCode:(NSInteger)code errorDomain:(NSString*)errorDomain forFilePath:(NSString*)filePath 
  additionalInformation:(NSString*)additionalInformation {
    if(additionalInformation==nil) {
        self = [super initWithDomain:errorDomain code:code 
                            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[DBCError errorDescriptionByCode:code], 
                                      NSLocalizedDescriptionKey, filePath, NSFilePathErrorKey, nil]];
    } else {
        self = [super initWithDomain:errorDomain code:code 
                            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[DBCError errorDescriptionByCode:code], 
                                      NSLocalizedDescriptionKey, additionalInformation, DBCAdditionalErrorInformation, 
                                      filePath, NSFilePathErrorKey, nil]];
    }
    return self;
}

#pragma mark DBCError for NSLog

- (NSString*)description {
    NSString *filePath = [self userInfo]!=nil?[[self userInfo] objectForKey:NSFilePathErrorKey]!=nil?
        [[self userInfo] valueForKey:NSFilePathErrorKey]:nil:nil;
    NSString *additionalErrorDescription = [self userInfo]!=nil?
        [[self userInfo] objectForKey:DBCAdditionalErrorInformation]!=nil?
            [[self userInfo] valueForKey:DBCAdditionalErrorInformation]:nil:nil;
    if(filePath == nil){
        if(additionalErrorDescription == nil)
            return [NSString stringWithFormat:@"Error Domain=%@ Code=%i \"%@ (%@ %i.)\"", [self domain], [self code],
                    [self localizedDescription], [self domain], [self code]];
        return [NSString stringWithFormat:@"Error Domain=%@ Code=%i \"%@ (%@ %i.)\". Description: %@", [self domain], 
                [self code], [self localizedDescription], [self domain], [self code], additionalErrorDescription];
    }
    if(additionalErrorDescription == nil)
        return [NSString stringWithFormat:@"Error Domain=%@ Code=%i \"%@ (%@ %i.)\". DBPath=%@", [self domain], 
                [self code], [self localizedDescription], [self domain], [self code], filePath];
    return [NSString stringWithFormat:@"Error Domain=%@ Code=%i \"%@ (%@ %i.)\". DBPath=%@. Description: %@", 
            [self domain], [self code], [self localizedDescription], [self domain], [self code], filePath, 
            additionalErrorDescription];
}

@end
