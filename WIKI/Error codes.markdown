<a name="top"/>
#__Error codes__  
In this document I'll enumerate possible error codes.  

<font color="#766666">enum</font> {  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_ERROR">SQLITE_ERROR</a> <font color="#766666">= 1</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_INTERNAL">SQLITE_INTERNAL</a> <font color="#766666">= 2</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_PERM">SQLITE_PERM</a> <font color="#766666">= 3</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_ABORT">SQLITE_ABORT</a> <font color="#766666">= 4</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_BUSY">SQLITE_BUSY</a> <font color="#766666">= 5</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_LOCKED">SQLITE_LOCKED</a> <font color="#766666">= 6</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_NOMEM">SQLITE_NOMEM</a> <font color="#766666">= 7</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_READONLY">SQLITE_READONLY</a> <font color="#766666">= 8</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_INTERRUPT">SQLITE_INTERRUPT</a> <font color="#766666">= 9</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_IOERR">SQLITE_IOERR</a> <font color="#766666">= 10</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_CORRUPT">SQLITE_CORRUPT</a> <font color="#766666">= 11</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_NOTFOUND">SQLITE_NOTFOUND</a> <font color="#766666">= 12</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_FULL">SQLITE_FULL</a> <font color="#766666">= 13</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_CANTOPEN">SQLITE_CANTOPEN</a> <font color="#766666">= 14</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_PROTOCOL">SQLITE_PROTOCOL</a> <font color="#766666">= 15</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_EMPTY">SQLITE_EMPTY</a> <font color="#766666">= 16</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_SCHEMA">SQLITE_SCHEMA</a> <font color="#766666">= 17</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_TOOBIG">SQLITE_TOOBIG</a> <font color="#766666">= 18</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_CONSTRAINT">SQLITE_CONSTRAINT</a> <font color="#766666">= 19</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_MISMATCH">SQLITE_MISMATCH</a> <font color="#766666">= 20</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_MISUSE">SQLITE_MISUSE</a> <font color="#766666">= 21</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_NOLFS">SQLITE_NOLFS</a> <font color="#766666">= 22</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_AUTH">SQLITE_AUTH</a> <font color="#766666">= 23</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_FORMAT">SQLITE_FORMAT</a> <font color="#766666">= 24</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_RANGE">SQLITE_RANGE</a> <font color="#766666">= 25</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_NOTADB">SQLITE_NOTADB</a> <font color="#766666">= 26</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_OOM">SQLITE_OOM</a> <font color="#766666">= 2000</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_SYNTAX_ERROR">SQLITE_SYNTAX_ERROR</a> <font color="#766666">= 2001</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_INCOMPLETE_REQUEST">SQLITE_INCOMPLETE_REQUEST</a> <font color="#766666">= 2002</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#SQLITE_GENERAL_PROCESSING_ERROR">SQLITE_GENERAL_PROCESSING_ERROR</a> <font color="#766666">= 2003</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBC_TARGET_FILE_MISSED">DBC_TARGET_FILE_MISSED</a> <font color="#766666">= 3000</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBC_WRONG_BINDING_PARMETERS_COUNT">DBC_WRONG_BINDING_PARMETERS_COUNT</a> <font color="#766666">= 3001</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBC_CANT_CREATE_FOLDER_FOR_MUTABLE_DATABASE">DBC_CANT_CREATE_FOLDER_FOR_MUTABLE_DATABASE</a> <font color="#766666">= 3002</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBC_CANT_COPY_DATABASE_FILE_TO_NEW_LOCATION">DBC_CANT_COPY_DATABASE_FILE_TO_NEW_LOCATION</a> <font color="#766666">= 3003</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBC_CANT_REMOVE_CREATED_CORRUPTED_DATABASE_FILE">DBC_CANT_REMOVE_CREATED_CORRUPTED_DATABASE_FILE</a> <font color="#766666">= 3004</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBC_DATABASE_PATH_NOT_SPECIFIED">DBC_DATABASE_PATH_NOT_SPECIFIED</a> <font color="#766666">= 3005</font>,  
&nbsp;&nbsp;&nbsp;&nbsp;<a href="#DBC_SPECIFIED_FILE_NOT_FOUND">DBC_SPECIFIED_FILE_NOT_FOUND</a> <font color="#766666">= 3006</font>,  
};  

