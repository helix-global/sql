CREATE PROCEDURE [dbo].[COM_ACCCRREQ_EXEC]  @ContextID int, @UserID int, @aMode int
AS
BEGIN
set nocount on

/* @aMode - 1 - не проверять наличие ID в AD */

declare @depID int
select @depID = A.DEPID
from COM_ACCCRREQ A
where A.ID = @ContextID

if dbo.COM_DEP_ACCESS2_OR_GROUP(@depID,3,@UserID,getdate(),'ADM') <> 1
begin
  raiserror('Unable to execute request for this department.',16,0);
  set nocount off
  return
end

if not exists (select A.ID from COM_ACCCRREQ_T A where A.VNESHID = @ContextID)
begin
  raiserror('Unable to execute request. The request is empty.',16,0);
  set nocount off
  return
end

declare @errStr nvarchar(max)

select top 1 @errStr = A.DOMAINACCOUNT
from COM_ACCCRREQ_T A
where A.VNESHID = @ContextID
  and exists (select B.ID from DEF_USERS B 
               where isnull(B.ISGROUP,0) = 0 
			     and (upper(B.LOGINNAME) = upper(A.DOMAINACCOUNT) or upper(B.LOGINNAME2) = upper(A.DOMAINACCOUNT))
				 and B.EMPLOYEEID is not null
				 )

if @errStr is not null
begin
  set @errStr = 'Unable to execute request. Account with domain name '+@errStr+' already exists in PDB.'
  raiserror(@errStr,16,0);
  set nocount off
  return
end

if isnull(@aMode,0) <> 1
begin
	set @errStr = null
	select top 1 @errStr = A.DOMAINACCOUNT
	from COM_ACCCRREQ_T A
	where A.VNESHID = @ContextID
	  and A.DOMAINACCOUNT_ID is null
	  
	if @errStr is not null
	begin
	  set @errStr = 'Domain account "'+@errStr+'" not found in AD.'
	  raiserror(@errStr,16,0);
	  set nocount off
	  return
	end
end

declare @noPN int 
set @noPN = dbo.DEF_SYS_CONST_INT('com_no_personalnumber',0)
 
if @noPN <> 1
begin

    set @errStr = null

    if isnull(@aMode,0) <> 1
    begin
     
		select top 1 @errStr = A.FULLNAME
		from COM_ACCCRREQ_T A
		where A.VNESHID = @ContextID
		  and isnull(A.PERSONALN,0) < 1
		  and isnull(A.TEMPEMPL,0) = 0
		  
		if @errStr is not null
		begin
		  set @errStr = 'Please enter personal number for employee '+@errStr+'.'
		  raiserror(@errStr,16,0);
		  set nocount off
		  return
		end
	
	end

    declare @errPN nvarchar(50)
    declare @errDepCode nvarchar(50)
	set @errStr = null
	
	select top 1 @errStr = A.NAME, @errPN = A.PERSONALNO, @errDepCode = DD.CODE
	from COM_EMPLOYEE A with (nolock)
	left join COM_DEPARTMENTS DD with (nolock) on DD.ID = A.DEPID
	where A.PERSONALNO in (select B.PERSONALN from COM_ACCCRREQ_T B where B.VNESHID = @ContextID and isnull(B.TEMPEMPL,0) = 0 and B.PERSONALN > 0)
	  and A.DISSDATE is null
		  
	if @errStr is not null
	begin
	  set @errStr = 'Employee record with personal number '+ltrim(rtrim(@errPN))+' already exists in PDB. Employee name: '+@errStr+'. Department: '+@errDepCode
	  raiserror(@errStr,16,0);
	  set nocount off
	  return
	end

end


insert into COM_EMPLOYEE (GID,S_S,S_CR,S_CDT,NAME,EMAIL,PHONE,DEPID,PERSONALNO,QUALIFICATION,PERSONALWT,GENDER,ISTEMP,REQUESTROWID,ROLEINDEP)
select newid(),1,@UserID,getdate(),A.FULLNAME,A.EMAIL,A.PHONEN,B.DEPID,A.PERSONALN,A.QUALIFICATION,A.PERSONALWT,A.GENDER,A.TEMPEMPL,A.ID,0
from COM_ACCCRREQ_T A
left join COM_ACCCRREQ B on B.ID = A.VNESHID
where A.VNESHID = @ContextID 

declare @usrs table (ID int not null,EMPLID int not null, DOMAINNAME nvarchar(100) not null, FULLNAME nvarchar(200), USERID int )

insert into @usrs (ID,EMPLID,DOMAINNAME,FULLNAME)
select A.ID,B.ID,A.DOMAINACCOUNT,A.FULLNAME
from COM_ACCCRREQ_T A 
left join COM_EMPLOYEE B on B.REQUESTROWID = A.ID
where A.VNESHID = @ContextID

update @usrs set USERID = (select B.ID from DEF_USERS B where (upper(B.LOGINNAME) = upper("@usrs".DOMAINNAME) or upper(B.LOGINNAME2) = upper("@usrs".DOMAINNAME)) and B.EMPLOYEEID is null and isnull(B.ISGROUP,0) = 0)

update DEF_USERS set EMPLOYEEID = (select B.EMPLID from @usrs B where B.USERID = DEF_USERS.ID)
                    ,REQUESTROWID = (select B.ID from @usrs B where B.USERID = DEF_USERS.ID)
where ID in (select C.USERID from @usrs C) 
  and EMPLOYEEID is null

insert into DEF_USERS (GID,S_S,S_CR,S_CDT,ISGROUP,LOGINNAME,FULLNAME,EMPLOYEEID,REQUESTROWID)
select newid(),1,@UserID,getdate(),0,A.DOMAINNAME,A.FULLNAME,A.EMPLID,A.ID
from @usrs A 
where A.USERID is null

declare @OP_grID int
declare @SPV_grID int

select @OP_grID = A.ID from DEF_USERS A where A.LOGINNAME = 'OP' and A.ISGROUP =1
select @SPV_grID = A.ID from DEF_USERS A where A.LOGINNAME = 'SPV' and A.ISGROUP =1

if @OP_grID is not null
begin

  insert into DEF_USERSTOGROUP (GID,S_CR,S_CDT,USERID,GROUPID)
  select newid(),@UserID,getdate(),B.ID,@OP_grID
  from COM_ACCCRREQ_T A 
  left join DEF_USERS B on B.REQUESTROWID = A.ID
  where A.VNESHID = @ContextID
    and A.R_OPERATOR = 1
    and not exists (select H.ID from DEF_USERSTOGROUP H where H.USERID = B.ID and H.GROUPID = @OP_grID)

end

if @SPV_grID is not null
begin

  insert into DEF_USERSTOGROUP (GID,S_CR,S_CDT,USERID,GROUPID)
  select newid(),@UserID,getdate(),B.ID,@SPV_grID
  from COM_ACCCRREQ_T A 
  left join DEF_USERS B on B.REQUESTROWID = A.ID
  where A.VNESHID = @ContextID
    and A.R_SUPERVISOR = 1
    and not exists (select H.ID from DEF_USERSTOGROUP H where H.USERID = B.ID and H.GROUPID = @SPV_grID)

end


set nocount off
END