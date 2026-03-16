create proc Zabbix_DB_Monitor
with EXECUTE AS OWNER --to be able to create utility table and make test transaction
as
begin
       waitfor delay '00:00:02'  --to limit amount of transaction per sec in case of DDOS or Zabbix bug
       set lock_timeout 5000       --don't wait for locks too much
       if object_id('Zabbix') is NULL create table dbo.Zabbix (c1 datetime)
       delete from Zabbix
       insert Zabbix values (GETDATE())
end