__<font size="3">Constants</font>__  
<a name="SQLITE_ERROR"/><font color="#766666">SQLITE_ERROR</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error returned by database and means some general error or database missing.  
<a name="SQLITE_INTERNAL"/><font color="#766666">SQLITE_INTERNAL</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means internal logic error in SQLite.  
<a name="SQLITE_PERM"/><font color="#766666">SQLITE_PERM</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what there is no access permission.  
<a name="SQLITE_ABORT"/><font color="#766666">SQLITE_ABORT</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what some callback routine aborted request.  
<a name="SQLITE_BUSY"/><font color="#766666">SQLITE_BUSY</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what database file is locked by another process or client.  
<a name="SQLITE_LOCKED"/><font color="#766666">SQLITE_LOCKED</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what a table in database is locked.  
<a name="SQLITE_NOMEM"/><font color="#766666">SQLITE_NOMEM</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what there is no memory for malloc().  
<a name="SQLITE_READONLY"/><font color="#766666">SQLITE_READONLY</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what client tried to write into readonly database.  
<a name="SQLITE_INTERRUPT"/><font color="#766666">SQLITE_INTERRUPT</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what operation was terminated by sqlite3_interrupt().  
<a name="SQLITE_IOERR"/><font color="#766666">SQLITE_IOERR</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what some kind of disk I/O error occured.  
<a name="SQLITE_CORRUPT"/><font color="#766666">SQLITE_CORRUPT</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what database disk image is malformed.  
<a name="SQLITE_NOTFOUND"/><font color="#766666">SQLITE_NOTFOUND</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what table or record not found.  
<a name="SQLITE_FULL"/><font color="#766666">SQLITE_FULL</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what data insertion failed because database is full.  
<a name="SQLITE_CANTOPEN"/><font color="#766666">SQLITE_CANTOPEN</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what database file can't be opened.  
<a name="SQLITE_PROTOCOL"/><font color="#766666">SQLITE_PROTOCOL</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what occurred database lock protocol error.  
<a name="SQLITE_EMPTY"/><font color="#766666">SQLITE_EMPTY</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what database is empty.  
<a name="SQLITE_SCHEMA"/><font color="#766666">SQLITE_SCHEMA</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what database schema was changed.  
<a name="SQLITE_TOOBIG"/><font color="#766666">SQLITE_TOOBIG</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what string or BLOB exceeds size limits.  
<a name="SQLITE_CONSTRAINT"/><font color="#766666">SQLITE_CONSTRAINT</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what operation was aborted due to constraint violation.  
<a name="SQLITE_MISMATCH"/><font color="#766666">SQLITE_MISMATCH</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what data mismatch was found in request.  
<a name="SQLITE_MISUSE"/><font color="#766666">SQLITE_MISUSE</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what library was used incorrectly.  
<a name="SQLITE_NOLFS"/><font color="#766666">SQLITE_NOLFS</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what was used OS features which not supported by host.  
<a name="SQLITE_AUTH"/><font color="#766666">SQLITE_AUTH</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what authorization denied.  
<a name="SQLITE_FORMAT"/><font color="#766666">SQLITE_FORMAT</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what auxiliary database format error found.  
<a name="SQLITE_RANGE"/><font color="#766666">SQLITE_RANGE</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what second parameter passed into sqlite3_bind_* is out of range.  
<a name="SQLITE_NOTADB"/><font color="#766666">SQLITE_NOTADB</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what opened file is not a database file.  
<a name="SQLITE_OOM"/><font color="#766666">SQLITE_OOM</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means out-of-memory.  
<a name="SQLITE_SYNTAX_ERROR"/><font color="#766666">SQLITE_SYNTAX_ERROR</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what SQL syntax error was found.  
<a name="SQLITE_INCOMPLETE_REQUEST"/><font color="#766666">SQLITE_INCOMPLETE_REQUEST</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what SQL query is not completed.  
<a name="SQLITE_GENERAL_PROCESSING_ERROR"/><font color="#766666">SQLITE_GENERAL_PROCESSING_ERROR</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what occurred some general error during SQL processings.  
<a name="DBC_TARGET_FILE_MISSED"/><font color="#766666">DBC_TARGET_FILE_MISSED</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what provided file can't be found on specified file path.  
<a name="DBC_WRONG_BINDING_PARMETERS_COUNT"/><font color="#766666">DBC_WRONG_BINDING_PARMETERS_COUNT</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what wrong number of parameters was passed for binding to SQL statement.  
<a name="DBC_CANT_CREATE_FOLDER_FOR_MUTABLE_DATABASE"/><font color="#766666">DBC_CANT_CREATE_FOLDER_FOR_MUTABLE_DATABASE</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what occurred error when tried to create folder at specified path when making mutable copy of database file.  
<a name="DBC_CANT_COPY_DATABASE_FILE_TO_NEW_LOCATION"/><font color="#766666">DBC_CANT_COPY_DATABASE_FILE_TO_NEW_LOCATION</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what occurred error when tried to copy database file to new location where it can be mutated.  
<a name="DBC_CANT_REMOVE_CREATED_CORRUPTED_DATABASE_FILE"/><font color="#766666">DBC_CANT_REMOVE_CREATED_CORRUPTED_DATABASE_FILE</font>  
&nbsp;&nbsp;&nbsp;&nbsp;Tell to use UTF-16 encoding for strings.  
<a name="DBC_DATABASE_PATH_NOT_SPECIFIED"/><font color="#766666">DBC_DATABASE_PATH_NOT_SPECIFIED</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what database file path not specified.  
<a name="DBC_SPECIFIED_FILE_NOT_FOUND"/><font color="#766666">DBC_SPECIFIED_FILE_NOT_FOUND</font>  
&nbsp;&nbsp;&nbsp;&nbsp;This error means what specified file not found at it's path.  