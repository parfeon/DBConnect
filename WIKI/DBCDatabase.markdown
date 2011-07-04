#__DBCDatabase Class Reference__  
[SQLitews]:http://www.sqlite.org  
[MAS]:http://www.apple.com/mac/app-store/  
[DBCDatabase+Advanced]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase+Advanced
[DBCDatabase+AdvancedOpen]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase+Advanced#m1  
[DBCDatabase+AiasesAttach]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase+Aiases#m1  
[DBCDatabaseResultCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseResult  
[DBCDatabaseRowCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseRow  
[DBCDatabaseEncodingUTF8c]:https://github.com/parfeon/DBConnect/wiki/Constants#DBCDatabaseEncodingUTF8  
[DBCDatabaseTransactionLockC]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseTransactionLock  
[DBCDatabaseAutocommitModeDeferredc]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseTransactionLock#DBCDatabaseAutocommitModeDeferred  
[DBCErrorwiki]:https://github.com/parfeon/DBConnect/wiki/DBCError  
<a name="top"/><font size="6">__Overview__</font>  
The __DBCDatabase__ defines methods to communicate with [SQLite][SQLitews] database.  
  
__DBCDatabase__ designed to:  
<ul>  
<li> control multi-threaded access to database handler (if it was passed to another thread) or <a href="http://www.sqlite.org">sqlite</a> database file</li>  
<li> execute queries and updates to database</li>  
<li> cache prepared <a href="http://www.sqlite.org">sqlite</a> statements (this allow to speed up requests execution)</li>  
<li> control SQL transactions</li>  
<li> create new database with <i>'read-only'</i> or <i>'read-write'</i> access</li>  
<li> create new database from SQL dump file (file like MySQL database dump file)</li>  
<li> create mutable copy of database</li>  
</ul>

<a name="basicExample"/>In some methods I'll reference on this small example:
<pre>
<font color="#547f85">DBCError</font> *error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#cb3229">@":memory:"</font>];
<font color="#b7359d">if</font>([db <font color="#38595d">openError</font>:&error]){
    [db <font color="#38595d">executeUpdate</font>:<font color="#cb3229">@"DROP TABLE IF EXISTS test;
                        CREATE TABLE IF NOT EXISTS test (pid INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,  \
                                                         pType TEXT NOT NULL, pTitle TEXT,                \
                                                         loc_lat FLOAT NOT NULL, loc_lon FLOAT NOT NULL); \
                        CREATE UNIQUE INDEX locationIndex ON test (loc_lat, loc_lon);                     \
                        INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?2, ?3, ?4 );     \
                        INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?5, ?6, ?7 );     \
                        INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?8, ?9, ?10 );    \
                        INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?11, ?12, ?13 );"</font>
                 <font color="#38595d">error</font>:&error, 
                       <font color="#cb3229">@"City"</font>, <font color="#cb3229">@"Cupertino"</font>, [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:37.3261f],
                       [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:-122.0320f], <font color="#cb3229">@"New York"</font>, [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:40.724f],
                       [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:-74.06f], <font color="#cb3229">@"Dnepropetrovsk"</font>, [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:48.47f],
                       [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:35.050f], <font color="#cb3229">@"Kiev"</font>, [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:50.457f],
                       [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:30.525f],
                       <font color="#b7359d">nil</font>];
    <font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
        <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
           for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
        <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
    }
} <font color="#b7359d">else</font> {
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

##__Tasks__
###__DBCDatabase instance initialization__
<a href="#m1">+ databaseWithPath:</a>  
<a href="#m2">+ databaseWithPath:defaultEncoding:</a>  
<a href="#m3">+ databaseFromFile:atPath:continueOnExecutionErrors:error:</a>  
<a href="#m4">+ databaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</a>  
<a href="#m5">- initWithPath:defaultEncoding:</a>  
<a href="#m6">- createDatabaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</a>
###__DBCDatabase sqlite database connection open/close__
<a href="#m7">- openError:</a>  
<a href="#m8">- openReadonlyError:</a>  
<a href="#m9">- makeMutableAt:error:</a>  
<a href="#m10">- closeError:</a>  
###__DBCDatabase DDL and DML__  
<a href="#m11">- executeUpdate:error:</a>  
<a href="#m12">- executeQuery:error:</a>  
<a href="#m13">- executeStatementsFromFile:continueOnExecutionErrors:error:</a>  
###__DBCDatabase TCL__  
<a href="#m14">- beginTransactionError:</a>  
<a href="#m15">- beginDeferredTransactionError:</a>  
<a href="#m16">- beginImmediateTransactionError:</a>  
<a href="#m17">- beginExclusiveTransactionError:</a>  
<a href="#m18">- commitTransactionError:</a>  
<a href="#m19">- rollbackTransactionError:</a>  
###__DBCDatabase properties__
<a href="#p1">busyRetryCount</a>  
<a href="#p2">defaultSQLSequencesTransactionLock</a>  
<a href="#p3">statementsCachingEnabled</a>  
<a href="#p4">rollbackSQLSequenceTransactionOnError</a>  
<a href="#p5">createTransactionOnSQLSequences</a>  
<a href="#p6">database</a>  
  
##__Properties__  
  
<font size="4"><a name="p1"/>busyRetryCount</font>  
  
This property stores statements execution retry count.  

<pre>@property (nonatomic)int busyRetryCount</pre>  
  
__Discussion__  
If you pass reference on __DBCDatabase__ to another thread or maybe few instances of __DBCDatabase__ access to same [sqlite][SQLitews] database file at same time, requests execution may not pass because database is busy or locked. This parameter tells to __DBCDatabase__ instance to retry for specified number of times to execute statement.  
By default value set to `5`.  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="p2"/>defaultSQLSequencesTransactionLock</font>  
  
This property stores default SQL statements transaction lock.  
  
<pre>@property (nonatomic)DBCDatabaseTransactionLock defaultSQLSequencesTransactionLock</pre>  

__Discussion__  
Available list of [DBCDatabaseTransactionLock][DBCDatabaseTransactionLockC] locks.  
By default value set to [DBCDatabaseAutocommitModeDeferred][DBCDatabaseAutocommitModeDeferredc].  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="p3"/>statementsCachingEnabled</font>  
  
This property specify whether compiled statements caching enabled or not.  

<pre>@property (nonatomic, getter = isStatementsCachingEnabled)BOOL statementsCachingEnabled</pre>  
  
__Discussion__  
This flag tells __DBCDatabase__ to cache compiled statements to make their future execution faster, because there is no time loss on statement compilation.  
By default value set to `YES`.  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="p4"/>rollbackSQLSequenceTransactionOnError</font>  
  
This property specify whether __DBCDatabase__ should rollback statements which was executed inside of transaction or not.  

<pre>@property (nonatomic)BOOL rollbackSQLSequenceTransactionOnError</pre>  
  
__Discussion__  
If `YES` __DBCDatabase__ will automatically rollback transaction (if started).  
By default value set to `YES`.  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="p5"/>createTransactionOnSQLSequences</font>  
  
This property stores specify whether __DBCDatabase__ should wrap SQL statements sequence with TCL or not.  

<pre>@property (nonatomic)BOOL createTransactionOnSQLSequences</pre>  
  
__Discussion__  
If `YES` __DBCDatabase__ will automatically wrap SQL statements sequence with transaction BEGIN and COMMIT (if transaction control not detected in provided SQL statements list).  
By default value set to `YES`.  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="p6"/>database</font>  
  
This property stores reference on opened [SQLite][SQLitews] database connection.  

<pre>@property (nonatomic, readonly, getter = database)sqlite3 *dbConnection</pre>  
  
__Return value__  
Reference on opened [sqlite][SQLitews] database connection or `nil`.  
  
__Discussion__  
If database connection is opened, than this property will return reference on it, otherwise `nil`.  
  
<a href="#top">Top</a>  
  
##__Class methods__  
  
<font size="4"><a name="m1"/>databaseWithPath:</font>  
  
Create and initialize __DBCDatabase__ instance, which can be used to communicate with [sqlite][SQLitews].  
  
<pre>+ (id)databaseWithPath:(NSString*)<i>dbFilePath</i></pre>  
__Parameters__  
_dbFilePath_  
&nbsp;&nbsp;&nbsp;&nbsp;[SQLite][SQLitews] database source can be specified as: `path`, `file`, `":memory:"`, `""` or `nil`.  
  
__Return value__  
Autoreleased __DBCDatabase__ instance.  
  
__Discussion__  
This is the fastest method to create __DBCDatabase__ and start to work with database. This method will prepare __DBCDatabase__ to work with database in UTF-8 encoding.  
If you planing to use database with _read-write_ access, you should place [sqlite][SQLitews] database file somewhere, where system can change file. Don't forget, what in iOS and Mac OS X (apps from [Mac App Store][MAS]) applications you can't modify database file inside application bundle.  
  
_dbFilePath_ tells to __DBCDatabase__ where it should open/create database:  
&nbsp;&nbsp;&nbsp;&nbsp;1. if _dbFilePath_ is absolute path to database file, then __DBCDatabase__ will use that persistent [sqlite][SQLitews] database file. If file not exists, it will be created.  
&nbsp;&nbsp;&nbsp;&nbsp;2. if _dbFilePath_ is `":memory:"`, then __DBCDatabase__ will create temporary `in-memory` database. Database can be reached only from instance, which created it. When database connection will be closed, database will be removed from memory.  
&nbsp;&nbsp;&nbsp;&nbsp;3. if _dbFilePath_ is `""` or `nil`, then __DBCDatabase__ will create temporary database on device like file. As `in-memory` database, it can be reached only from instance, which created it and will be removed from filesystem as soon as connection will be closed.  
  
__How to use__  
Create __DBCDatabase__ instance for [sqlite][SQLitews] database file, stored in _Documents_ directory for example:
<pre>
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#cb3229">@"test.sqlite"</font>];
</pre>  
  
Create __DBCDatabase__ instance for database, which will be temporary stored in memory:
<pre>
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#cb3229">@":memory:"</font>];
</pre>
  
Create __DBCDatabase__ instance for database, which will be temporary stored on filesystem:
<pre>
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#cb3229">@""</font>];
</pre>  
<pre>
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#b7359d">nil</font>];
</pre>
  
__See Also__  
<a href="#m2">+ databaseWithPath:defaultEncoding:</a>  
<a href="#m3">+ databaseFromFile:atPath:continueOnExecutionErrors:error:</a>  
<a href="#m4">+ databaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</a>  
<a href="#m5">- initWithPath:defaultEncoding:</a>  
<a href="#m6">- createDatabaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m2"/>databaseWithPath:defaultEncoding:</font>  
  
Create and initialize __DBCDatabase__ instance, which can be used to communicate with [sqlite][SQLitews]  
    
<pre>+ (id)databaseWithPath:(NSString*)<i>dbFilePath</i> defaultEncoding:(DBCDatabaseEncoding)<i>encoding</i></pre>  
__Parameters__  
_dbFilePath_  
&nbsp;&nbsp;&nbsp;&nbsp;[SQLite][SQLitews] database source can be specified as: `path`, `file`, `":memory:"`, `""` or `nil`.  
_encoding_  
&nbsp;&nbsp;&nbsp;&nbsp;The database encoding, which will be used to define which method from <a href="http://www.sqlite.org/capi3ref.html">SQLite C API</a> to use. The default value is [DBCDatabaseEncodingUTF8][DBCDatabaseEncodingUTF8c].  
  
__Return value__  
Autoreleased __DBCDatabase__ instance.  
  
__Discussion__  
This method creates __DBCDatabase__ and prepares it to work with provided encoding. There are few methods in <a href="http://www.sqlite.org/capi3ref.html">SQLite C API</a> which can be used specially for UTF-8/UTF-16 encodings. But I hope you will keep close to the light side of the force and use UTF-8 encoding.  
If you planing to use database with _read-write_ access, you should place [sqlite][SQLitews] database file somewhere, where system can change file. Don't forget, what in iOS and Mac OS X (apps from [Mac App Store][MAS]) applications you can't modify database file inside application bundle.  
    
_dbFilePath_ tells to __DBCDatabase__ where it should open/create database:  
&nbsp;&nbsp;&nbsp;&nbsp;1. if _dbFilePath_ is absolute path to database file, then __DBCDatabase__ will use that persistent [sqlite][SQLitews] database file. If file not exists, it will be created.  
&nbsp;&nbsp;&nbsp;&nbsp;2. if _dbFilePath_ is `":memory:"`, then __DBCDatabase__ will create temporary `in-memory` database. Database can be reached only from instance, which created it. When database connection will be closed, database will be removed from memory.  
&nbsp;&nbsp;&nbsp;&nbsp;3. if _dbFilePath_ is `""` or `nil`, then __DBCDatabase__ will create temporary database on device like file. As `in-memory` database, it can be reached only from instance, which created it and will be removed from filesystem on connection close.  
  
__How to use__  
Usage is almost same as in case of <a href="#m1">databaseWithPath:</a>, but with this method you can additionally specify encoding, which will be used instead of default UTF-8.  
For example, to create __DBCDatabase__ instance using UTF-16 encoding for database, which will be temporary stored in memory do something like this:
<pre>
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#cb3229">@":memory:"</font> <font color="#38595d">defaultEncoding</font>:<font color="#38595d">DBCDatabaseEncodingUTF16</font>];
</pre>  
  
__See Also__  
<a href="#m1">+ databaseWithPath:</a>  
<a href="#m3">+ databaseFromFile:atPath:continueOnExecutionErrors:error:</a>  
<a href="#m4">+ databaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</a>  
<a href="#m5">- initWithPath:defaultEncoding:</a>  
<a href="#m6">- createDatabaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</a>  
  
<a href="#top">Top</a>  

* * *    
  
<font size="4"><a name="m3"/>databaseFromFile:atPath:continueOnExecutionErrors:error:</font>  
  
Create and initialize __DBCDatabase__ instance, which will create/restore/update database from external dump file for you.  
  
<pre>+ (id)databaseFromFile:(NSString*)<i>sqlStatementsListFilepath</i> atPath:(NSString*)<i>dbFilePath</i> 
 continueOnExecutionErrors:(BOOL)<i>continueOnExecutionErrors</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_sqlStatementsListFilepath_  
&nbsp;&nbsp;&nbsp;&nbsp;The path or file for database dump with SQL statements list.  
_dbFilePath_  
&nbsp;&nbsp;&nbsp;&nbsp;Dump processing result destination can be specified as: `path`, `file`, `":memory:"`, `""` or `nil`.  
_continueOnExecutionErrors_  
&nbsp;&nbsp;&nbsp;&nbsp;Specify `YES` to proceed dump file processing even in case of SQL execution error or `NO` to terminate processing immediately.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorwiki] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
Autoreleased __DBCDatabase__ instance or `nil` if occurred an error.  
  
