CREATE function [dbo].[COM_EMPL_IDS_IN_SKILL_STR](@SkillID int, @dBeg datetime, @dEnd datetime, @UserID int)
returns nvarchar(max) as 
begin
  declare @res nvarchar(max) = ''
  
  select @res = @res + ',' + cast(EMP.ID as nvarchar)
	from COM_EMPLOYEE_SKILL S with (nolock)
	left join COM_EMPLOYEE EMP with (nolock) on EMP.ID = S.EMPLOYEEID
	where S.SKILLID = @SkillID
		 and isnull(S.S_CDT,'19900101') <= @dEnd
		 /*  TODO может ли быть что скилл "кончился" насовсем без продления ?
		 and isnull(S.EXPIRATION_DATE,'40000101') >= @dBeg
		 */
		 and EMP.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@UserID, 1, getdate()))
	GROUP BY EMP.ID 
    
  return @res
end