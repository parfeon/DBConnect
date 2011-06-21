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

#ifndef DBC_ADDITIONAL_ERROR_CODES_H_
    #define DBC_ADDITIONAL_ERROR_CODES_H_ 1
    #define SQLITE_OOM 2000
    #define SQLITE_SYNTAX_ERROR 2001
    #define SQLITE_INCOMPLETE_REQUEST 2002
    #define SQLITE_GENERAL_PROCESSING_ERROR 2003

    #define DBC_TARGET_FILE_MISSED 3000
    #define DBC_WRONG_BINDING_PARMETERS_COUNT 3001
    #define DBC_CANT_CREATE_FOLDER_FOR_MUTABLE_DATABASE 3002
    #define DBC_CANT_COPY_DATABASE_FILE_TO_NEW_LOCATION 3003
    #define DBC_CANT_REMOVE_CREATED_CORRUPTED_DATABASE_FILE 3004
    #define DBC_DATABASE_PATH_NOT_SPECIFIED 3005
#endif //DBC_ADDITIONAL_ERROR_CODES_H_