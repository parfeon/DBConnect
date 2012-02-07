#DBConnect

__DBConnect__ is a thread-safe Objective-C [SQLite][sqliteweb] wrapper for embedded systems. I was inspired by [EGODatabase][EGODatabasews] and [FMDB][FMDBws] when writing __DBConnect__  
[sqliteweb]:http://www.sqlite.org  
[EGODatabasews]:https://github.com/enormego/egodatabase  
[FMDBws]:https://github.com/shifu/fmdb  
__DBConnect__ was tested to work on iOS

#__DBConnect library structure__  
__DBConnect__ consist from four basic classes:  
__1.__ DBCDatabase  
__2.__ DBCDatabaseResult  
__3.__ DBCDatabaseRow  
__4.__ DBCError  
There are also other classes: __DBCDatabaseInfo__, __DBCDatabaseIndexInfo__, __DBCDatabaseTableColumnInfo__, __DBCDatabaseIndexedColumnInfo__  
Also __DBConnect__ has 2 categories to extend its abilities: __Advanced__, __Aliases__. __DBConnect__ functionality was knowingly separated. __Advanced__ will be interested for advanced users. __Aliases__ contains methods, which are basically aliases for frequent queries. Functionality was separated to keep autocomplete away from bunch of methods, which you will possibly never use.

##__DBCDatabase__  
This is a basic class, which provides intuitive Objective-C API to work with SQLite3 library. It allows opening connection to sqlite database file in _read-write_ and _read-only_ modes. Of course, it also allows you to perform DDL, DML and TCL queries. Also this class allows you to create database from scratch, using SQL dump (like dump from MySQL). 

##__DBCDatabaseResult__
This class is used by __DBConnect__ to provide results from query execution. This class implements fast enumeration for faster iteration through result's entries.

##__DBCDatabaseRow__
__DBConnect__ uses this class to store data retrieved when stepped using sqlite statement. 

##__DBCError__
__DBCError__ is used by __DBConnect__ to represent errors, which occurred during lifetime.

#__Documentation and how-to__
Documentation and additional information about the usage you can find in [Wiki][wikiMain]  
[wikiMain]:https://github.com/parfeon/DBConnect/wiki

#__License__
Copyright (c) 2011 Sergey Mamontov
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.