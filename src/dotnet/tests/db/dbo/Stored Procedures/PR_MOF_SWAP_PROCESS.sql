CREATE procedure [dbo].[PR_MOF_SWAP_PROCESS] @UserID int, @DevID1 int, @DevID2 int, @MOF1 nvarchar(50), @MOF2 nvarchar(50)
as
set nocount on
/*

1. Копируется MOF первого изделия, ему присваивается номер @MOF1
2. Изделие @DevID2 привязывается к нему

3. Копируется MOF второго изделия, ему присваивается номер @MOF2
4. Изделие @DevID1 привязывается к нему

*/

declare @sourceOrd1 int
declare @newID1 int
declare @newSOid1 int
declare @oldSOid1 int

declare @sourceOrd2 int
declare @newID2 int
declare @newSOid2 int
declare @oldSOid2 int


select @sourceOrd1 = A.ORDERID, @oldSOid1 = A.SORDERID from PR_DEVICE A where A.ID = @DevID1
select @sourceOrd2 = A.ORDERID, @oldSOid2 = A.SORDERID from PR_DEVICE A where A.ID = @DevID2


/* MOF */

insert into PR_PRORDER (GID,S_CR,S_CDT,S_S,NN,DD,URGENCY,CUSTOMERID,DEPARTMENTID,ORDERTYPE,EXPDATE,NN2,SPREQ,NN3)
select newid(),@UserID,getdate(),A.S_S,@MOF1,A.DD,A.URGENCY,A.CUSTOMERID,A.DEPARTMENTID,A.ORDERTYPE,A.EXPDATE,A.NN2,A.SPREQ,A.NN3
from PR_PRORDER A 
where A.ID = @sourceOrd1

select @newID1 = @@IDENTITY

insert into PR_PRORDER (GID,S_CR,S_CDT,S_S,NN,DD,URGENCY,CUSTOMERID,DEPARTMENTID,ORDERTYPE,EXPDATE,NN2,SPREQ,NN3)
select newid(),@UserID,getdate(),A.S_S,@MOF2,A.DD,A.URGENCY,A.CUSTOMERID,A.DEPARTMENTID,A.ORDERTYPE,A.EXPDATE,A.NN2,A.SPREQ,A.NN3
from PR_PRORDER A 
where A.ID = @sourceOrd2

select @newID2 = @@IDENTITY

/* строки MOF*/

insert into PR_PRORDER_T (GID,S_CR,S_CDT,PRORDERID,MODELID,REVID,QUANTITY,REMARK)
select newid(),@UserID,getdate(),@newID1,A.MODELID,A.REVID,1,A.REMARK
from PR_PRORDER_T A where A.PRORDERID = @newID1

insert into PR_PRORDER_T (GID,S_CR,S_CDT,PRORDERID,MODELID,REVID,QUANTITY,REMARK)
select newid(),@UserID,getdate(),@newID2,A.MODELID,A.REVID,1,A.REMARK
from PR_PRORDER_T A where A.PRORDERID = @newID2


/* supply orders */

insert into PR_SUPPLY (GID,S_CR,S_CDT,S_S,ND,DD,URGENCY,CUSTOMERID,DEPARTMENTID,SPREQ)
select newid(),@UserID,getdate(),A.S_S,A.ND,A.DD,A.URGENCY,A.CUSTOMERID,A.DEPARTMENTID,A.SPREQ
from PR_SUPPLY A 
where A.ID = @oldSOid1

select @newSOid1 = @@IDENTITY

insert into PR_SUPPLY (GID,S_CR,S_CDT,S_S,ND,DD,URGENCY,CUSTOMERID,DEPARTMENTID,SPREQ)
select newid(),@UserID,getdate(),A.S_S,A.ND,A.DD,A.URGENCY,A.CUSTOMERID,A.DEPARTMENTID,A.SPREQ
from PR_SUPPLY A 
where A.ID = @oldSOid2

select @newSOid2 = @@IDENTITY



/* подмена в изделиях */

update PR_DEVICE set ORDERID = @newID1, SORDERID = @newSOid1 where PR_DEVICE.ID = @DevID2

update PR_DEVICE set ORDERID = @newID2, SORDERID = @newSOid2 where PR_DEVICE.ID = @DevID1


set nocount off