__Discussion__  
This method allows you to create/restore/update [sqlite][SQLitews] database from SQL dump file and prepare __DBCDatabase__ to work with it in default UTF-8 encoding.  
You can use `file`, `:memory:` or `""` as target for database dump processing result. This means what you can create some persistent/temporary [sqlite][SQLitews] database. Also this method can be used to perform database upgrades from file with SQL statements.  
After successful execution, you'll get __DBCDatabase__ instance with ready to use, there is no need to call <a href="#7">openError:</a> (but this is OK to do that).  
  
__How to use__  
Create __DBCDatabase__ instance and execute SQL statements from dump file on [sqlite][SQLitews] database file, which stored in _Documents_ directory for example. Processing will proceed even in case of errors in SQL statement execution:
<pre>
<font color="#7243a4">NSString</font> *dumpFilePath = ...;
<font color="#547f85">DBCError</font> *error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseFromFile</font>:dumpFilePath <font color="#38595d">atPath</font>:<font color="#cb3229">@"rstored.sqlite"</font>
                      <font color="#38595d">continueOnExecutionErrors</font>:<font color="#b7359d">YES</font> <font color="#38595d">error</font>:&error];  
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){  
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);  
}
</pre>
  
Create __DBCDatabase__ instance and execute SQL statements from dump file on [sqlite][SQLitews] `in-memory` temporary database. Processing won't proceed in case of errors in SQL statement execution:
<pre>
<font color="#7243a4">NSString</font> *dumpFilePath = ...;
<font color="#547f85">DBCError</font> *error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseFromFile</font>:dumpFilePath <font color="#38595d">atPath</font>:<font color="#cb3229">@":memory:"</font> <font color="#38595d">continueOnExecutionErrors</font>:<font color="#b7359d">NO</font>
                                          <font color="#38595d">error</font>:&error];  
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){  
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);  
}
</pre>
  
