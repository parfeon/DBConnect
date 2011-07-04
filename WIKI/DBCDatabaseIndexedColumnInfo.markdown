#__DBCDatabaseIndexedColumnInfo Class Reference__  
[SQLitews]:http://www.sqlite.org  
[APPLFastEnumerationProtocol]:http://developer.apple.com/library/ios/#documentation/cocoa/reference/NSFastEnumeration_protocol/Reference/NSFastEnumeration.html
[DBCDatabaseResultCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabaseResult  
[DBCDatabaseCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase  
[DBCDatabaseBasicExample]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase#basicExample  
[DBCDatabaseIndexInfo]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase+Aliases#m17  
<a name="top"/><font size="6">__Overview__</font>  
This class holds information about column which is part of table index and was retrieved as result of [indexedColumnsList:index:error:][DBCDatabaseIndexInfo].  
This class holds information about:
<ul>
<li>column index inside table index</li>
<li>column index inside table</li>
<li>column name</li>
</ul>
  
##__Tasks__  
###__DBCDatabaseIndexedColumnInfo initialization__  
<a href="#m1">+ indexedColumnInfoWithSequence:inTableSequenceNumber:name:</a>  
<a href="#m2">- initIndexedColumnInfoWithSequence:inTableSequenceNumber:name:</a>  
###__DBCDatabaseIndexedColumnInfo properties__  
<a href="#p1">indexInIndex</a>  
<a href="#p2">indexInTable</a>  
<a href="#p3">name</a>  

##__Properties__  

<font size="4"><a name="p1"/>indexInIndex</font>  
  
This property stores information about sequence number of column inside index.  
  
<pre>@property (nonatomic, readonly, getter = indexInIndex)int colIdxInIndex</pre>   
  
__Return value__  
Sequence number of column inside index.  
  
__See Also__  
<a href="#p2">indexInTable</a>  
<a href="#p3">name</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="p2"/>indexInTable</font>  
  
This property stores information about column sequence number inside table.  
  
<pre>@property (nonatomic, readonly, getter = indexInTable)int colIdxInTable</pre>   
  
__Return value__  
Column sequence number inside table.  
  
__See Also__  
<a href="#p1">indexInIndex</a>  
<a href="#p3">name</a>  
  
<a href="#top">Top</a>  
  
* * *  

<font size="4"><a name="p3"/>name</font>  
  
This property stores information about column name.  
  
<pre>@property (nonatomic, readonly, getter = name)NSString *colName</pre>   
  
__Return value__  
Column name.  
  
__See Also__  
<a href="#p1">indexInIndex</a>  
<a href="#p2">indexInTable</a>  
  
<a href="#top">Top</a>  

##__Class methods__  

<font size="4"><a name="m1"/>indexedColumnInfoWithSequence:inTableSequenceNumber:name:</font>  
  
Create and initialize __DBCDatabaseIndexedColumnInfo__ instance with in index sequence number, in table sequence number and column name.  
  
<pre>+ (id)indexedColumnInfoWithSequence:(int)<i>columnIndexInIndex</i> inTableSequenceNumber:(int)<i>columnIndexInTable</i> 
                               name:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_columnIndexInIndex_  
&nbsp;&nbsp;&nbsp;&nbsp;Sequence number of column inside index.  
_columnIndexInTable_  
&nbsp;&nbsp;&nbsp;&nbsp;Column sequence number inside table.  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;Column name.  
  
__Return value__  
Autoreleased __DBCDatabaseIndexedColumnInfo__ instance.  
  
__Discussion__  
This method creates and initialize __DBCDatabaseIndexedColumnInfo__ instance which stored information about indexed column.  
  
__See Also__  
<a href="#m2">- initIndexedColumnInfoWithSequence:inTableSequenceNumber:name:</a>  
  
<a href="#top">Top</a>  

##__Instance methods__  

<font size="4"><a name="m2"/>initIndexedColumnInfoWithSequence:inTableSequenceNumber:name:</font>  
  
Initialize __DBCDatabaseIndexedColumnInfo__ instance with in index sequence number, in table sequence number and column name.  
  
<pre>- (id)initIndexedColumnInfoWithSequence:(int)<i>columnIndexInIndex</i> inTableSequenceNumber:(int)<i>columnIndexInTable</i> 
                                   name:(NSString*)<i>columnName</i></pre>  
__Parameters__  
_sequenceNumber_  
_columnIndexInIndex_  
&nbsp;&nbsp;&nbsp;&nbsp;Sequence number of column inside index.  
_columnIndexInTable_  
&nbsp;&nbsp;&nbsp;&nbsp;Column sequence number inside table.  
_columnName_  
&nbsp;&nbsp;&nbsp;&nbsp;Column name.  
  
__Return value__  
Initialized __DBCDatabaseIndexedColumnInfo__ instance.  
  
__Discussion__  
This method creates and initialize __DBCDatabaseIndexedColumnInfo__ instance which stored information about indexed column.  
  
__See Also__  
<a href="#m1">+ indexedColumnInfoWithSequence:inTableSequenceNumber:name:</a>  
  
<a href="#top">Top</a>  