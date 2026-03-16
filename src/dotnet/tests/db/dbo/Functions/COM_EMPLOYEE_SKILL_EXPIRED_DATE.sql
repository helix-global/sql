CREATE FUNCTION [dbo].[COM_EMPLOYEE_SKILL_EXPIRED_DATE]
(   
    @empID int, @skillID int
)
RETURNS DATETIME 
AS
begin

declare @ret datetime

declare @UserID int, @lastDate datetime, @dateCrSkill datetime, @expTypeId int, 
		@expTerm int, @prodSupport int, @prolongDate datetime, @notExpiring int,
		@withoutTraining int

select @UserID=ID 
from DEF_USERS with (nolock)
where EMPLOYEEID=@empID

select @dateCrSkill=C.SKILL_DATE, 
    @expTypeId=S.EXPIRATION_TERM_TYPE_ID, 
    @expTerm=S.EXPIRATION_TERM, 
    @prodSupport=S.PRODUCTION_SUPPORT,
    @prolongDate = P.PROLONG_DATE,
	@notExpiring = C.NOT_EXPIRING,
	@withoutTraining = isnull(C.WITHOUT_TRAINING,0) --навык добавлен вручную
from COM_EMPLOYEE_SKILL C with (nolock)
    join COM_SKILLS S with (nolock) on C.SKILLID=S.ID
    left join (select P.PROLONG_DATE as PROLONG_DATE, P.EMPLOYEEID, P.SKILLID 
                from COM_EMPLOYEE_SKILL_PROLONGATION P with (nolock)
                    join (select max(P.ID) as ID from COM_EMPLOYEE_SKILL_PROLONGATION P with (nolock) group by P.EMPLOYEEID, P.SKILLID) L on P.ID=L.ID
                ) P on C.EMPLOYEEID=P.EMPLOYEEID and C.SKILLID=P.SKILLID
where C.SKILLID=@skillID and C.EMPLOYEEID=@empID


select @lastDate = S.LAST_DATE
from
    (select ISNULL(S.SKILLID, S1.SKILLID) as SKILLID, MAX(T.DEND) as LAST_DATE
    from dbo.PR_OPERATION_TIME T   with (nolock)
        join dbo.PR_OPERATION O   with (nolock) on T.OPERID=O.ID
        left join dbo.COM_OPERATION_SKILL S on O.OPERTYPEID=S.OPERFORM_ID
        join dbo.PR_OPERATIONS OP  with (nolock) on O.OPERTYPEID=OP.ID
        left join dbo.COM_OPERATION_GROUP_SKILL S1 with (nolock) on OP.OPERGRID=S1.OPERGROUP_ID
    where T.USERID=@UserID and O.S_S=1000013 and ISNULL(S.SKILLID, S1.SKILLID)=@skillID
    group by ISNULL(S.SKILLID, S1.SKILLID)) S 
        join (select E.S_CDT, E.SKILLID from COM_SKILL_EMPLOYEES E with (nolock)
                    join DEF_USERS U with (nolock) on E.EMPLOYEEID=U.EMPLOYEEID
                where U.ID=@UserID) C on S.SKILLID=C.SKILLID


if @dateCrSkill is not null and @withoutTraining=1 and @dateCrSkill > isnull(@lastDate,'19000101')
  set @lastDate = @dateCrSkill  
  

if @notExpiring=1
begin
	set @ret = case 
            when @expTypeId=1 then DATEADD(day, @expTerm, getdate())
            when @expTypeId=2 then DATEADD(week, @expTerm, getdate())
            when @expTypeId=3 then DATEADD(month, @expTerm, getdate())
            when @expTypeId=4 then DATEADD(year, @expTerm, getdate()) 
		END
end
else
begin
	set @ret = case 
			when @prodSupport=1 and @expTypeId=1 then ISNULL(@prolongDate,DATEADD(day, @expTerm, @dateCrSkill))
			when @prodSupport=1 and @expTypeId=2 then ISNULL(@prolongDate,DATEADD(week, @expTerm, @dateCrSkill))
			when @prodSupport=1 and @expTypeId=3 then ISNULL(@prolongDate,DATEADD(month, @expTerm, @dateCrSkill))
			when @prodSupport=1 and @expTypeId=4 then ISNULL(@prolongDate,DATEADD(year, @expTerm, @dateCrSkill))
			when @prodSupport=0 and @expTypeId=1 then DATEADD(day, @expTerm, @lastDate)
			when @prodSupport=0 and @expTypeId=2 then DATEADD(week, @expTerm, @lastDate)
			when @prodSupport=0 and @expTypeId=3 then DATEADD(month, @expTerm, @lastDate)
			when @prodSupport=0 and @expTypeId=4 then DATEADD(year, @expTerm, @lastDate)
			else null end 
end
    
return @ret
end