Create __DBCDatabase__ instance and execute SQL statements from dump file on [sqlite][SQLitews] database temporary stored on filesystem. Processing won't proceed in case of errors in SQL statement execution:
<pre>
<font color="#7243a4">NSString</font> *dumpFilePath = ...;
<font color="#547f85">DBCError</font> *error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseFromFile</font>:dumpFilePath <font color="#38595d">atPath</font>:<font color="#cb3229">@""</font> <font color="#38595d">continueOnExecutionErrors</font>:<font color="#b7359d">NO</font>
                                          <font color="#38595d">error</font>:&error];  
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){  
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);  
}
</pre>  
  
__See Also__  
<a href="#m1">+ databaseWithPath:</a>  
<a href="#m2">+ databaseWithPath:defaultEncoding:</a>  
<a href="#m4">+ databaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</a>  
<a href="#m5">- initWithPath:defaultEncoding:</a>  
<a href="#m6">- createDatabaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m4"/>databaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</font>  
  
Create and initialize __DBCDatabase__ instance, which will create/restore/update database from external dump file for you.  

<pre>+ (id)databaseFromFile:(NSString*)<i>sqlStatementsListFilepath</i> atPath:(NSString*)<i>dbFilePath</i> 
       defaultEncoding:(DBCDatabaseEncoding)<i>encoding</i> continueOnExecutionErrors:(BOOL)<i>continueOnExecutionErrors</i> 
                 error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_sqlStatementsListFilepath_  
&nbsp;&nbsp;&nbsp;&nbsp;The path or file for database dump with SQL statements list.  
_dbFilePath_  
&nbsp;&nbsp;&nbsp;&nbsp;Dump processing result destination can be specified as: `path`, `file`, `":memory:"`, `""` or `nil`.  
_encoding_  
&nbsp;&nbsp;&nbsp;&nbsp;The database encoding, which will be used to define which method from <a href="http://www.sqlite.org/capi3ref.html">SQLite C API</a> to use. The default value is [DBCDatabaseEncodingUTF8][DBCDatabaseEncodingUTF8c].  
_continueOnExecutionErrors_  
&nbsp;&nbsp;&nbsp;&nbsp;Specify `YES` to proceed dump file processing even in case of SQL execution error or `NO` to terminate processing immediately.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorwiki] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
Autoreleased __DBCDatabase__ instance or `nil` if occurred an error.  
  
__Discussion__  
As <a href="#m3">databaseFromFile:atPath:continueOnExecutionErrors:error:</a> this method allows you to create/restore/update  [sqlite][SQLitews] database from SQL dump file and prepare __DBCDatabase__ to work with it in specified encoding.  
  
__How to use__  
For example, to create and initialize __DBCDatabase__ instance with UTF-8 encoding for database, which will be temporary stored on filesystem, we need to do something like this:
<pre>
<font color="#7243a4">NSString</font> *dumpFilePath = ...;
<font color="#547f85">DBCError</font> *error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseFromFile</font>:dumpFilePath <font color="#38595d">atPath</font>:<font color="#cb3229">@""</font>  
                                <font color="#38595d">defaultEncoding</font>:<font color="#38595d">DBCDatabaseEncodingUTF8</font> <font color="#38595d">continueOnExecutionErrors</font>:<font color="#b7359d">NO</font>
                                          <font color="#38595d">error</font>:&error];  
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){  
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag  
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);  
}
</pre>

__See Also__  
<a href="#m1">+ databaseWithPath:</a>  
<a href="#m2">+ databaseWithPath:defaultEncoding:</a>  
<a href="#m3">+ databaseFromFile:atPath:continueOnExecutionErrors:error:</a>  
<a href="#m5">- initWithPath:defaultEncoding:</a>  
<a href="#m6">- createDatabaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</a>  
  
