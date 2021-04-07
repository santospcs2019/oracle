/*
--- Header: $Id: h1.sql 26 2015-12-01 23:16:22Z mve $
--- Copyright 2015 HASHJOIN (http://www.hashjoin.com/). All Rights Reserved.

- gets report from AWR based on the following parameters
- saves output in h1_out table for comparison (See h1d.sql)

1: start HHMI     [0317 = 3:17am]
2: end HHMI       [0825 = 8:25am]
3: days back      [0 = today; 7 = seven days back]
4: instance       [1 = INST_ID=1, give -1 for all]
5: service_hash   [1225919510 = dba_services.name_hash, give -1 for all]

@h1 0317 0825 0 -1 -1
@h1 0317 0825 7 3 1225919510
*/


set term off
set echo off
--drop table h1_out;
create table h1_out(
	PROGRAM		varchar2(64)
,	MODULE		VARCHAR2(48)
,	ash_secs	number(30)
,	min_ts		varchar2(5)
,	max_ts		varchar2(5)
,	EVENT		VARCHAR2(64)
,	WAIT_CLASS	VARCHAR2(64)
,	run_id		number(10));
--,	constraint h1_out_pk primary key(run_id) using index );

create index h1_out_indx on h1_out(run_id);

create sequence h1_out_s;


set lines 128
set pages 100
set trims on
col module format a25 trunc
col program format a25 trunc
col event format a25 trunc
col wait_Class format a15
col min_ts heading "Start"
col max_ts heading "End"
col ash_secs heading "ASH|Seconds"

col PLAN_TABLE_OUTPUT format a132

col str new_value _str
col edn new_value _edn
col run_id new_value _rid

select to_char(sysdate-&&3,'yyyymmdd')||'&&1' str,
       to_char(sysdate-&&3,'yyyymmdd')||'&&2' edn,
       h1_out_s.nextval run_id
  from dual;

insert into h1_out
SELECT /*+LEADING(x h) USE_NL(h)*/
--       h.INSTANCE_NUMBER
--       h.sql_id
--,      h.sql_plan_hash_value
--,      h.sql_child_number
	PROGRAM
,	nvl(module,'null')
,      SUM(10) ash_secs
,       to_char(min(h.sample_time),'HH24:MI') min_ts
,       to_char(max(h.sample_time),'HH24:MI') max_ts
,      nvl(h.event,'ON_CPU') event
,	h.wait_Class
,	&&_rid
FROM dba_hist_snapshot x
,    dba_hist_active_sess_history h
WHERE x.end_interval_time <= TO_DATE(to_char(sysdate-&&3,'yyyymmdd')||'&&2','yyyymmddhh24mi')
AND x.begin_interval_time >= TO_DATE(to_char(sysdate-&&3,'yyyymmdd')||'&&1','yyyymmddhh24mi')
AND h.sample_time BETWEEN TO_DATE(to_char(sysdate-&&3,'yyyymmdd')||'&&1','yyyymmddhh24mi') AND
                          TO_DATE(to_char(sysdate-&&3,'yyyymmdd')||'&&2','yyyymmddhh24mi')
AND h.snap_id = x.snap_id
AND h.dbid = x.dbid
AND h.instance_number = x.instance_number
and x.INSTANCE_NUMBER = decode(&&4,-1,x.INSTANCE_NUMBER,&&4)
and h.service_hash = decode(&&5,-1,h.service_hash,&&5)
--AND h.event = '4'
--and h.wait_Class = 'Cluster'
GROUP BY
--	h.INSTANCE_NUMBER
--,	h.sql_id
--,	h.sql_plan_hash_value
--,	h.sql_child_number
	PROGRAM
,	module
,	h.event
,	h.wait_Class
having SUM(10) > 900
ORDER BY ash_secs DESC;

commit;

set term on

ttit "Date Range: &&_str &&_edn"
select * from h1_out where run_id = &&_rid order by ash_secs DESC;


set echo on

