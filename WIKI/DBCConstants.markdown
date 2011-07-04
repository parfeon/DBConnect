#__Constants__  
<a name="top"/>
[DBCDatabaseCR]:https://github.com/parfeon/DBConnect/wiki/DBCDatabase  
In this document you'll find contants which mainly used in [DBCDatabase][DBCDatabaseCR] and it's categories.  

#__Database encoding__  
Encoding constants specify how strings are encoded and stored in a database.  

<font color="#766666">typedef enum</font> {  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBCDatabaseEncodingUTF8">DBCDatabaseEncodingUTF8</a> <font color="#766666">= 0</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBCDatabaseEncodingUTF16">DBCDatabaseEncodingUTF16</a> <font color="#766666">= 1</font>,  
};  

__<font size="3">Constants</font>__  
<a name="DBCDatabaseEncodingUTF8"/><font color="#766666">DBCDatabaseEncodingUTF8</font>  
&nbsp;&nbsp;&nbsp;&nbsp;Tell to use UTF-8 encoding for strings.  
<a name="DBCDatabaseEncodingUTF16"/><font color="#766666">DBCDatabaseEncodingUTF16</font>  
&nbsp;&nbsp;&nbsp;&nbsp;Tell to use UTF-16 encoding for strings. 

<a href="#top">Top</a>  

##__Transaction journaling mode__  
This constants allow to control transaction journal mode behavior.  

<font color="#766666">typedef enum</font> {  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBCDatabaseJournalingModeDelete">DBCDatabaseJournalingModeDelete</a> <font color="#766666">= 0</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBCDatabaseJournalingModeTruncate">DBCDatabaseJournalingModeTruncate</a> <font color="#766666">= 1</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBCDatabaseJournalingModePersist">DBCDatabaseJournalingModePersist</a> <font color="#766666">= 2</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBCDatabaseJournalingModeMemory">DBCDatabaseJournalingModeMemory</a> <font color="#766666">= 3</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBCDatabaseJournalingModeOff">DBCDatabaseJournalingModeOff</a> <font color="#766666">= 4</font>,  
};  

__<font size="3">Constants</font>__  
<a name="DBCDatabaseJournalingModeDelete"/><font color="#766666">DBCDatabaseJournalingModeDelete</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This is default behavior which tell database to remove journal file as soon as transaction is completed.  
<a name="DBCDatabaseJournalingModeTruncate"/><font color="#766666">DBCDatabaseJournalingModeTruncate</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This constant is used to tell database to truncate file to zero bytes length as soon as transaction is completed. Sometime this is faster than  
&nbsp;&nbsp;&nbsp;&nbsp;delete whole file.  
<a name="DBCDatabaseJournalingModePersist"/><font color="#766666">DBCDatabaseJournalingModePersist</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This constant is used to tell database to keep journal file after transaction completed, database will overwrite header to mark it as invalid.   
<a name="DBCDatabaseJournalingModeMemory"/><font color="#766666">DBCDatabaseJournalingModeMemory</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This constant is used to tell database place transaction journal into memory which gives better performance but also make this option  
&nbsp;&nbsp;&nbsp;&nbsp;dangerous. If application crashed or killed while transaction is in process, than database file probably would be corrupted.  
<a name="DBCDatabaseJournalingModeOff"/><font color="#766666">DBCDatabaseJournalingModeOff</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This constant is used to tell database don't create transaction journal file at all. This is dangerous same as  
&nbsp;&nbsp;&nbsp;&nbsp;DBCDatabaseJournalingModeMemory option.  

<a href="#top">Top</a>  

##__Database file locking mode__  
This constants allow to specify how database file locks are managed.  

<font color="#766666">typedef enum</font> {  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBCDatabaseLockingModeNormal">DBCDatabaseLockingModeNormal</a> <font color="#766666">= 0</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBCDatabaseLockingModeExclusive">DBCDatabaseLockingModeExclusive</a> <font color="#766666">= 1</font>,  
};  

__<font size="3">Constants</font>__  
<a name="DBCDatabaseLockingModeNormal"/><font color="#766666">DBCDatabaseLockingModeNormal</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This constant is used to tell database to acquire and release the appropriate locks with each transaction.  
<a name="DBCDatabaseLockingModeExclusive"/><font color="#766666">DBCDatabaseLockingModeExclusive</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This constant is used to tell database to acquire locks in normal fashion and don't release them even if transaction is completed.  
  
<a href="#top">Top</a>  

##__Database transaction lock modes__  
This constants allow to specify which locks should be used by specific transaction.  

<font color="#766666">typedef enum</font> {  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBCDatabaseAutocommitModeDeferred">DBCDatabaseAutocommitModeDeferred</a> <font color="#766666">= 0</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBCDatabaseAutocommitModeImmediate">DBCDatabaseAutocommitModeImmediate</a> <font color="#766666">= 1</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBCDatabaseAutocommitModeExclusive">DBCDatabaseAutocommitModeExclusive</a> <font color="#766666">= 2</font>,  
};  

__<font size="3">Constants</font>__  
<a name="DBCDatabaseAutocommitModeDeferred"/><font color="#766666">DBCDatabaseAutocommitModeDeferred</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This constant is used to make transaction not acquire any locks until they are needed. This is default transaction locking mode.  
<a name="DBCDatabaseAutocommitModeImmediate"/><font color="#766666">DBCDatabaseAutocommitModeImmediate</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This constant is used to make transaction acquire the reserved locks, but still allow other clients to read from the database.  
<a name="DBCDatabaseLockingModeExclusive"/><font color="#766666">DBCDatabaseLockingModeExclusive</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This constant is used to make transaction to try acquire full controller over database and deny access from other clients.  
  
<a href="#top">Top</a>  