<a href="#top">Top</a>  

##__Instance methods__
  
<font size="4"><a name="m5"/>initWithPath:defaultEncoding:</font>  
  
Initialize __DBCDatabase__ instance, which can be used to communicate with [sqlite][SQLitews]  
  
<pre>- (id)initWithPath:(NSString*)<i>dbFilePath</i> defaultEncoding:(DBCDatabaseEncoding)<i>encoding</i></pre>  
__Parameters__  
_dbFilePath_  
&nbsp;&nbsp;&nbsp;&nbsp;[SQLite][SQLitews] database source can be specified as: `path`, `file`, `":memory:"`, `""` or `nil`.  
_encoding_  
&nbsp;&nbsp;&nbsp;&nbsp;The database encoding, which will be used to define which method from <a href="http://www.sqlite.org/capi3ref.html">SQLite C API</a> to use. The default value is [DBCDatabaseEncodingUTF8][DBCDatabaseEncodingUTF8c].  
  
__Return value__  
Initialized __DBCDatabase__ instance  
  
__Discussion__  
This method initializes __DBCDatabase__ instance and prepares it to work with provided encoding. There are few methods in <a href="http://www.sqlite.org/capi3ref.html">SQLite C API</a> which can be used specially for UTF-8/UTF-16 encodings. But I hope you will keep close to the light side of the force and use UTF-8 encoding.  
If you planing to use database in 'read-write' mode, you should place [sqlite][SQLitews] database file somewhere, where system can change file. Don't forget, what in iOS and Mac OS X (apps from [Mac App Store][MAS]) applications you can't modify database file inside application bundle.  
  
_dbFilePath_ tells to __DBCDatabase__ where it should open/create database:  
&nbsp;&nbsp;&nbsp;&nbsp;1. if _dbFilePath_ is absolute path to database file, then __DBCDatabase__ will use that persistent [sqlite][SQLitews] database file. If file not exists, it will be created.  
&nbsp;&nbsp;&nbsp;&nbsp;2. if _dbFilePath_ is `":memory:"`, then __DBCDatabase__ will create temporary database in memory. Database can be reached only from instance, which created it. When database connection will be closed, database will be removed from memory.  
&nbsp;&nbsp;&nbsp;&nbsp;3. if _dbFilePath_ is `""` or `nil`, then __DBCDatabase__ will create temporary database on device like file. As in-memory database, it can be reached only from instance, which created it and will be removed from filesystem on connection close.  
  
__How to use__  
All you have to do is allocate __DBCDatabase__ and than do the same as shown in <a href="#m2">databaseWithPath:defaultEncoding:</a> class method.  
For example, to create and initialize __DBCDatabase__ instance using UTF-8 encoding for database, which will be temporary stored in memory do something like this:
<pre>
<font color="#547f85">DBCDatabase</font> *db = [[<font color="#547f85">DBCDatabase</font> <font color="#43277c">alloc</font>] <font color="#38595d">initWithPath</font>:<font color="#cb3229">@":memory:"</font> <font color="#38595d">defaultEncoding</font>:<font color="#38595d">DBCDatabaseEncodingUTF8</font>];
</pre>
  
__See Also__  
<a href="#m1">+ databaseWithPath:</a>  
<a href="#m2">+ databaseWithPath:defaultEncoding:</a>  
<a href="#m3">+ databaseFromFile:atPath:continueOnExecutionErrors:error:</a>  
<a href="#m4">+ databaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</a>  
<a href="#m6">- createDatabaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m6"/>databaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</font>  
  
Initialize __DBCDatabase__ instance, which will create/restore/update database from external dump file for you.  
  
<pre>- (id)createDatabaseFromFile:(NSString*)<i>sqlQeryListPath</i> atPath:(NSString*)<i>databasePath</i>  
             defaultEncoding:(DBCDatabaseEncoding)<i>encoding</i> 
   continueOnExecutionErrors:(BOOL)<i>continueOnExecutionErrors</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_sqlStatementsListFilepath_  
&nbsp;&nbsp;&nbsp;&nbsp;The path or file for database dump with SQL statements list.  
_dbFilePath_  
&nbsp;&nbsp;&nbsp;&nbsp;Dump processing result destination can be specified as: `path`, `file`, `":memory:"`, `""` or `nil`.  
_encoding_  
&nbsp;&nbsp;&nbsp;&nbsp;The database encoding, which will be used to define which method from <a href="http://www.sqlite.org/capi3ref.html">SQLite C API</a> to use. The default value is [DBCDatabaseEncodingUTF8][DBCDatabaseEncodingUTF8c].  
_continueOnExecutionErrors_  
&nbsp;&nbsp;&nbsp;&nbsp;Specify `YES` to proceed dump file processing even in case of SQL execution error or `NO` to terminate processing immediately.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorwiki] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
Initialized __DBCDatabase__ instance or `nil` if occurred an error.  
  
__Discussion__  
This method allows you to create/restore/update [sqlite][SQLitews] database from SQL dump file and prepare __DBCDatabase__ to work with it in specified encoding.  
You can use `file`, `:memory:` or `""` as target for database dump processing result. This means what you can create some persistent/temporary [sqlite][SQLitews] database. Also this method can be used to perform database upgrades from file with SQL statements.  
After successful processing, you'll get __DBCDatabase__ instance with ready to use, there is no need to call <a href="#7">openError:</a> (but this is OK to do that).  
  
__How to use__  
All you have to do is allocate __DBCDatabase__ and than do the same as shown in <a href="#m4">databaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</a> class method.  
For example, to to create and initialize __DBCDatabase__ instance with UTF-16 encoding for database, which will be temporary stored on filesystem, we need to do something like this:
<pre>
<font color="#7243a4">NSString</font> *dumpFilePath = ...;
<font color="#547f85">DBCError</font> *error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *db = [[<font color="#547f85">DBCDatabase</font> <font color="#43277c">alloc</font>] <font color="#38595d">createDatabaseFromFile</font>:dumpFilePath <font color="#38595d">atPath</font>:<font color="#cb3229">@""</font>  
                                              <font color="#38595d">defaultEncoding</font>:<font color="#38595d">DBCDatabaseEncodingUTF16</font> 
                                    <font color="#38595d">continueOnExecutionErrors</font>:<font color="#b7359d">NO</font> <font color="#38595d">error</font>:&error];  
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){  
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag  
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);  
}
</pre>
  


__See Also__  
<a href="#m1">+ databaseWithPath:</a>  
<a href="#m2">+ databaseWithPath:defaultEncoding:</a>  
<a href="#m3">+ databaseFromFile:atPath:continueOnExecutionErrors:error:</a>  
<a href="#m4">+ databaseFromFile:atPath:defaultEncoding:continueOnExecutionErrors:error:</a>  
<a href="#m5">- initWithPath:defaultEncoding:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m7"/>openError:</font>  

