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

#import "DBCConfiguration.h"

#define DBCReleaseObject(__OBJECT__) if(__OBJECT__!=nil){[__OBJECT__ release], __OBJECT__ = nil; }

#define DBCDatabaseTransactionLockNameFromEnum(__LOCK_ENUM__) ({\
    NSString *lockName = nil;\
    if(__LOCK_ENUM__==DBCDatabaseAutocommitModeDeferred) lockName=@"DEFERRED";\
    if(__LOCK_ENUM__==DBCDatabaseAutocommitModeImmediate) lockName=@"IMMEDIATE";\
    if(__LOCK_ENUM__==DBCDatabaseAutocommitModeExclusive) lockName=@"EXCLUSIVE";\
    lockName;\
})

#define DBCDatabaseDataTypeStringify(__DATA_TYPE__)({\
    NSString *dataTypeName = nil;\
    if(__DATA_TYPE__ == SQLITE_INTEGER) dataTypeName = @"integer";\
    else if(__DATA_TYPE__ == SQLITE_FLOAT) dataTypeName = @"float";\
    else if(__DATA_TYPE__ == SQLITE_TEXT) dataTypeName = @"text";\
    else if(__DATA_TYPE__ == SQLITE_BLOB) dataTypeName = @"blob";\
    else if(__DATA_TYPE__ == SQLITE_NULL) dataTypeName = @"null";\
    else dataTypeName = @"unknown";\
    dataTypeName;\
})

#define DBCDatabaseEncodedSQLiteError(__ENCODING__)({\
    const char *cErrorMsg = __ENCODING__==DBCDatabaseEncodingUTF16?sqlite3_errmsg16(dbConnection):\
sqlite3_errmsg(dbConnection);\
    NSString *errorMsg = nil;\
    if(cErrorMsg!=NULL)\
        errorMsg = [NSString stringWithCString:cErrorMsg \
            encoding:(dbEncoding==DBCDatabaseEncodingUTF16?NSUTF16StringEncoding:NSUTF8StringEncoding)];\
    errorMsg;\
})

#if DBCUseDebugLogger
    #define DBCDebugLogger(...) NSLog(__VA_ARGS__)
#else
    #define DBCDebugLogger(...)
#endif

#if DBCUseLockLogger
    #define DBCLockLogger(...) NSLog(__VA_ARGS__)
#else
    #define DBCLockLogger(...)
#endif