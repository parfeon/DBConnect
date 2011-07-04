#__DBCDatabaseInfo Class Reference__  
[SQLitews]:http://www.sqlite.org  
[APPLFastEnumerationProtocol]:http://developer.apple.com/library/ios/#documentation/cocoa/reference/NSFastEnumeration_protocol/Reference/NSFastEnumeration.html
[DBCDatabaseResultCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseResult  
[DBCDatabaseCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase  
[DBCDatabaseBasicExample]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#basicExample  
[DBCDatabaseDatabaseList]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#m15  
<a name="top"/><font size="6">__Overview__</font>  
This class holds information about currently opened databases returned as result of [databasesListError:][DBCDatabaseDatabaseList].  
This class holds information about:
<ul>
<li>database names</li>
<li>sequence number among other databases</li>
<li>path to database source</li>
</ul>
  
##__Tasks__  
###__DBCDatabaseInfo initialization__  
<a href="#m1">+ databaseInfoWithSequence:name:filePath:</a>  
<a href="#m2">- initDatabaseInfoWithSequence:name:filePath:</a>  
###__DBCDatabaseRow properties__  
<a href="#p1">numberInSequence</a>  
<a href="#p2">name</a>  
<a href="#p3">filePath</a>  

##__Properties__  

<font size="4"><a name="p1"/>numberInSequence</font>  
  
This property stores information about database sequence number.  
  
<pre>@property (nonatomic, readonly, getter = numberInSequence)int dbSeqNumber</pre>   
  
__Return value__  
Database sequence number.  
  
__Discussion__  
This number can be used to determine which database was attached one after another and in which order.  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="p2"/>name</font>  
  
This property stores information about database name.  
  
<pre>@property (nonatomic, readonly, getter = name)NSString *dbName</pre>   
  
__Return value__  
Database name.  
  
__Discussion__  
This is the name which was used during database attachment or _main_.  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="p3"/>filePath</font>  
  
This property stores information about database source.  
  
<pre>@property (nonatomic, readonly, getter = filePath)NSString *dbFilePath</pre>   
  
__Return value__  
Database source path.  
  
__Discussion__  
Database can have different types of sources: `file`, `""`, `:memory:`. Last two won't have any value in this property.  
  
<a href="#top">Top</a>  
 
##__Class methods__  

<font size="4"><a name="m1"/>databaseInfoWithSequence:name:filePath:</font>  
  
Create and initialize __DBCDatabaseInfo__ instance with sequence number, name and source path.  
  
<pre>+ (id)databaseInfoWithSequence:(int)<i>sequenceNumber</i> name:(NSString*)<i>databaseName</i> 
                      filePath:(NSString*)<i>pathToDatabaseFile</i></pre>  
__Parameters__  
_sequenceNumber_  
&nbsp;&nbsp;&nbsp;&nbsp;[SQLite][SQLitews] database sequence number among other databases.  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;Database name.  
_pathToDatabaseFile_  
&nbsp;&nbsp;&nbsp;&nbsp;The path or file of database source.  
  
__Return value__  
Autoreleased __DBCDatabaseInfo__ instance.  
  
__Discussion__  
This method creates and initialize __DBCDatabaseInfo__ instance which stored information about single database attached/created at current database connection.  
  
__See Also__  
<a href="#m2">- initDatabaseInfoWithSequence:name:filePath:</a>  
  
<a href="#top">Top</a>  
  
##__Instance methods__  

<font size="4"><a name="m2"/>initDatabaseInfoWithSequence:name:filePath:</font>  
  
Initialize __DBCDatabaseInfo__ instance with sequence number, name and source path.  
  
<pre>- (id)initDatabaseInfoWithSequence:(int)<i>sequenceNumber</i> name:(NSString*)<i>databaseName</i> 
                          filePath:(NSString*)<i>pathToDatabaseFile</i></pre>  
__Parameters__  
_sequenceNumber_  
&nbsp;&nbsp;&nbsp;&nbsp;[SQLite][SQLitews] database sequence number among other databases.  
_databaseName_  
&nbsp;&nbsp;&nbsp;&nbsp;Database name.  
_pathToDatabaseFile_  
&nbsp;&nbsp;&nbsp;&nbsp;The path or file of database source.  
  
__Return value__  
Initialized __DBCDatabaseInfo__ instance.  
  
__Discussion__  
This method creates and initialize __DBCDatabaseInfo__ instance which stored information about single database attached/created at current database connection.  
  
__See Also__  
<a href="#m1">+ databaseInfoWithSequence:name:filePath:</a>  
  
<a href="#top">Top</a>  