Open [sqlite][SQLitews] database connection with _read-write_ access.  
  
<pre>- (BOOL)openError:(DBCError**)<i>error</i></pre>  
__Parameters__  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorwiki] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if connection successfully opened, otherwise `NO`.  
  
__Discussion__  
This method open [sqlite][SQLitews] connection with specified database source and encoding. This is the one of few methods, which try to decide which one of <a href="http://www.sqlite.org/capi3ref.html">SQLite C API</a> to use, basing on provided encoding. If file not exists, it will be automatically created (if it not located in application bundle).  
This method uses [openWithFlags:][DBCDatabase+AdvancedOpen] from [Advanced][DBCDatabase+Advanced] category inside. __DBCDatabase__ instance opened with this method will use _read-write_ access on [attached][DBCDatabase+AiasesAttach] databases too.  
It is possible, what connection can't be opened because of few reasons, so you need to handle error and ensure what connection successfully opened.  
  
__How to use__  
To create and open database connection you don't even need [sqlite][SQLitews] database source, because you can create temporary `in-memory` database for example. Next example will show how to open connection for `in-memory` database:
<pre>
<font color="#547f85">DBCError</font> *error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#cb3229">@":memory:"</font>];
<font color="#b7359d">if</font>([db <font color="#38595d">openError</font>:&error] && error == <font color="#b7359d">nil</font>){
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Connection opened"</font>);  
} <font color="#b7359d">else</font> {
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m8">- openReadonlyError:</a>  
<a href="#m9">- makeMutableAt:error:</a>  
<a href="#m10">- closeError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m8"/>openReadonlyError:</font>  

Open [sqlite][SQLitews] database connection with _read-only_ access.

<pre>- (BOOL)openReadonlyError:(DBCError**)<i>error</i></pre>  
__Parameters__  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorwiki] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if connection successfully opened, otherwise `NO`.  
  
__Discussion__  
This method open [sqlite][SQLitews] connection with specified database source and encoding. This is the one of few methods, which try to decide which one of <a href="http://www.sqlite.org/capi3ref.html">SQLite C API</a> to use, basing on provided encoding. If file not exists, it will be automatically created (if it not located in application bundle).  
This method uses [openWithFlags:][DBCDatabase+AdvancedOpen] from [Advanced][DBCDatabase+Advanced] category inside. __DBCDatabase__ instance opened with this method will use _read-only_ access on [attached][DBCDatabase+AiasesAttach] databases too.  
It is possible, what connection can't be opened because of few reasons, so you need to handle error and ensure what connection successfully opened.  
  
__How to use__  
To create and open database connection you don't even need [sqlite][SQLitews] database source, because you can create temporary `in-memory` database for example. Next example will show how to open connection for `in-memory` database
<pre>
<font color="#547f85">DBCError</font> *error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#cb3229">@":memory:"</font>];
<font color="#b7359d">if</font>(![db <font color="#38595d">openReadonlyError</font>:&error]){
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m7">- openError:</a>  
<a href="#m9">- makeMutableAt:error:</a>  
<a href="#m10">- closeError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m9"/>makeMutableAt:error:</font>  
  
This method was created as some kind of helper to copy database file to new location.  

<pre>- (BOOL)makeMutableAt:(NSString*)<i>mutableDatabaseStoreDestination</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_mutableDatabaseStoreDestination_  
&nbsp;&nbsp;&nbsp;&nbsp;The path or file for current [sqlite][SQLitews] database file copy destination.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorwiki] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if copy was successfully created, otherwise `NO`.  
  
__Discussion__  
Sometimes there is a need to make mutable copy of database file (move it out from application bundle). Currently initiated/opened database file will be moved to new location (if file don't exists already) and automatically reopen database connection with new file. To ensure, what database file won't change by current connection, it will be closed.  
To make mutable copy, you don't even need to open connection. If connection was opened, it will be reopened for new database file.  
This methods can't be called on temporary databases.  

__How to use__  
<pre>
<font color="#7243a4">NSString</font> *targetDatabaseLocation = ...;
<font color="#547f85">DBCError</font> *error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#cb3229">@"test.sqlite"</font>];
<font color="#b7359d">if</font>(![db <font color="#38595d">makeMutableAt</font>:targetDatabaseLocation <font color="#38595d">error</font>:&error]){  
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag  
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);  
}
</pre>

__See Also__  
<a href="#m7">- openError:</a>  
<a href="#m8">- openReadonlyError:</a>  
<a href="#m10">- closeError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m10"/>closeError:</font>  
  
Close current [sqlite][SQLitews] database connection.  
  
<pre>- (BOOL)closeError:(DBCError**)<i>error</i></pre>  
__Parameters__  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorwiki] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if connection was successfully closed, otherwise `NO`.  
  
__Discussion__  
Simply close connection and cleanup some caches (if was enabled).  

__How to use__  
There is nothing special in this method, it just close current connection:  
<pre>
<font color="#547f85">DBCError</font> *error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *db = ...;
<font color="#b7359d">if</font>(![db <font color="#38595d">closeError</font>:&error]){  
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag  
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);  
}
</pre>

__See Also__  
<a href="#m7">- openError:</a>  
<a href="#m8">- openReadonlyError:</a>  
<a href="#m9">- makeMutableAt:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m11"/>executeUpdate:error:</font>  

Execute DDL or DML request to [sqlite][SQLitews] database.  

<pre>- (BOOL)executeUpdate:(NSString*)sqlUpdate error:(DBCError**)error, ... </pre>  
__Parameters__  
_sqlUpdate_  
&nbsp;&nbsp;&nbsp;&nbsp;SQL query command.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorwiki] object that describes the problem. Pass `NULL` if you do not want error information.  
_..._  
&nbsp;&nbsp;&nbsp;&nbsp;List of binding parameters.  
  
__Return value__  
`YES` if update statements was successfully executed, otherwise `NO`.  
  
__Discussion__  
I've tried to design both basic methods for DDL and DML to be as simple as possible to use them in your purposes.  
This method can't be called on database with _read-only_ access.  
Of course it has some rules, to work as it should.  

