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

#import "DBCDatabaseInfo.h"
#import "DBCMacro.h"


@implementation DBCDatabaseInfo

@synthesize dbSeqNumber, dbName, dbFilePath;

#pragma mark DBCDatabaseInfo instance initialization

+ (id)databaseInfoWithSequence:(int)sequenceNumber name:(NSString*)databaseName filePath:(NSString*)pathToDatabaseFile {
    return [[[[self class] alloc] initDatabaseInfoWithSequence:sequenceNumber name:databaseName 
                                                      filePath:pathToDatabaseFile] autorelease];
}

- (id)initDatabaseInfoWithSequence:(int)sequenceNumber name:(NSString*)databaseName 
                          filePath:(NSString*)pathToDatabaseFile {
    if((self = [super init])){
        dbSeqNumber = sequenceNumber;
        dbName = [databaseName copy];
        dbFilePath = [pathToDatabaseFile copy];
    }
    return self;
}

#pragma mark DBCDatabaseInfo for NSLog

- (NSString*)description {
    return [NSString stringWithFormat:@"\nSequence number: %i\nDatabase name: %@\nDatabase file path: %@", dbSeqNumber, 
            dbName, dbFilePath];
}

#pragma mark DBCDatabaseInfo memory management

- (void)dealloc {
    DBCReleaseObject(dbName);
    DBCReleaseObject(dbFilePath);
    [super dealloc];
}

@end
