#DBConnect

__DBConnect__ is a thread-safe Objective-C [SQLite][sqliteweb] wrapper for embedded systems. I was inspired by [EGODatabase][EGODatabasews] and [FMDB][FMDBws] when were writing __DBConnect__  
[sqliteweb]:http://www.sqlite.org  
[EGODatabasews]:https://github.com/enormego/egodatabase  
[FMDBws]:https://github.com/shifu/fmdb  
__DBConnect__ is tested to work on iOS

#__DBConnect library structure__  
__DBConnect__ consist from four basic classes:  
__1.__ DBCDatabase  
__2.__ DBCDatabaseResult  
__3.__ DBCDatabaseRow  
__4.__ DBCError  
There also other classes: __DBCDatabaseInfo__, __DBCDatabaseIndexInfo__, __DBCDatabaseTableColumnInfo__, __DBCDatabaseIndexedColumnInfo__  
Also __DBConnect__ have 2 categories to extend it abilities: __Advanced__, __Aliases__. __DBConnect__ functionality was knowingly separated. __Advanced__ will be interested for advanced users. __Aliases__ contains methods, which are basically aliases for frequent queries. Functionality was separated to keep autocomplete from bunch of methods, which you possibly won't never use.

##__DBCDatabase__  
This is basic class, which provide intuitive Objective-C API to work with SQLite3 library. It allows to open connection to sqlite database file in _read-write_ and _read-only_ mode. Of course it also allow you to perform DDL, DML and TCL queries. Also this class allows you to create database from scratch, using SQL dump (like dump from MySQL). 

##__DBCDatabaseResult__
This class used by __DBConnect__ to provide results from query execution. This class implements fast enumeration for faster iteration through result entries.

##__DBCDatabaseRow__
__DBConnect__ uses this class to store data retrieved when stepped with sqlite statement. 

##__DBCError__
__DBCError__ used by __DBConnect__ to represent errors, which occurred during lifetime.

#__Documentation and how-to's__
Documentation and additional information about usage you can find in [Wiki][wikiMain]  
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