<a name="m11rules"/><u>Lets start from SQL statement format</u>  
You can't use anything else except SQL query format. Parameter tokens can be: _NSLog format specifiers_, _anonymous_ (`?`), _indexed_ (`?<index>`), _named_ (`:<name>`, `@<name>`, `$<name>`).  
Only with _NSLog format specifiers_ parameter tokens you can use non-Objective-C data types, in other cases Objective-C objects only.  
Main _NSLog format specifiers_ benefits is what you can specify any datatype from format specifier:
<ul>
<li>Opjective-C object</li>  
<li>signed int</li>  
<li>unsigned int</li>
<li>short int</li>
<li>unsigned short int</li>
<li>long int</li>
<li>long long int</li>
<li>unsigned long long</li>
<li>double</li>
<li>c string</li>
</ul> 
But you can't reuse same value few times in statements with this kind of parameter tokens format.  
With other parameter tokens format you can use Objective-C objects only.  
_Anonymous_ (`?`) tokens after processing will be casted to _indexed_ (`?<index>`) tokens and executed on [sqlite][SQLitews] database.  
_Indexed_ (`?<index>`) and _named_ (`:<name>`, `@<name>`, `$<name>`) tokens allow you to reuse parameters from list of bindings more than one time in statement, without need to write it again and again into list of bindings.  
Also one of the features, what you can pass few SQL statements in one request and they all will be executed in transaction (if enabled) or just one by one. In case of enabled transactions it is possible, to enable automatic rollback in case of execution error.  
  
<u>Let's study something about what we can pass as list of bindings in this method</u>  
As written above, with _NSLog format specifiers_ you can pass both Objective-C objects and C data types. To pass them, you just write them into list of bindings parameters in their origin form (will show it in _How to use_ section).  
With other type of parameter tokens you can pass them one by one like Objective-C objects, or you can pass __NSDictionary__ for _named_ or __NSArray__ for _indexed_ tokens.  

__How to use__  
In this series of examples, we will use results from one of the <a href="#basicExample">examples</a>, shown earlier.  
<u>To use _NSLog format specifiers_, we have to do something like this</u>:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">executeUpdate</font>:<font color="#cb3229">@"INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( %s, %@, %f, %d );"</font>
             <font color="#38595d">error</font>:&error, <font color="#cb3229">"City"</font>, <font color="#cb3229">@"Denver"</font>, 40.2338f, (<font color="#b7359d">int</font>)-76.1372f, <font color="#b7359d">nil</font>];
</pre>  
I hope you noticed, what I've to do some type cast to pass correct value. So for `%d` I've to pass integer, if you pass some float value it won't be automatically rounded and execution will fail. So try to use corresponding format specifiers for correct data passed as parameters.  
  
<u>To use _anonymous_ tokens for the same task we will do next</u>:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">executeUpdate</font>:<font color="#cb3229">@"INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?, ?, ?, ? );"</font>
             <font color="#38595d">error</font>:&error, <font color="#cb3229">@"City"</font>, <font color="#cb3229">@"Denver"</font>, [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:40.2338f], 
                           [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:-76.1372f], <font color="#b7359d">nil</font>];
</pre>  
As we can see, we have to pass same count of parameters as declared in statement by _anonymous_ tokens.  
Also you can pass here an array of values. This is also possible with _indexed_ tokens, but ensure what you not messed with indices values. In case of _anonymous_ tokens you have to provide array and place values inside of it in the order, to correspond to target column. Here is example of how to do this:  
<pre>
[db <font color="#38595d">executeUpdate</font>:<font color="#cb3229">@"INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?, ?, ?, ? );"</font>
             <font color="#38595d">error</font>:&error, [<font color="#7243a4">NSArray</font> <font color="#43277c">arrayWithObjects</font>:<font color="#cb3229">@"City"</font>, <font color="#cb3229">@"Denver"</font>, [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:40.2338f], 
                           [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:-76.1372f], <font color="#b7359d">nil</font>], <font color="#b7359d">nil</font>];
</pre>  
  
<u>To use _indexed_ tokens for the same task we will do next</u>:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">executeUpdate</font>:<font color="#cb3229">@"INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?2, ?3, ?3 );"</font>
             <font color="#38595d">error</font>:&error, <font color="#cb3229">@"City"</font>, <font color="#cb3229">@"Denver"</font>, [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:40.2338f], <font color="#b7359d">nil</font>];
</pre>  
Also you can pass here an array of values. This is also possible with _anonymous_ tokens, but ensure what you not messed with indices values. In case of _indexed_ tokens you can use indices inside array and place them as _indexed_ tokens but incremented by 1. Here is example of how to do this:  
<pre>
[db <font color="#38595d">executeUpdate</font>:<font color="#cb3229">@"INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( ?1, ?2, ?3, ?3 );"</font>
             <font color="#38595d">error</font>:&error, [<font color="#7243a4">NSArray</font> <font color="#43277c">arrayWithObjects</font>:<font color="#cb3229">@"City"</font>, <font color="#cb3229">@"Denver"</font>, [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:40.2338f], 
                           <font color="#b7359d">nil</font>], <font color="#b7359d">nil</font>];
</pre>  
Just to show you benefits from using _indexed_ tokens I've place same latitude value as longitude.  
  
<u>To use _named_ tokens for the same task we will do next</u>:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">executeUpdate</font>:<font color="#cb3229">@"INSERT INTO test (pType, pTitle, loc_lat, loc_lon) \
                               VALUES ( :placeType, @placeTitle, $placeLatitude, :placeLatitude );"</font>
             <font color="#38595d">error</font>:&error, 
                   [<font color="#7243a4">NSDictionary</font> <font color="#43277c">dictionaryWithObjectsAndKeys</font>:<font color="#cb3229">@"City"</font>, <font color="#cb3229">@"placeType"</font>, <font color="#cb3229">@"Denver"</font>, <font color="#cb3229">@"placeTitle"</font>, 
                   [<font color="#7243a4">NSNumber</font> <font color="#43277c">numberWithFloat</font>:40.2338f], <font color="#cb3229">@"placeLatitude"</font>, <font color="#b7359d">nil</font>];
</pre>  
Just to show you benefits from using _named_ tokens I've place same latitude value as longitude. Also example above show how you can use _named_ tokens in statement.  


__See Also__  
<a href="#m12">- executeQuery:error:</a>  
<a href="#m13">- executeStatementsFromFile:continueOnExecutionErrors:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m12"/>executeQuery:error:</font>  

Execute DDL or DML request to [sqlite][SQLitews] database.  

<pre>- (DBCDatabaseResult*)executeQuery:(NSString*)sqlQuery error:(DBCError**)error, ... </pre>  
__Parameters__  
_sqlQuery_  
&nbsp;&nbsp;&nbsp;&nbsp;SQL query command.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorwiki] object that describes the problem. Pass `NULL` if you do not want error information.  
_..._  
&nbsp;&nbsp;&nbsp;&nbsp;List of binding parameters.  
  
__Return value__  
[DBCDatabaseResult][DBCDatabaseResultCR]  instance with array of [DBCDatabaseRow][DBCDatabaseRowCR].  
  
__Discussion__  
This method designed in same way as <a href="#m11">executeUpdate:error:</a> to make it easy to use. Check <a href="#m11rules"/>executeUpdate:error:</a> rules and acceptable datatypes.  
This method can't be called on database with _read-only_ access.  

