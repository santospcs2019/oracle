



*******************************************************************
*                TUNNING                                          *
*******************************************************************



**************************************************************
* How to Tell if You got a Smart Scan                        *
**************************************************************
select sql_id,
 decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') Offloaded,
 decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,0,
 100*(IO_CELL_OFFLOAD_ELIGIBLE_BYTES-
 IO_INTERCONNECT_BYTES)/
 IO_CELL_OFFLOAD_ELIGIBLE_BYTES) as IO_SAVED
 from v$sql
 where sql_text like 'insert into star_cp.t%'; 
 
 result:
 
    SQL_ID      OFFLOADED              IO_SAVED
	
 6h1mfahnvfuy8    Yes	           99,96680427320075757575757575757575757576
 
 **************
 *** DICAS  ***
 *************
 
***  Mixed Workload Systems

Flash Cache is Key
• Expect 1-2ms Single Block Reads
• If Not Getting Them, Check for FC Problems
• Consider setting CELL_FLASH_CACHE to KEEP

• Remember Indexes Can Be Overused
(optimizer_index_cost_adj) <<<<<<<<<<<<<<<<<<-------------------------
 
 There are many new features in 11gR2:
• Auto DOP
• Parallel Queuing
• In-Memory Parallel
These are not specific to Exadata.
PX will be important in Exadata (uses Direct Path Read)

Every query is parallelized across multiple storage cells <<<<<<------------------------------------

May mean you don’t need as high DOP

Auto DOP is probably the wave of the future but still scary 


** INDICES

To Index or Not to Index?
Myth: Exadata doesn’t need any indexes
Truth: You’ll need indexes for single row access (OLTP)<<<<<-------
Note: Moving to Exadata will allow you to get rid
 of a bunch of indexes that you weren’t using
 in the first place.
Note2: Moving to Exadata may make many indexes
 that are being used unnecessary.
* Hint: Make them invisible first, and then remove them! <<<<<-------------


**Parallel?

There are many new features in 11gR2:

• Auto DOP

• Parallel Queuing

• In-Memory Parallel

These are not specific to Exadata.

PX will be important in Exadata (uses Direct Path Read)

Every query is parallelized across multiple storage cells

May mean you don’t need as high DOP

Auto DOP is probably the wave of the future but still scary.


** Nulls?

Can’t be indexed via B-Tree

Can’t do Partition Elimination

But they can be located with Storage Indexes

*We may want to re-think the use of nulls* 


** Compression (HCC)

Don’t even think about compressing active data…

• Every change migrates the affected row to a  <<<<------------------
new block (OLTP)

• Every change locks the entire Compression
Unit

• Partition large objects by time and <<<<<<-----------------------
compress inactive partitions 