#__DBCDatabaseTableColumnInfo Class Reference__  
[SQLitews]:http://www.sqlite.org  
[APPLFastEnumerationProtocol]:http://developer.apple.com/library/ios/#documentation/cocoa/reference/NSFastEnumeration_protocol/Reference/NSFastEnumeration.html
[DBCDatabaseResultCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseResult  
[DBCDatabaseCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase  
[DBCDatabaseBasicExample]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#basicExample  
[DBCDatabaseTableInformation1]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase+Aliases#m13  
[DBCDatabaseTableInformation2]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase+Aliases#m14  
<a name="top"/><font size="6">__Overview__</font>  
This class holds information about single column of table which was retrieved as result of [tableInformation:error:][DBCDatabaseTableInformation1] or [tableInformation:forDatabase:error:][DBCDatabaseTableInformation2]  
This class holds information about:
<ul>
<li>column sequence number</li>
<li>column name</li>
<li>column data type</li>
<li>whether column was specified as 'NOT NULL' or not</li>
<li>column default value</li>
<li>whether column was part of the primary key or not</li>
</ul>
  
##__Tasks__  
###__DBCDatabaseTableColumnInfo initialization__  
<a href="#m1">+ columnInfoWithSequence:columnName:columnDataType:isNotNull:defaultValue:isPartOfThePrimaryKey:</a>  
<a href="#m2">- initolumnInfoWithSequence:columnName:columnDataType:isNotNull:defaultValue:isPartOfThePrimaryKey:</a>  
###__DBCDatabaseTableColumnInfo properties__  
<a href="#p1">numberInSequence</a>  
<a href="#p2">name</a>  
<a href="#p3">type</a>  
<a href="#p4">isNotNull</a>  
<a href="#p5">defaultValue</a>  
<a href="#p6">isPartOfThePrimaryKey</a>  

##__Properties__  

<font size="4"><a name="p1"/>numberInSequence</font>  
  
This property stores information about column sequence number by order.  
  
<pre>@property (nonatomic, readonly, getter = numberInSequence)int colIdx</pre>   
  
__Return value__  
Column sequence number by order.  
  
__Discussion__  
This number can be used to determine column position in row of other columns.  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="p2"/>name</font>  
  
This property stores information about column name.  
  
<pre>@property (nonatomic, readonly, getter = name)NSString *colName</pre>   
  
__Return value__  
Column name.  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="p3"/>type</font>  
  
This property stores information about column defined data type.  
  
<pre>@property (nonatomic, readonly, getter = type)NSString *colType</pre>   
  
__Return value__  
Column defined data type.  
  
__Discussion__  
This property stores data type, which was set when table was created or altered.  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="p4"/>isNotNull</font>  
  
This property stores information about whether column should have `NOT NULL` value or not.  
  
<pre>@property (nonatomic, readonly, getter = isNotNull)BOOL colNotNull</pre>   
  
__Return value__  
`YES` if column have `NOT NULL` and should contain value, otherwise `NO`.  
  
__Discussion__  
If `YES` than your requests should specify value for this column or at least specify `DEFAULT`.  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="p5"/>defaultValue</font>  
  
This property stores information about column default value.  
  
<pre>@property (nonatomic, readonly, getter = defaultValue)NSString *colDefValue</pre>   
  
__Return value__  
Default value.  
  
__Discussion__  
Default value will be assigned to column in case if user not provided data for column.  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="p6"/>isPartOfThePrimaryKey</font>  
  
This property stores information about whether column is part of the primary key or not.  
  
<pre>@property (nonatomic, readonly, getter = isPartOfThePrimaryKey)BOOL colIsPartOfPK</pre>   
  
__Return value__  
`YES` if column belongs to the primary key, otherwise `NO`  
  
<a href="#top">Top</a>  

##__Class methods__  

<font size="4"><a name="m1"/>columnInfoWithSequence:columnName:columnDataType:isNotNull:defaultValue:isPartOfThePrimaryKey:</font>  
  
Create and initialize __DBCDatabaseTableColumnInfo__ instance with sequence number, name and source path.  
  
<pre>+ (id)columnInfoWithSequence:(int)<i>columnNumber</i> columnName:(NSString*)<i>columnName</i> 
              columnDataType:(NSString*)<i>columnDataType</i> isNotNull:(BOOL)<i>isNotNull</i> 
                defaultValue:(NSString*)<i>defaultVallue</i> isPartOfThePrimaryKey:(BOOL)<i>isPartOfThePrimaryKey</i></pre>  
__Parameters__  
_columnNumber_  
&nbsp;&nbsp;&nbsp;&nbsp;Column sequence number by order.  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;Column name.  
_columnDataType_  
&nbsp;&nbsp;&nbsp;&nbsp;Column data type.  
_isNotNull_  
&nbsp;&nbsp;&nbsp;&nbsp;If `YES` than column should be `NOT NULL`, otherwise `NO`.  
_defaultVallue_  
&nbsp;&nbsp;&nbsp;&nbsp;Default column value, if `NULL` was passed as value.  
_isPartOfThePrimaryKey_  
&nbsp;&nbsp;&nbsp;&nbsp;If `YES` than column is part of primary key.  
  
__Return value__  
Autoreleased __DBCDatabaseTableColumnInfo__ instance.  
  
__Discussion__  
This method creates and initialize __DBCDatabaseTableColumnInfo__ instance which stored information about single database attached/created at current database connection.  
  
__See Also__  
<a href="#m2">- initDatabaseInfoWithSequence:name:filePath:</a>  
  
<a href="#top">Top</a>  

##__Instance methods__  

<font size="4"><a name="m2"/>initolumnInfoWithSequence:columnName:columnDataType:isNotNull:defaultValue:isPartOfThePrimaryKey:</font>  
  
Initialize __DBCDatabaseTableColumnInfo__ instance with sequence number, name and source path.  
  
<pre>- (id)initolumnInfoWithSequence:(int)<i>columnNumber</i> columnName:(NSString*)<i>columnName</i> 
                 columnDataType:(NSString*)<i>columnDataType</i> isNotNull:(BOOL)<i>isNotNull</i> 
                   defaultValue:(NSString*)<i>defaultVallue</i> isPartOfThePrimaryKey:(BOOL)<i>isPartOfThePrimaryKey</i></pre>  
__Parameters__  
_columnNumber_  
&nbsp;&nbsp;&nbsp;&nbsp;Column sequence number by order.  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;Column name.  
_columnDataType_  
&nbsp;&nbsp;&nbsp;&nbsp;Column data type.  
_isNotNull_  
&nbsp;&nbsp;&nbsp;&nbsp;If `YES` than column should be `NOT NULL`, otherwise `NO`.  
_defaultVallue_  
&nbsp;&nbsp;&nbsp;&nbsp;Default column value, if `NULL` was passed as value.  
_isPartOfThePrimaryKey_  
&nbsp;&nbsp;&nbsp;&nbsp;If `YES` than column is part of primary key.  
  
__Return value__  
Initialized __DBCDatabaseTableColumnInfo__ instance.  
  
__Discussion__  
This method creates and initialize __DBCDatabaseTableColumnInfo__ instance which stored information about single database attached/created at current database connection.  
  
__See Also__  
<a href="#m1">+ databaseInfoWithSequence:name:filePath:</a>  
  
<a href="#top">Top</a>  