__How to use__  
In this example, we will use results from one of the <a href="#basicExample">examples</a>, shown earlier.  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabaseResult</font> *result = [db <font color="#38595d">executeQuery</font>:<font color="#cb3229">@"SELECT * FROM test WHERE loc_lat > %d AND loc_lat < %d"</font>
                                        <font color="#38595d">error</font>:&error, 37, 41, <font color="#b7359d">nil</font>];
<font color="#b7359d">if</font>(error == <font color="#b7359d">nil</font>){
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"%@"</font>, [[result <font color="#38595d">columnNames</font>] <font color="#43277c">componentsJoinedByString</font>:<font color="#cb3229">@" | "</font>]);
    <font color="#b7359d">for</font>(<font color="#547f85">DBCDatabaseRow</font> *row in result) <font color="#43277c">NSLog</font>(<font color="#cb3229">@"%@"</font>, row);
}

<font color="#008123">/* Output:
    pid | ptype | ptitle | loc_lat | loc_lon
    1 | City | Cupertino | 37.3261 | -122.032
    2 | City | New York | 40.724 | -74.006    
*/</font>

<font color="#b7359d">if</font>(error == <font color="#b7359d">nil</font>){
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"%@"</font>, result);
}

<font color="#008123">/* Output:
    Result for: SELECT * FROM test WHERE loc_lat > ?1 AND loc_lat < ?2;
    Query execution done in 0.000000s
    Found: 2 records
    Column names: pid | ptype | ptitle | loc_lat | loc_lon
    Result rows: (
        "1 | City | Cupertino | 37.3261 | -122.032",
        "2 | City | New York | 40.724 | -74.006"
    )
*/</font>
</pre>


__See Also__  
<a href="#m11">- executeUpdate:error:</a>  
<a href="#m13">- executeStatementsFromFile:continueOnExecutionErrors:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m13"/>executeStatementsFromFile:continueOnExecutionErrors:error:</font>  

Execute DDL or DML request from file to [sqlite][SQLitews] database.  

<pre>- (BOOL)executeStatementsFromFile:(NSString*)<i>statementsFilePath</i> 
        continueOnExecutionErrors:(BOOL)<i>continueOnExecutionErrors</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_statementsFilePath_  
&nbsp;&nbsp;&nbsp;&nbsp;The path to SQL statements list.  
_continueOnExecutionErrors_  
&nbsp;&nbsp;&nbsp;&nbsp;Specify `YES` to proceed file processing even in case of SQL execution error or `NO` to terminate processing immediately.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorwiki] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if statements list from file was successfully executed, otherwise `NO`.  
  
__Discussion__  
This method allows you to execute list of statements directly from file stored somewhere in application bundle or elsewhere.  
This method can't be called on database with _read-only_ access.  

__How to use__  
In this example we will reproduce same result as shown in this <a href="#basicExample">example</a> by executing SQL statements from external file.
<pre>
<font color="#547f85">DBCError</font> *error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#cb3229">@":memory:"</font>];
<font color="#b7359d">if</font>([db <font color="#38595d">openError</font>:&error]){
    [db <font color="#38595d">executeStatementsFromFile</font>:[[<font color="#7243a4">NSBundle</font> <font color="#43277c">mainBundle</font>] <font color="#43277c">pathForResource</font>:<font color="#cb3229">@"test.sql"</font> <font color="#43277c">ofType</font>:<font color="#cb3229">@"dump"</font>]
        <font color="#38595d">continueOnExecutionErrors</font>:<font color="#b7359d">NO</font> <font color="#38595d">error</font>:&error];
    <font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
        <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
           for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
        <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
    } <font color="#b7359d">else</font> {
        <font color="#547f85">DBCDatabaseResult</font> *result = [db <font color="#38595d">executeQuery</font>:<font color="#cb3229">@"SELECT * FROM test"</font> error</font>:&error, <font color="#b7359d">nil</font>];

        <font color="#b7359d">if</font>(error == <font color="#b7359d">nil</font>){
            <font color="#43277c">NSLog</font>(<font color="#cb3229">@"%@"</font>, result);
        }

<font color="#008123">/* Output:
    Result for: SELECT * FROM test;
    Query execution done in 0.000000s
    Found: 4 records
    Column names: pid | ptype | ptitle | loc_lat | loc_lon
    Result rows: (
        "1 | City | Cupertino | 37.3261 | -122.032",
        "2 | City | New York | 40.724 | -74.06",
        "3 | City | Dnepropetrovsk | 48.47 | 35.05",
        "4 | City | Kiev | 50.457 | 30.525"
    )
*/</font>
    }
} <font color="#b7359d">else</font> {
    <font color="#008123">// In some rare cases an error may occur, just log it out to find out what gone wrong. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>  
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>


__See Also__  
<a href="#m11">- executeUpdate:error:</a>  
<a href="#m12">- executeQuery:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m14"/>beginTransactionError:</font>  

Begin transaction with <a href="#p2">default lock</a> mode.  

<pre>- (BOOL)beginTransactionError:(DBCError**)<i>error</i></pre>  
  
__Return value__  
`YES` if transaction started with <a href="#p2">default lock</a> mode, otherwise `NO`.  
  
__Discussion__  
This method allows you to begin transaction with <a href="#p2">default lock</a> mode. If database accessed from few threads for example, than the locking mode defines how to balance peer access with ensured success of the transaction.  
This method can't be called on database with _read-only_ access.  
Transactions usually used when you need to execute large number of inserts or other data manipulation at once.  
Be careful because when you manually begin transaction, database leaves auto-commit mode and won't write anything will you commit transaction by yourself. 

__How to use__  
In this example, we will use results from one of the <a href="#basicExample">examples</a>, shown earlier.  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">beginTransactionError</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
} <font color="#b7359d">else</font> {
    [db <font color="#38595d">executeUpdate</font>:<font color="#cb3229">@"INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( %s, %@, %f, %d );"</font>
                <font color="#38595d">error</font>:&error, <font color="#cb3229">"City"</font>, <font color="#cb3229">@"Denver"</font>, 40.2338f, (<font color="#b7359d">int</font>)-76.1372f, <font color="#b7359d">nil</font>];
    [db <font color="#38595d">executeUpdate</font>:<font color="#cb3229">@"INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( %s, %@, %f, %d );"</font>
                <font color="#38595d">error</font>:&error, <font color="#cb3229">"City"</font>, <font color="#cb3229">@"San Jose"</font>, 37.3397f, (<font color="#b7359d">int</font>)-121.8949f, <font color="#b7359d">nil</font>];
}
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">commitTransactionError</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m15">- beginDeferredTransactionError:</a>  
<a href="#m16">- beginImmediateTransactionError:</a>  
<a href="#m17">- beginExclusiveTransactionError:</a>  
<a href="#m18">- commitTransactionError:</a>  
<a href="#m19">- rollbackTransactionError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m15"/>beginDeferredTransactionError:</font>  

