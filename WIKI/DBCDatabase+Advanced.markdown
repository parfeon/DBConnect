#__DBCDatabase Advanced Category Reference__  
[SQLitews]:http://www.sqlite.org  
[SQLiteModule]:http://www.sqlite.org/c3ref/module.html
[MAS]:http://www.apple.com/mac/app-store/  
[DBCDatabaseCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase  
[DBCDatabaseBasicExample]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#basicExample  
[DBCDatabaseOpenMethod]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#m7  
[DBCErrorCR]:https://github.com/parfeon/DBConnect/wiki/DBCError  
[DBCDatabase+Aiases]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase+Aiases  
[ConstantsJournalingMode]:https://github.com/parfeon/DBConnect/wiki/Constants#DBCDatabaseJournalingMode
[ConstantsJournalingModeDelete]:https://github.com/parfeon/DBConnect/wiki/Constants#DBCDatabaseJournalingModeDelete
[ConstantsLockingMode]:https://github.com/parfeon/DBConnect/wiki/Constants#DBCDatabaseLockingMode
<a name="top"/><font size="6">__Overview__</font>  
Basic purpose of this category, is to keep some advanced database tweaks away form user, who needs only basic features of wrapper. Also this keep autocomplete from showing you methods, which you probably won't use at all.  
There are one more category for [DBCDatabase][DBCDatabaseCR] [Aliases][DBCDatabase+Aiases], this categories was created thematically on their purposes.  
Advanced category adds specific aliases and methods to work with [sqlite][SQLitews] database.  
  
##__Tasks__  
###__DBCDatabase instance initialization__  
<a href="#m1">- openWithFlags:error:</a>  
###__Working with [sqlite][SQLitews] database file pages__  
<a href="#m2">- freeUnusedPagesError:</a>  
<a href="#m3">- freePagesCountInDatabase:error:</a>  
<a href="#m4">- pagesCountInDatabase:error:</a>  
<a href="#m5">- setPageSizeInDatabase:size:error:</a>  
<a href="#m6">- pageSizeInDatabase:error:</a>  
<a href="#m7">- setMaximumPageCountForDatabase:size:error:</a>  
<a href="#m8">- resetMaximumPageCountForDatabase:error:</a>  
<a href="#m9">- maximumPageCountForDatabase:error:</a>  
###__[sqlite][SQLitews] database backup/restore__  
<a href="#m10">- restore:fromFile:database:error:</a>  
<a href="#m11">- restore:from:database:error:</a>  
<a href="#m12">- backup:toFile:database:error:</a>  
<a href="#m13">- backup:to:database:error:</a>  
###__Transaction journaling control__  
<a href="#m14">- turnOffJournalingError:</a>  
<a href="#m15">- turnOffJournalingForDatabase:error:</a>  
<a href="#m16">- turnOnJournalingError:error:</a>  
<a href="#m17">- turnOnJournalingForDatabase:error:</a>  
<a href="#m18">- setJournalMode:error:</a>  
<a href="#m19">- journalModeError:</a>  
<a href="#m20">- setJournalMode:forDatabase:error:</a>  
<a href="#m21">- journalModeForDatabase:error:</a>  
<a href="#m22">- setJournalSizeLimitForDatabase:size:error:</a>  
<a href="#m23">- journalSizeLimitForDatabase:error:</a>  
###__Database locking__  
<a href="#m24">- setLockingMode:error:</a>  
<a href="#m25">- lockingModeError:</a>  
<a href="#m26">- setLockingMode:forDatabase:error:</a>  
<a href="#m27">- lockingModeForDatabase:error:</a>  
<a href="#m28">- setOmitReadlockLike:error:</a>  
<a href="#m29">- omitReadlockError:</a>  
###__Virtual tables (modules) registration__  
<a href="#m30">- registerModule:moduleName:userData:cleanupFunction:error:</a>  
###__Function register/unregister__  
<a href="#m31">- registerScalarFunction:functionName:parametersCount:textValueRepresentation:userData:error:</a>  
<a href="#m32">- unRegisterScalarFunction:parametersCount:textValueRepresentation:error:</a>  
<a href="#m33">- registerAggregationFunction:finalizeFunction:functionName:parametersCount:textValueRepresentation:userData:error:</a>  
<a href="#m34">- unRegisterAggregationFunction:parametersCount:textValueRepresentation:error:</a>  
<a href="#m35">- registerCollationFunction:cleanupFunction:functionName:textValueRepresentation:userData:error:</a>  
<a href="#m36">- unRegisterCollationFunction:textValueRepresentation:error:</a>  

##__Instance methods__  
  
<font size="4"><a name="m1"/>openWithFlags:error:</font>  
  
Open [sqlite][SQLitews] database connection with specific options.  
  
<pre>- (BOOL)openWithFlags:(int)<i>flags</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_flags_  
&nbsp;&nbsp;&nbsp;&nbsp;A series of bit-flags that can be used to control how the database file is open.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database connection was successfully opened, otherwise `NO`.  
  
__Discussion__  
The flags parameter controls the state of the opened file. This parameters in most cases consist from few bit-flags:
<ul>
<li><i>SQLITE_OPEN_READONLY</i> - open database file for <i>read-only</i> access.</li>
<li><i>SQLITE_OPEN_READWRITE</i> - open database file for <i>read-write</i> access. The file must already exist.</li>
<li><i>SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE</i> - default bit-flags to open database file for <i>read-write</i> access and file creation if it don't exist.</li>
</ul>
Also few more bit-flags can be added to flags above:
<ul>
<li><i>SQLITE_OPEN_NOMUTEX</i> - open database connection with multithreaded support (if library was compiled with thread support, but we knew what this is not our case). This flag cannot be used in conjunction with the <i>SQLITE_OPEN_FULLMUTEX</i> flag.</li>
<li><i>SQLITE_OPEN_FULLMUTEX</i> - open database connection in _serialized_ mode (if library was compiled with thread support, but we knew what this is not our case). This flag cannot be used in conjunction with the <i>SQLITE_OPEN_NO MUTEX</i> flag.</li>
<li><i>SQLITE_OPEN_SHAREDCACHE</i> - enables shared cache for this database connection. This flag cannot be used in conjunction with the <i>SQLITE_OPEN_PRIVATECACHE</i> flag.</li>
<li><i>SQLITE_OPEN_PRIVATECACHE</i> - disables shared cache for this database connection. This flag cannot be used in conjunction with the <i>SQLITE_OPEN_SHAREDCACHE</i> flag.</li>
</ul>
  
__How to use__  
In this example I'll show you how implemented [openError:][DBCDatabaseOpenMethod] method from inside (of course you can see it in source codes)
<pre>
<font color="#547f85">DBCError</font> *error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *db = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#cb3229">@":memory:"</font>];
<font color="#b7359d">BOOL</font> isOpened = [db <font color="#38595d">openWithFlags</font>:<font color="#754931">SQLITE_OPEN_READWRITE</font>|<font color="#754931">SQLITE_OPEN_CREATE</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
[- openError:][DBCDatabaseOpenMethod]  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m2"/>freeUnusedPagesError:</font>  

This method allows you to remove _garbage_ data from [sqlite][SQLitews] database file and reduce it in size.  
  
<pre>- (BOOL)freeUnusedPagesError:(DBCError**)<i>error</i></pre>  
__Parameters__  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database was successfully vacuumed, otherwise `NO`.  
  
__Discussion__  
After removing large amount of data from table, maybe even drop whole table, there are _garbage_ left in [sqlite][SQLitews] database file, so we need to cleanup it time after time. This macro help to remove _garbage_ data from [sqlite][SQLitews] database file and defragment database structures and repack individual database pages.  
This method can be performed only on _main_ database (which was used to create connection) also it don't have any effect on `in-memory` database.  
Under the hood this method will recreate database from the scratch with database settings, default for current database connection. For example if your database file uses some non-standard settings (for example page_size), make sure to set them with appropriate methods before free unused pages. Also this methods will rebuild indices and all this operations require some time, so don't overuse this feature.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
I'll show you how to clean up free pages after dropped whole table with data in it if count of free pages more than 70% of total pages count.    
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">dropTable</font>:<font color="#cb3229">@"test"</font> <font color="#38595d">inDatabase</font>:<font color="#b7359d">nil</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error == <font color="#b7359d">nil</font>){
    <font color="#b7359d">int</font> freePagesCount = [db <font color="#38595d">freePagesCountInDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
    <font color="#b7359d">int</font> totalPagesCount = [db <font color="#38595d">pagesCountInDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
    <font color="#b7359d">if</font>(freePagesCount >= (totalPagesCount-freePagesCount)*0.7){
        [db <font color="#38595d">freeUnusedPagesError</font>:&error];
        <font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
            <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
               for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
            <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
        }
    }
} <font color="#b7359d">else</font> {
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m3">- freePagesCountInDatabase:error:</a>  
<a href="#m4">- pagesCountInDatabase:error:</a>  
<a href="#m5">- setPageSizeInDatabase:size:error:</a>  
<a href="#m6">- pageSizeInDatabase:error:</a>  
<a href="#m7">- setMaximumPageCountForDatabase:size:error:</a>  
<a href="#m8">- resetMaximumPageCountForDatabase:error:</a>  
<a href="#m9">- maximumPageCountForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m3"/>freePagesCountInDatabase:error:</font>  
  
This method allows you to retrieve how many pages in specified database are currently marked as free and available.  
  
<pre>- (int)freePagesCountInDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database for which you wan to retrieve how much free pages there. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
How many pages in specified database are currently marked as free and available.  
  
__Discussion__  
This method can be used to determine when you need to call <a href="#m2">freeUnusedPagesError:</a> to free up pages.  

__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
I'll show you how to retrieve number of free pages.  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">dropTable</font>:<font color="#cb3229">@"test"</font> <font color="#38595d">inDatabase</font>:<font color="#b7359d">nil</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error == <font color="#b7359d">nil</font>){
    <font color="#b7359d">int</font> freePagesCount = [db <font color="#38595d">freePagesCountInDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
    <font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
        <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
           for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
        <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
    }
} <font color="#b7359d">else</font> {
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m2">- freeUnusedPagesError:</a>  
<a href="#m4">- pagesCountInDatabase:error:</a>  
<a href="#m5">- setPageSizeInDatabase:size:error:</a>  
<a href="#m6">- pageSizeInDatabase:error:</a>  
<a href="#m7">- setMaximumPageCountForDatabase:size:error:</a>  
<a href="#m8">- resetMaximumPageCountForDatabase:error:</a>  
<a href="#m9">- maximumPageCountForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m4"/>pagesCountInDatabase:error:</font>  
  
This method allows you to retrieve how much pages used by specified database.  
  
<pre>- (int)pagesCountInDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database for which you wan to retrieve how pages it uses. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
How many pages used by database (including marked as _free_).    
  
__Discussion__  
This method can be used to determine when you need to call <a href="#m2">freeUnusedPagesError:</a> to free up pages. Product for return values of <a href="#m4">pagesCountInDatabase:error:</a> and <a href="#m5">pageSizeInDatabase:error:</a> will give you how many space is used by database.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#b7359d">int</font> totalPagesCount = [db <font color="#38595d">pagesCountInDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
      for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m2">- freeUnusedPagesError:</a>  
<a href="#m3">- freePagesCountInDatabase:error:</a>  
<a href="#m5">- setPageSizeInDatabase:size:error:</a>  
<a href="#m6">- pageSizeInDatabase:error:</a>  
<a href="#m7">- setMaximumPageCountForDatabase:size:error:</a>  
<a href="#m8">- resetMaximumPageCountForDatabase:error:</a>  
<a href="#m9">- maximumPageCountForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m5"/>setPageSizeInDatabase:size:error:</font>  
  
This method allows you to change pages size for specified database.  
  
<pre>- (BOOL)setPageSizeInDatabase:(NSString*)<i>databaseName</i> size:(int)<i>newPageSize</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database for which you wan to change page size. If _nil_ than _main_ database will be used.  
_newPageSize_  
&nbsp;&nbsp;&nbsp;&nbsp;New page size value in bytes. __Size must be a power of two__.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database page size was successfully changed , otherwise `NO`.  
  
__Discussion__  
This method allows you to change database page size and repack database from the scratch with new page size value. The _bytes_ must be a power of two. By default, the allowed sizes are __512__, __1024__, __2048__, __4096__, __8192__, __16384__, and __32768__ bytes.  
Both this and <a href="#m6">pageSizeInDatabase:error:</a> methods heavily used in _backup_ and _restore_ methods.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
I'll show you how to set new page size for specific database.  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">setPageSizeInDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">size</font>:4096 <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m2">- freeUnusedPagesError:</a>  
<a href="#m3">- freePagesCountInDatabase:error:</a>  
<a href="#m4">- pagesCountInDatabase:error:</a>  
<a href="#m6">- pageSizeInDatabase:error:</a>  
<a href="#m7">- setMaximumPageCountForDatabase:size:error:</a>  
<a href="#m8">- resetMaximumPageCountForDatabase:error:</a>  
<a href="#m9">- maximumPageCountForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m6"/>pageSizeInDatabase:error:</font>  
  
This method allows you to retrieve pages size for specified database.  
  
<pre>- (int)pageSizeInDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database for which you wan to retrieve pages size. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
Specified database page size.  
  
__Discussion__  
This method allow you to retrieve page size for specified database. Product for return values of <a href="#m4">pagesCountInDatabase:error:</a> and <a href="#m5">pageSizeInDatabase:error:</a> will give you how many space is used by database.  
Both this and <a href="#m6">setPageSizeInDatabase:size:error:</a> methods heavily used in _backup_ and _restore_ methods.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
Here I'll show you how to retrieve page size for specific database in bytes:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#b7359d">int</font> databasePageSize [db <font color="#38595d">pageSizeInDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m2">- freeUnusedPagesError:</a>  
<a href="#m3">- freePagesCountInDatabase:error:</a>  
<a href="#m4">- pagesCountInDatabase:error:</a>  
<a href="#m5">- setPageSizeInDatabase:size:error:</a>  
<a href="#m7">- setMaximumPageCountForDatabase:size:error:</a>  
<a href="#m8">- resetMaximumPageCountForDatabase:error:</a>  
<a href="#m9">- maximumPageCountForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m7"/>setMaximumPageCountForDatabase:size:error:</font>  
  
This method allows you to set maximum database pages count.  
  
<pre>- (BOOL)setMaximumPageCountForDatabase:(NSString*)<i>databaseName</i> size:(int)<i>newPageCount</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database for which you wan to change maximum pages count. If _nil_ than _main_ database will be used.  
_newPageCount_  
&nbsp;&nbsp;&nbsp;&nbsp;New page count (only 32-bit signed int allowed).  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database maximum pages count was successfully changed , otherwise `NO`.  
  
__Discussion__  
This method allows you to change maximum page size for specified database. If database will try to grow past this maximum, you'll get an out-of-space error.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example we will set custom maximum pages count for database, which is equal to __1073741823__ (maximum value):  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">setMaximumPageCountForDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">size</font>:1073741823 <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m2">- freeUnusedPagesError:</a>  
<a href="#m3">- freePagesCountInDatabase:error:</a>  
<a href="#m4">- pagesCountInDatabase:error:</a>  
<a href="#m5">- setPageSizeInDatabase:size:error:</a>  
<a href="#m6">- pageSizeInDatabase:error:</a>  
<a href="#m8">- resetMaximumPageCountForDatabase:error:</a>  
<a href="#m9">- maximumPageCountForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m8"/>resetMaximumPageCountForDatabase:error:</font>  
  
This method allows you to reset maximum page count to default value.  
  
<pre>- (BOOL)resetMaximumPageCountForDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database for which you wan to reset to default maximum pages count. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.
  
__Return value__  
`YES` if database maximum pages count was successfully reset, otherwise `NO`.  
  
__Discussion__  
This method simply resets for specified database maximum pages count to __1073741823__ pages (this count of pages allow to store one terabyte in database).  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example we will set default maximum pages count value for database, which is equal to __1073741823__:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">resetMaximumPageCountForDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m2">- freeUnusedPagesError:</a>  
<a href="#m3">- freePagesCountInDatabase:error:</a>  
<a href="#m4">- pagesCountInDatabase:error:</a>  
<a href="#m5">- setPageSizeInDatabase:size:error:</a>  
<a href="#m6">- pageSizeInDatabase:error:</a>  
<a href="#m7">- setMaximumPageCountForDatabase:size:error:</a>  
<a href="#m9">- maximumPageCountForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m9"/>maximumPageCountForDatabase:error:</font>  
  
This method allows you to retrieve maximum pages count for specified database.  
  
<pre>- (int)maximumPageCountForDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database for which you wan to retrieve maximum pages count. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
Specified database maximum pages count.  
  
__Discussion__  
This method allow you to retrieve maximum pages count for specified database. 

__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
Here I'll show you how to retrieve maximum pages count for specific database:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#b7359d">int</font> maximumPagesCount [db <font color="#38595d">maximumPageCountForDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m2">- freeUnusedPagesError:</a>  
<a href="#m3">- freePagesCountInDatabase:error:</a>  
<a href="#m4">- pagesCountInDatabase:error:</a>  
<a href="#m5">- setPageSizeInDatabase:size:error:</a>  
<a href="#m6">- pageSizeInDatabase:error:</a>  
<a href="#m7">- setMaximumPageCountForDatabase:size:error:</a>  
<a href="#m8">- resetMaximumPageCountForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m10"/>restore:fromFile:database:error:</font>  
  
This method allows you to restore destination database from current [sqlite][SQLitews] database connection with source database file and specified source database name.  
  
<pre>- (BOOL)restore:(NSString*)<i>dstDatabaseName</i> fromFile:(NSString*)<i>srcDatabaseFile</i> 
       database:(NSString*)<i>srcDatabaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_dstDatabaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;Destination database name in current [sqlite][SQLitews] database connection for restore. If _nil_ than _main_ database will be used.  
_srcDatabaseFile_  
&nbsp;&nbsp;&nbsp;&nbsp;Source database file from which database restore will be performed.  
_srcDatabaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;Source database name, which will be used to restore destination database. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database was successfully restored, otherwise `NO`.  
  
__Discussion__  
If page-size of the source and destination database are different, than before restore, destination database page-size will be changed (if opened with _read-write_ access).  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
We will assume what we used <a href="#m12">backup:toFile:database:error:</a> to backup file from [example][DBCDatabaseBasicExample] to file with name `test_backup.sqlite`
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#7243a4">NSString</font> *docDir = [<font color="#43277c">NSSearchPathForDirectoriesInDomains</font>(<font color="#43277c">NSDocumentDirectory</font>, <font color="#43277c">NSUserDomainMask</font>, <font color="#b7359d">YES</font>) 
                    <font color="#43277c">objectAtIndex</font>:0];
<font color="#7243a4">NSString</font> *backupFilepath = [docDir <font color="#43277c">stringByAppendingPathComponent</font>:<font color="#cb3229">@"test_backup.sqlite"</font>];
<font color="#547f85">DBCDatabase</font> *restoredDB = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#cb3229">@":memory:"</font>];
<font color="#b7359d">if</font>(error == <font color="#b7359d">nil</font>){
    <font color="#b7359d">BOOL</font> restored = [restoredDB <font color="#38595d">restore</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">fromFile</font>:backupFilepath <font color="#38595d">database</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
    <font color="#b7359d">if</font>(restored) <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Woohoo, database was restored from file"</font>);
    <font color="#b7359d">else if</font>(error != <font color="#b7359d">nil</font>){
        <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
           for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
        <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
    }
} <font color="#b7359d">else</font> {
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m11">- restore:from:database:error:</a>  
<a href="#m12">- backup:toFile:database:error:</a>  
<a href="#m13">- backup:to:database:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m11"/>restore:from:database:error:</font>  
  
This method allows you to restore destination database from current connection with source database connection and specified source database name.  
  
<pre>- (BOOL)restore:(NSString*)<i>dstDatabaseName</i> from:(sqlite3*)<i>srcDatabaseConnection</i>
       database:(NSString*)<i>srcDatabaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_dstDatabaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;Destination database name in current [sqlite][SQLitews] database connection for restore. If _nil_ than _main_ database will be used.  
_srcDatabaseConnection_  
&nbsp;&nbsp;&nbsp;&nbsp;Source [sqlite][SQLitews] database connection from which database restore will be performed.  
_srcDatabaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;Source database name, which will be used to restore destination database. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database was successfully restored, otherwise `NO`.  
  
__Discussion__  
If page-size of the source and destination database are different, than before restore, destination database page-size will be changed (if opened with _read-write_ access).  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example we will use our original database connection from this [example][DBCDatabaseBasicExample] as source for restoring new database:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *restoredDB = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#cb3229">@":memory:"</font>];
<font color="#b7359d">if</font>(error == <font color="#b7359d">nil</font>){
    <font color="#b7359d">BOOL</font> restored = [restoredDB <font color="#38595d">restore</font>:<font color="#b7359d">nil</font> <font color="#38595d">from</font>:[db <font color="#38595d">database</font>] <font color="#38595d">database</font>:<font color="#b7359d">nil</font> <font color="#38595d">error</font>:&error];
    <font color="#b7359d">if</font>(restored) <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Woohoo, database was restored from another database connection"</font>);
    <font color="#b7359d">else if</font>(error != <font color="#b7359d">nil</font>){
        <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
           for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
        <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
    }
} <font color="#b7359d">else</font> {
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m10">- restore:fromFile:database:error:</a>  
<a href="#m12">- backup:toFile:database:error:</a>  
<a href="#m13">- backup:to:database:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m12"/>backup:toFile:database:error:</font>  
  
This method allows you to backup source database from current connection to destination database file and specified destination database name.  
  
<pre>- (BOOL)backup:(NSString*)<i>srcDatabaseName</i> toFile:(NSString*)<i>dstDatabaseFile</i>
      database:(NSString*)<i>dstDatabaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_srcDatabaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;Source database name in current [sqlite][SQLitews] database connection for backup. If _nil_ than _main_ database will be used.  
_dstDatabaseFile_  
&nbsp;&nbsp;&nbsp;&nbsp;Destination database file to which database backup will be performed.  
_dstDatabaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;Destination database name, which will be used to backup source database. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database backup successfully completed, otherwise `NO`.  
  
__Discussion__  
If page-size of the source and destination database are different, than before restore, destination database page-size will be changed (if opened with _read-write_ access).  
If another thread or process writes to the source database, while backing up, then SQLite detects this and usually restart backup process. If the backup process is restarted frequently enough it may never run to completion and <a href="#m12">backup:toFile:database:error:</a> function may never return.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
Here I'll show you how to backup active database to file:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#7243a4">NSString</font> *docDir = [<font color="#43277c">NSSearchPathForDirectoriesInDomains</font>(<font color="#43277c">NSDocumentDirectory</font>, <font color="#43277c">NSUserDomainMask</font>, <font color="#b7359d">YES</font>) 
                    <font color="#43277c">objectAtIndex</font>:0];
<font color="#7243a4">NSString</font> *backupFilepath = [docDir <font color="#43277c">stringByAppendingPathComponent</font>:<font color="#cb3229">@"test_backup.sqlite"</font>];
[db <font color="#38595d">backup</font>:<font color="#b7359d">nil</font> <font color="#38595d">toFile</font>:backupFilepath <font color="#38595d">database</font>:<font color="#b7359d">nil</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m10">- restore:fromFile:database:error:</a>  
<a href="#m11">- restore:from:database:error:</a>  
<a href="#m13">- backup:to:database:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m13"/>backup:to:database:error:</font>  
  
This method allows you to backup source database from current connection to destination database connection and specified destination.  
  
<pre>- (BOOL)backup:(NSString*)<i>srcDatabaseName</i> to:(sqlite3*)<i>dstDatabase</i>
      database:(NSString*)<i>dstDatabaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_srcDatabaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;Source database name in current [sqlite][SQLitews] database connection for backup. If _nil_ than _main_ database will be used.  
_dstDatabase_  
&nbsp;&nbsp;&nbsp;&nbsp;Destination [sqlite][SQLitews] database connection to which database backup will be performed.  
_dstDatabaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;Destination database name, which will be used to backup source database. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database backup successfully completed, otherwise `NO`.  
  
__Discussion__  
If page-size of the source and destination database are different, than before restore, destination database page-size will be changed (if opened with _read-write_ access).  
If another thread or process writes to the source database, while backing up, then SQLite detects this and usually restart backup process. If the backup process is restarted frequently enough it may never run to completion and <a href="#m12">backup:to:database:error:</a> function may never return.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example we will backup database from current connection to database on another connection (it's almost the same as in <a href="#m11">restore:from:database:error:</a> except what as source used current connection):
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#547f85">DBCDatabase</font> *dbForBackup = [<font color="#547f85">DBCDatabase</font> <font color="#38595d">databaseWithPath</font>:<font color="#cb3229">@":memory:"</font>];
<font color="#b7359d">if</font>(error == <font color="#b7359d">nil</font>){
    [db <font color="#38595d">backup</font>:<font color="#b7359d">nil</font> <font color="#38595d">to</font>:[dbForBackup <font color="#38595d">database</font>] <font color="#38595d">database</font>:<font color="#b7359d">nil</font> <font color="#38595d">error</font>:&error];
    <font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
        <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
           for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
        <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
    }
} <font color="#b7359d">else</font> {
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m10">- restore:fromFile:database:error:</a>  
<a href="#m11">- restore:from:database:error:</a>  
<a href="#m12">- backup:toFile:database:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m14"/>turnOffJournalingError:</font>  
  
This method allows you to turn off transaction journaling for database connection by default.  
  
<pre>- (BOOL)turnOffJournalingError:(DBCError**)<i>error</i></pre>  
__Parameters__  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if transaction journaling successfully turned off, otherwise `NO`.  
  
__Discussion__  
Journal files used by [SQLite][SQLitews] to roll back transactions or if unrecoverable error was encountered. Basically journal required for all SQL statements which change database structure or values.  
All existing databases won't be modified. To turn off journaling for specific (existing) database use <a href="#m15">turnOffJournalingForDatabase:error:</a> instead.  
By default journaling turned on.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show you how to disable transaction journaling by default for all newly attached databases:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">turnOffJournalingError</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m15">- turnOffJournalingForDatabase:error:</a>  
<a href="#m16">- turnOnJournalingError:error:</a>  
<a href="#m17">- turnOnJournalingForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m15"/>turnOffJournalingForDatabase:error:</font>  
  
This method allows you to turn off transaction journaling for specified database.  
  
<pre>- (BOOL)turnOffJournalingForDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database, for which you want to turn off transactions journaling. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if transaction journaling successfully turned off, otherwise `NO`.  
  
__Discussion__  
Journal files used by [SQLite][SQLitews] to roll back transactions or if unrecoverable error was encountered. Basically journal required for all SQL statements which change database structure or values.  
This will affect only specific database and rest will be untouched. If you wish to turn off journaling by default for all newly attached databases use <a href="#m14">turnOffJournalingError:</a> instead.  
By default journaling turned on.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show you how to disable transaction journaling for specific database:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">turnOffJournalingForDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m14">- turnOffJournalingError:</a>  
<a href="#m16">- turnOnJournalingError:error:</a>  
<a href="#m17">- turnOnJournalingForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m16"/>turnOnJournalingError:</font>  
  
This method allows you to turn on transaction journaling for database connection by default.  
  
<pre>- (BOOL)turnOnJournalingError:(DBCError**)<i>error</i></pre>  
__Parameters__  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if transaction journaling successfully turned on, otherwise `NO`.  

__Discussion__  
Journal files used by [SQLite][SQLitews] to roll back transactions or if unrecoverable error was encountered. Basically journal required for all SQL statements which change database structure or values.  
All existing databases won't be modified. To turn on journaling for specific (existing) database use <a href="#m17">turnOnJournalingForDatabase:error:</a> instead.  
By default journaling turned on.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show you how to enabled transaction journaling by default for all newly attached databases:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">turnOnJournalingError</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m14">- turnOffJournalingError:</a>  
<a href="#m15">- turnOffJournalingForDatabase:error:</a>  
<a href="#m17">- turnOnJournalingForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m17"/>turnOnJournalingForDatabase:error:</font>  
  
This method allows you to turn on transaction journaling for specified database.  
  
<pre>- (BOOL)turnOnJournalingForDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database, for which you want to turn on transactions journaling. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if transaction journaling successfully turned on, otherwise `NO`.  
  
__Discussion__  
Journal files used by [SQLite][SQLitews] to roll back transactions or if unrecoverable error was encountered. Basically journal required for all SQL statements which change database structure or values.  
This will affect only specific database and rest will be untouched. If you wish to turn on journaling by default for all newly attached databases use <a href="#m16">turnOnJournalingError:</a> instead.  
By default journaling turned on.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show you how to enable transaction journaling for specific database:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">turnOnJournalingForDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m14">- turnOffJournalingError:</a>  
<a href="#m15">- turnOffJournalingForDatabase:error:</a>  
<a href="#m16">- turnOnJournalingError:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m18"/>setJournalMode:error:</font>  
  
This method allows you to change transaction journaling mode for database connection by default.  
  
<pre>- (BOOL)setJournalMode:(DBCDatabaseJournalingMode)<i>journalMode</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_journalMode_  
&nbsp;&nbsp;&nbsp;&nbsp;New transaction [journaling mode][ConstantsJournalingMode].  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if transaction journaling mode was successfully changed, otherwise `NO`.  
  
__Discussion__  
Journal files used by [SQLite][SQLitews] to roll back transactions or if unrecoverable error was encountered. Basically journal required for all SQL statements which change database structure or values.  
By default value set to `DBCDatabaseJournalingModeDelete`.  
    
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show you how to set custom transaction journaling mode by default for all newly attached databases:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">setJournalMode</font>:<font color="#38595d">DBCDatabaseJournalingModeOff</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m19">- journalModeError:</a>  
<a href="#m20">- setJournalMode:forDatabase:error:</a>  
<a href="#m21">- journalModeForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m19"/>journalModeError:</font>  
  
This method allows you to retrieve default transaction journaling mode for database connection.  
  
<pre>- (DBCDatabaseJournalingMode)journalModeError:(DBCError**)<i>error</i></pre>  
__Parameters__  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
Default transaction [journaling mode][ConstantsJournalingMode].  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show you how to retrieve default journaling mode:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#38595d">DBCDatabaseJournalingMode</font> journalingMode = [db <font color="#38595d">journalModeError</font>::&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m18">- setJournalMode:error:</a>  
<a href="#m20">- setJournalMode:forDatabase:error:</a>  
<a href="#m21">- journalModeForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m20"/>setJournalMode:forDatabase:error:</font>  
  
This method allows you to change transaction journaling mode for specific database.  
  
<pre>- (BOOL)setJournalMode:(DBCDatabaseJournalingMode)<i>journalMode</i> forDatabase:(NSString*)<i>databaseName</i> 
                 error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_journalMode_  
&nbsp;&nbsp;&nbsp;&nbsp;New transaction [journaling mode][ConstantsJournalingMode].  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database, for which you want to change transactions journaling mode. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if transaction journaling mode was successfully changed, otherwise `NO`.  
  
__Discussion__  
Journal files used by [SQLite][SQLitews] to roll back transactions or if unrecoverable error was encountered. Basically journal required for all SQL statements which change database structure or values.  
By default value set to `DBCDatabaseJournalingModeDelete`.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show you how to set custom transaction journaling mode for specific database:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">setJournalMode</font>:<font color="#38595d">DBCDatabaseJournalingModeTruncate</font> <font color="#38595d">forDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m18">- setJournalMode:error:</a>  
<a href="#m19">- journalModeError:</a>  
<a href="#m21">- journalModeForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m21"/>journalModeForDatabase:error:</font>  
  
This method allows you to retrieve transaction journaling mode for specific database.  
  
<pre>- (DBCDatabaseJournalingMode)journalModeForDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database, for which you want to retrieve transactions journaling mode. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.
  
__Return value__  
Transaction [journaling mode][ConstantsJournalingMode] for specified database.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show you how to retrieve journaling mode for specific database:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#38595d">DBCDatabaseJournalingMode</font> journalingMode = [db <font color="#38595d">journalModeForDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m18">- setJournalMode:error:</a>  
<a href="#m19">- journalModeError:</a>  
<a href="#m20">- setJournalMode:forDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m22"/>setJournalSizeLimitForDatabase:size:error:</font>  
  
This method allows you to set default journal size limit for specified database.  
  
<pre>- (BOOL)setJournalSizeLimitForDatabase:(NSString*)<i>databaseName</i> size:(long long int)<i>newJournalSizeLimit</i> 
                                 error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database, for which you want to change transactions journal size. If _nil_ than _main_ database will be used.  
_newJournalSizeLimit_  
&nbsp;&nbsp;&nbsp;&nbsp;New journal size in bytes.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if transaction journal size was successfully changed, otherwise `NO`.  
  
__Discussion__  
Forces the partial deletion of large journal files that would otherwise be left in place. By default journaling mode set to [DBCDatabaseJournalingModeDelete][ConstantsJournalingModeDelete] and journal will be removed as soon as transaction will be completed. But if journaling mode set to one of persistent modes, than file will be kept and will grown all the time.  
This value applied per database.  
By default value set to `-1`.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example we will change transaction journaling size to 4096 bytes for specific database:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">setJournalSizeLimitForDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">size</font>:4096 <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m23">- journalSizeLimitForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m23"/>journalSizeLimitForDatabase:error:</font>  
  
This method allows you to retrieve default journal size limit for specified database.  
  
<pre>- (long long int)journalSizeLimitForDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database, for which you want to retrieve transactions journal size. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
Transaction journal size for specified database in bytes.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
Here I'll show how to retrieve journal size limit for specific database:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#b7359d">long long int</font> journalSizeLimit = [db <font color="#38595d">journalSizeLimitForDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m23">- journalSizeLimitForDatabase:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m24"/>setLockingMode:error:</font>  
  
This method allows you to set default database file locking mode.  
  
<pre>- (BOOL)setLockingMode:(DBCDatabaseLockingMode)<i>lockingMode</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_lockingMode_  
&nbsp;&nbsp;&nbsp;&nbsp;New [locking mode][ConstantsLockingMode].  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database file locking mode was successfully changed, otherwise `NO`.  
  
__Discussion__  
All existing databases won't be modified. To change locking mode for specific (existing) database use <a href="#m26">setLockingMode:forDatabase:error:</a> instead.  
By default value set to `DBCDatabaseLockingModeNormal`.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
Here I'll show how to change database file [locking mode][ConstantsLockingMode] to `normal` which won't lock file until it should perform some queries on it. This mode will be set by default for all newly attached databases:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">setLockingMode</font>:<font color="#38595d">DBCDatabaseLockingModeNormal</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m25">- lockingModeError:</a>  
<a href="#m26">- setLockingMode:forDatabase:error:</a>  
<a href="#m27">- lockingModeForDatabase:error:</a>  
<a href="#m28">- setOmitReadlockLike:error:</a>  
<a href="#m29">- omitReadlockError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m25"/>lockingModeError:</font>  
  
This method allows you to retrieve default database file locking mode.  
  
<pre>- (DBCDatabaseLockingMode)lockingModeError:(DBCError**)<i>error</i></pre>  
__Parameters__  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.   
  
__Return value__  
Default database file [locking mode][ConstantsLockingMode].  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
Here I'll show you how to retrieve default [locking mode][ConstantsLockingMode]:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#38595d">DBCDatabaseLockingMode</font> lockingMode = [db <font color="#38595d">lockingModeError</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m24">- setLockingMode:error:</a>  
<a href="#m26">- setLockingMode:forDatabase:error:</a>  
<a href="#m27">- lockingModeForDatabase:error:</a>  
<a href="#m28">- setOmitReadlockLike:error:</a>  
<a href="#m29">- omitReadlockError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m26"/>setLockingMode:forDatabase:error:</font>  
  
This method allows you to change specified database locking mode.
  
<pre>- (BOOL)setLockingMode:(DBCDatabaseLockingMode)<i>lockingMode</i> forDatabase:(NSString*)<i>databaseName</i> 
                 error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_lockingMode_  
&nbsp;&nbsp;&nbsp;&nbsp;New [locking mode][ConstantsLockingMode].  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database, for which you want to change locking mode. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database file locking mode was successfully changed, otherwise `NO`.  
  
__Discussion__  
This will affect only specific database and rest will be untouched. If you wish to change locking mode by default for all newly attached databases use <a href="#m24">setLockingMode:error:</a> instead.  
By default value set to `DBCDatabaseLockingModeNormal`.  

__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
Here I'll show how to change database file [locking mode][ConstantsLockingMode] to `normal` which won't lock file until it should perform some queries on it. This mode will be set for specific database:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">setLockingMode</font>:<font color="#38595d">DBCDatabaseLockingModeNormal</font> <font color="#38595d">forDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m24">- setLockingMode:error:</a>  
<a href="#m25">- lockingModeError:</a>  
<a href="#m27">- lockingModeForDatabase:error:</a>  
<a href="#m28">- setOmitReadlockLike:error:</a>  
<a href="#m29">- omitReadlockError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m27"/>lockingModeForDatabase:error:</font>  
  
This method allows you to retrieve locking mode for specified database.  
  
<pre>- (DBCDatabaseLockingMode)lockingModeForDatabase:(NSString*)<i>databaseName</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;The name of database, for which you want to retrieve locking mode. If _nil_ than _main_ database will be used.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
Specified database file [locking mode][ConstantsLockingMode].  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
Here I'll show you how to retrieve [locking mode][ConstantsLockingMode] for specific database:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#38595d">DBCDatabaseLockingMode</font> lockingMode = [db <font color="#38595d">lockingModeForDatabase</font>:<font color="#cb3229">@"main"</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m24">- setLockingMode:error:</a>  
<a href="#m25">- lockingModeError:</a>  
<a href="#m26">- setLockingMode:forDatabase:error:</a>  
<a href="#m28">- setOmitReadlockLike:error:</a>  
<a href="#m29">- omitReadlockError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m28"/>setOmitReadlockLike:error:</font>  
  
This method allows you to enable or disable database read locking for _read-only_ access.  
  
<pre>- (BOOL)setOmitReadlockLike:(BOOL)<i>omit</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;New locking flag state.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database read lock was successfully changed, otherwise `NO`.  
  
__Discussion__  
This method allows to increase performance by disabling database read locks for connections which was opened with _read-only_ access. You should ensure what all processes will access in _read-only_ mode before disabling read locks.  
Specify `YES` if you wish do disable read locks.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
In this example I'll show you how to disable file locking for _read_ operations:  
<pre>
error = <font color="#b7359d">nil</font>;
[db <font color="#38595d">setOmitReadlockLike</font>:<font color="#b7359d">YES</font> <font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m24">- setLockingMode:error:</a>  
<a href="#m25">- lockingModeError:</a>  
<a href="#m26">- setLockingMode:forDatabase:error:</a>  
<a href="#m27">- lockingModeForDatabase:error:</a>  
<a href="#m29">- omitReadlockError:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m29"/>omitReadlockError:</font>  
  
This method allows you to retrieve current state of read lock flag.  
  
<pre>- (BOOL)omitReadlockError:(DBCError**)<i>error</i></pre>  
__Parameters__  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if database read lock is enabled, otherwise `NO`.  
  
__Discussion__  
If YES than this means what read lock is disabled and connection which opened with _read-only_ access will be able to retrieve data from file till other process performing requests on this database.  
  
__How to use__  
In this example, we will use results from one of the [examples][DBCDatabaseBasicExample], shown earlier in [DBCDatabase Class Reference][DBCDatabaseCR].  
Here I'll show you how to retrieve whether read lock was omitted or not:  
<pre>
error = <font color="#b7359d">nil</font>;
<font color="#b7359d">BOOL</font> omitLock = [db <font color="#38595d">omitReadlockError</font>:<font color="#38595d">error</font>:&error];
<font color="#b7359d">if</font>(error != <font color="#b7359d">nil</font>){
    <font color="#008123">// Hmm, something went wrong, try to log out error to find out something useful. Or you can set flag
       for DBCUseDebugLogger in DBCConfiguration.h, than DBConnect will log out all debug information.</font>
    <font color="#43277c">NSLog</font>(<font color="#cb3229">@"Occurred an error: %@"</font>, error);
}
</pre>

__See Also__  
<a href="#m24">- setLockingMode:error:</a>  
<a href="#m25">- lockingModeError:</a>  
<a href="#m26">- setLockingMode:forDatabase:error:</a>  
<a href="#m27">- lockingModeForDatabase:error:</a>  
<a href="#m28">- setOmitReadlockLike:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m30"/>registerModule:moduleName:userData:cleanupFunction:error:</font>  
  
This method allows you to register virtual table (module).  
  
<pre>- (BOOL)registerModule:(const sqlite3_module*)module moduleName:(NSString*)<i>moduleName</i> userData:(void*)<i>userData</i>
       cleanupFunction:(void(*)(void*))<i>cleanupFunction</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_module_  
&nbsp;&nbsp;&nbsp;&nbsp;SQL [virtual table structure][SQLiteModule].  
_moduleName_  
&nbsp;&nbsp;&nbsp;&nbsp;New module name.  
_userData_  
&nbsp;&nbsp;&nbsp;&nbsp;User data passed to module.  
_cleanupFunction_  
&nbsp;&nbsp;&nbsp;&nbsp;Function used to cleanup all retained resources. Pass `NULL` if you don't want use it.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if module was successfully registered, otherwise `NO`.  
  
__Discussion__  
This method allows to register own virtual tables (modules) which you can later use in your SQL statements to perform some additional actions or define specific behavior.  
I'm recommend you to read some tutorials about creation one of internal or external modules.  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m31"/>registerScalarFunction:functionName:parametersCount:textValueRepresentation:userData:error:</font>  
  
This method allows you to register user defined scalar function.  
  
<pre>- (BOOL)registerScalarFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))<i>function</i> 
                  functionName:(NSString*)<i>fnName</i> parametersCount:(int)<i>fnParametersCount</i> 
       textValueRepresentation:(int)<i>expectedTextValueRepresentation</i> userData:(void*)<i>fnUserData</i>
                         error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_function_  
&nbsp;&nbsp;&nbsp;&nbsp;User defined scalar C function pointer.  
_fnName_  
&nbsp;&nbsp;&nbsp;&nbsp;Scalar function name.  
_fnParametersCount_  
&nbsp;&nbsp;&nbsp;&nbsp;Number of parameters what should be provided when calling function from SQL statement. If value is negative then variable parameters count is assumed.  
_expectedTextValueRepresentation_  
&nbsp;&nbsp;&nbsp;&nbsp;Expected representation for text values passed into the function, and can be one of _SQLITE_UTF8_, _SQLITE_UTF16_, _SQLITE_UTF16BE_, _SQLITE_UTF16LE_, or _SQLITE_ANY_.  
_fnUserData_  
&nbsp;&nbsp;&nbsp;&nbsp;The pointer to user data which.
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if scalar function was successfully registered, otherwise `NO`.  
  
__Discussion__  
Scalar function may take multiple parameters, but return only one: integer or string.  
You can use few functions with same name, but they should have different _fnParametersCount_.  
I'm recommend you to read some tutorials about creation one of internal or external modules.  

__See Also__  
<a href="#m32">- unRegisterScalarFunction:parametersCount:textValueRepresentation:error:</a>  
<a href="#m33">- registerAggregationFunction:finalizeFunction:functionName:parametersCount:textValueRepresentation:userData:error:</a>  
<a href="#m34">- unRegisterAggregationFunction:parametersCount:textValueRepresentation:error:</a>  
<a href="#m35">- registerCollationFunction:cleanupFunction:functionName:textValueRepresentation:userData:error:</a>  
<a href="#m36">- unRegisterCollationFunction:textValueRepresentation:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m32"/>unRegisterScalarFunction:parametersCount:textValueRepresentation:error:</font>  
  
This method allows you to unregister user defined scalar function.  
  
<pre>- (BOOL)unRegisterScalarFunction:(NSString*)<i>fnName</i> parametersCount:(int)<i>fnParametersCount</i> 
         textValueRepresentation:(int)<i>expectedTextValueRepresentation</i> error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_fnName_  
&nbsp;&nbsp;&nbsp;&nbsp;Scalar function name, which was used during registration.  
_fnParametersCount_  
&nbsp;&nbsp;&nbsp;&nbsp;Number of parameters what should be provided when calling function from SQL statement. If value is negative then variable parameters count is assumed.  
_expectedTextValueRepresentation_  
&nbsp;&nbsp;&nbsp;&nbsp;Expected representation for text values passed into the function, and can be one of _SQLITE_UTF8_, _SQLITE_UTF16_, _SQLITE_UTF16BE_, _SQLITE_UTF16LE_, or _SQLITE_ANY_.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if scalar function was successfully unregistered, otherwise `NO`.  
  
__Discussion__  
After function was unregistered you can't use it in SQL statements.  

__See Also__  
<a href="#m31">- registerScalarFunction:functionName:parametersCount:textValueRepresentation:userData:error:</a>  
<a href="#m33">- registerAggregationFunction:finalizeFunction:functionName:parametersCount:textValueRepresentation:userData:error:</a>  
<a href="#m34">- unRegisterAggregationFunction:parametersCount:textValueRepresentation:error:</a>  
<a href="#m35">- registerCollationFunction:cleanupFunction:functionName:textValueRepresentation:userData:error:</a>  
<a href="#m36">- unRegisterCollationFunction:textValueRepresentation:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m33"/>registerAggregationFunction:finalizeFunction:functionName:parametersCount:textValueRepresentation:userData:error:</font>  
  
This method allows you to register user defined aggregation function.  
  
<pre>- (BOOL)registerAggregationFunction:(void(*)(sqlite3_context*, int, sqlite3_value**))<i>stepFunction</i> 
                   finalizeFunction:(void(*)(sqlite3_context*))<i>finalizeFunction</i> functionName:(NSString*)<i>fnName</i> 
                    parametersCount:(int)<i>fnParametersCount</i> 
            textValueRepresentation:(int)<i>expectedTextValueRepresentation</i> userData:(void*)<i>fnUserData</i>
                              error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_stepFunction_  
&nbsp;&nbsp;&nbsp;&nbsp;User defined step C function pointer.  
_finalizeFunction_  
&nbsp;&nbsp;&nbsp;&nbsp;User defined finalize C function pointer.  
_fnName_  
&nbsp;&nbsp;&nbsp;&nbsp;Scalar function name.  
_fnParametersCount_  
&nbsp;&nbsp;&nbsp;&nbsp;Number of parameters what should be provided when calling function from SQL statement. If value is negative then variable parameters count is assumed.  
_expectedTextValueRepresentation_  
&nbsp;&nbsp;&nbsp;&nbsp;Expected representation for text values passed into the function, and can be one of _SQLITE_UTF8_, _SQLITE_UTF16_, _SQLITE_UTF16BE_, _SQLITE_UTF16LE_, or _SQLITE_ANY_.  
_fnUserData_  
&nbsp;&nbsp;&nbsp;&nbsp;The pointer to user data which.
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if aggregation function was successfully registered, otherwise `NO`.  
  
__Discussion__  
Aggregate functions are used to collapse values from a grouping of rows into a single result value.  
You can use few functions with same name, but they should have different _fnParametersCount_.  
I'm recommend you to read some tutorials about creation one of internal or external modules.  

__See Also__  
<a href="#m31">- registerScalarFunction:functionName:parametersCount:textValueRepresentation:userData:error:</a>  
<a href="#m32">- unRegisterScalarFunction:parametersCount:textValueRepresentation:error:</a>  
<a href="#m34">- unRegisterAggregationFunction:parametersCount:textValueRepresentation:error:</a>  
<a href="#m35">- registerCollationFunction:cleanupFunction:functionName:textValueRepresentation:userData:error:</a>  
<a href="#m36">- unRegisterCollationFunction:textValueRepresentation:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m34"/>unRegisterAggregationFunction:parametersCount:textValueRepresentation:error:</font>  
  
This method allows you to unregister user defined aggregation function.  
  
<pre>- (BOOL)unRegisterAggregationFunction:(NSString*)<i>fnName</i> parametersCount:(int)<i>fnParametersCount</i> 
              textValueRepresentation:(int)<i>expectedTextValueRepresentation</i>
                                error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_fnName_  
&nbsp;&nbsp;&nbsp;&nbsp;Collation function name, which was used during registration.  
_fnParametersCount_  
&nbsp;&nbsp;&nbsp;&nbsp;Number of parameters what should be provided when calling function from SQL statement. If value is negative then variable parameters count is assumed.  
_expectedTextValueRepresentation_  
&nbsp;&nbsp;&nbsp;&nbsp;Expected representation for text values passed into the function, and can be one of _SQLITE_UTF8_, _SQLITE_UTF16_, _SQLITE_UTF16BE_, _SQLITE_UTF16LE_, or _SQLITE_ANY_.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  
  
__Return value__  
`YES` if aggregation function was successfully registered, otherwise `NO`.  
  
__Discussion__  
After function was unregistered you can't use it in SQL statements.  
You can use few functions with same name, but they should have different _fnParametersCount_.  

__See Also__  
<a href="#m31">- registerScalarFunction:functionName:parametersCount:textValueRepresentation:userData:error:</a>  
<a href="#m32">- unRegisterScalarFunction:parametersCount:textValueRepresentation:error:</a>  
<a href="#m33">- registerAggregationFunction:finalizeFunction:functionName:parametersCount:textValueRepresentation:userData:error:</a>  
<a href="#m35">- registerCollationFunction:cleanupFunction:functionName:textValueRepresentation:userData:error:</a>  
<a href="#m36">- unRegisterCollationFunction:textValueRepresentation:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m35"/>registerCollationFunction:cleanupFunction:functionName:textValueRepresentation:userData:error:</font>  
  
This method allows you to register user defined collation function.  
  
<pre>- (BOOL)registerCollationFunction:(int(*)(void*, int, const void*, int, const void*))<i>function</i> 
                  cleanupFunction:(void(*)(void*))<i>cleanupFunction</i> functionName:(NSString*)<i>fnName</i> 
          textValueRepresentation:(int)<i>expectedTextValueRepresentation</i> userData:(void*)<i>fnUserData</i>
                            error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_function_  
&nbsp;&nbsp;&nbsp;&nbsp;User defined collation C function pointer.  
_cleanupFunction_  
&nbsp;&nbsp;&nbsp;&nbsp;Function used to cleanup all retained resources. Pass NULL if you don't want use it.  
_fnName_  
&nbsp;&nbsp;&nbsp;&nbsp;Scalar function name.  
_fnParametersCount_  
&nbsp;&nbsp;&nbsp;&nbsp;Number of parameters what should be provided when calling function from SQL statement. If value is negative then variable parameters count is assumed.  
_expectedTextValueRepresentation_  
&nbsp;&nbsp;&nbsp;&nbsp;Expected representation for text values passed into the function, and can be one of _SQLITE_UTF8_, _SQLITE_UTF16_, _SQLITE_UTF16BE_, _SQLITE_UTF16LE_, or _SQLITE_ANY_.  
_fnUserData_  
&nbsp;&nbsp;&nbsp;&nbsp;The pointer to user data which.
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  

__Return value__  
`YES` if collation function was successfully registered, otherwise `NO`.    
  
__Discussion__  
Collations are used to sort text values. 
You can use few functions with same name, but they should have different _fnParametersCount_.  
I'm recommend you to read some tutorials about creation one of internal or external modules.  

__See Also__  
<a href="#m31">- registerScalarFunction:functionName:parametersCount:textValueRepresentation:userData:error:</a>  
<a href="#m32">- unRegisterScalarFunction:parametersCount:textValueRepresentation:error:</a>  
<a href="#m33">- registerAggregationFunction:finalizeFunction:functionName:parametersCount:textValueRepresentation:userData:error:</a>  
<a href="#m34">- unRegisterAggregationFunction:parametersCount:textValueRepresentation:error:</a>  
<a href="#m36">- unRegisterCollationFunction:textValueRepresentation:error:</a>  
  
<a href="#top">Top</a>  
  
* * *  
  
<font size="4"><a name="m36"/>unRegisterCollationFunction:textValueRepresentation:error:</font>  
  
This method allows you to unregister user defined collation function.  
  
<pre>- (BOOL)unRegisterCollationFunction:(NSString*)<i>fnName</i> 
            textValueRepresentation:(int)<i>expectedTextValueRepresentation</i>
                              error:(DBCError**)<i>error</i></pre>  
__Parameters__  
_fnName_  
&nbsp;&nbsp;&nbsp;&nbsp;Collation function name, which was used during registration.  
_expectedTextValueRepresentation_  
&nbsp;&nbsp;&nbsp;&nbsp;Expected representation for text values passed into the function, and can be one of _SQLITE_UTF8_, _SQLITE_UTF16_, _SQLITE_UTF16BE_, _SQLITE_UTF16LE_, or _SQLITE_ANY_.  
_error_  
&nbsp;&nbsp;&nbsp;&nbsp;If an error occurs, upon return contains an [DBCError][DBCErrorCR] object that describes the problem. Pass `NULL` if you do not want error information.  

__Return value__  
`YES` if collation function was successfully unregistered, otherwise `NO`.  
  
__Discussion__  
After function was unregistered you can't use it in SQL statements.  

__See Also__  
<a href="#m31">- registerScalarFunction:functionName:parametersCount:textValueRepresentation:userData:error:</a>  
<a href="#m32">- unRegisterScalarFunction:parametersCount:textValueRepresentation:error:</a>  
<a href="#m33">- registerAggregationFunction:finalizeFunction:functionName:parametersCount:textValueRepresentation:userData:error:</a>  
<a href="#m34">- unRegisterAggregationFunction:parametersCount:textValueRepresentation:error:</a>  
<a href="#m35">- registerCollationFunction:cleanupFunction:functionName:textValueRepresentation:userData:error:</a>  
  
<a href="#top">Top</a>  