Begin transaction with <a href="#p2">deferred lock</a> mode.  

<pre>- (BOOL)beginDeferredTransactionError:(DBCError**)<i>error</i></pre>  
  
__Return value__  
`YES` if transaction started with <a href="#p2">deferred lock</a> mode, otherwise `NO`.  
  
__Discussion__  
This method allows you to begin transaction with <a href="#p2">deferred lock</a> mode. If database accessed from few threads for example, than the locking mode defines how to balance peer access with ensured success of the transaction.  
This method can't be called on database with _read-only_ access.  
Transactions usually used when you need to execute large number of inserts or other data manipulation at once.  
Be careful because when you manually begin transaction, database leaves auto-commit mode and won't write anything will you commit transaction by yourself. 

__How to use__  
This method can be used in same way like <a href="#m14">beginTransactionError:</a> and difference will be only in transaction <a href="#p2">lock</a> mode.  
  
__See Also__  
<a href="#m14">- beginTransactionError:</a>  
<a href="#m16">- beginImmediateTransactionError:</a>  
<a href="#m17">- beginExclusiveTransactionError:</a>  
<a href="#m18">- commitTransactionError:</a>  
<a href="#m19">- rollbackTransactionError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m16"/>beginImmediateTransactionError:</font>  

Begin transaction with <a href="#p2">immediate lock</a> mode.  

<pre>- (BOOL)beginImmediateTransactionError:(DBCError**)<i>error</i></pre>  
  
__Return value__  
`YES` if transaction started with <a href="#p2">immediate lock</a> mode, otherwise `NO`.  
  
__Discussion__  
This method allows you to begin transaction with <a href="#p2">immediate lock</a> mode. If database accessed from few threads for example, than the locking mode defines how to balance peer access with ensured success of the transaction.  
This method can't be called on database with _read-only_ access.  
Transactions usually used when you need to execute large number of inserts or other data manipulation at once.  
Be careful because when you manually begin transaction, database leaves auto-commit mode and won't write anything will you commit transaction by yourself. 

__How to use__  
This method can be used in same way like <a href="#m14">beginTransactionError:</a> and difference will be only in transaction <a href="#p2">lock</a> mode.  
  
__See Also__  
<a href="#m14">- beginTransactionError:</a>  
<a href="#m15">- beginDeferredTransactionError:</a>   
<a href="#m17">- beginExclusiveTransactionError:</a>  
<a href="#m18">- commitTransactionError:</a>  
<a href="#m19">- rollbackTransactionError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m17"/>beginExclusiveTransactionError:</font>  

Begin transaction with <a href="#p2">exclusive lock</a> mode.  

<pre>- (BOOL)beginExclusiveTransactionError:(DBCError**)<i>error</i></pre>  
  
__Return value__  
`YES` if transaction started with <a href="#p2">exclusive lock</a> mode, otherwise `NO`.  
  
__Discussion__  
This method allows you to begin transaction with <a href="#p2">exclusive lock</a> mode. If database accessed from few threads for example, than the locking mode defines how to balance peer access with ensured success of the transaction.  
This method can't be called on database with _read-only_ access.  
Transactions usually used when you need to execute large number of inserts or other data manipulation at once.  
Be careful because when you manually begin transaction, database leaves auto-commit mode and won't write anything will you commit transaction by yourself. 

__How to use__  
This method can be used in same way like <a href="#m14">beginTransactionError:</a> and difference will be only in transaction <a href="#p2">lock</a> mode.  
  
__See Also__  
<a href="#m14">- beginTransactionError:</a>  
<a href="#m15">- beginDeferredTransactionError:</a>  
<a href="#m16">- beginImmediateTransactionError:</a>  
<a href="#m18">- commitTransactionError:</a>  
<a href="#m19">- rollbackTransactionError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m18"/>commitTransactionError:</font>  

Commit recently started transaction.  

<pre>- (BOOL)commitTransactionError:(DBCError**)<i>error</i></pre>  
  
__Return value__  
`YES` if transaction commit was successful, otherwise `NO`.  
  
__Discussion__  
This method allows you to commit recently performed data manipulation SQL statements and write them down into [sqlite][SQLitews] database file.  
This method can't be called on database with _read-only_ access.  

__How to use__  
Usage of this method was shown in '__How to use__' for <a href="#m14">beginTransactionError:</a>.  
  
__See Also__  
<a href="#m14">- beginTransactionError:</a>  
<a href="#m15">- beginDeferredTransactionError:</a>  
<a href="#m16">- beginImmediateTransactionError:</a>  
<a href="#m17">- beginExclusiveTransactionError:</a>  
<a href="#m19">- rollbackTransactionError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m19"/>rollbackTransactionError:</font>  

Rollback recent data manipulation SQL statements to the state, before transaction was started.  

<pre>- (BOOL)rollbackTransactionError:(DBCError**)<i>error</i></pre>  
  
__Return value__  
`YES` if transaction rollback was successful, otherwise `NO`.  
  
__Discussion__  
This method allows you to restore database state to the state before all data manipulation was made in transaction.  
This method can't be called on database with _read-only_ access.  

__How to use__  
Usage of this method was shown in '__How to use__' for <a href="#m14">beginTransactionError:</a>.  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">beginTransactionError</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
} <font color="#b7359d">else</font> {
    error = <font color="#b7359d">nil</font>;
    [db <font color="#38595d">executeUpdate</font>:<font color="#cb3229">@"INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( %s, %@, %f, %d );"</font>
                <font color="#38595d">error</font>:&error, <font color="#cb3229">"City"</font>, <font color="#cb3229">@"Denver"</font>, 40.2338f, (<font color="#b7359d">int</font>)-76.1372f, <font color="#b7359d">nil</font>];
    [db <font color="#38595d">executeUpdate</font>:<font color="#cb3229">@"INSERT INTO test (pType, pTitle, loc_lat, loc_lon) VALUES ( %s, %@, %f, %d );"</font>
                <font color="#38595d">error</font>:&error, <font color="#cb3229">"City"</font>, <font color="#cb3229">@"San Jose"</font>, 37.3397f, (<font color="#b7359d">int</font>)-121.8949f, <font color="#b7359d">nil</font>];
    <font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>) {
        <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
           for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
        <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
        error = <font color="#b7359d">nil</font>;
        [db <font color="#38595d">rollbackTransactionError:</font>&error];
        <font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>) {
            <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
               for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
            <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
        }
    }
}
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">commitTransactionError</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>
  
__See Also__  
<a href="#m14">- beginTransactionError:</a>  
<a href="#m15">- beginDeferredTransactionError:</a>  
<a href="#m16">- beginImmediateTransactionError:</a>  
<a href="#m17">- beginExclusiveTransactionError:</a>  
<a href="#m18">- commitTransactionError:</a>  
  
<a href="#top">Top</a>  
