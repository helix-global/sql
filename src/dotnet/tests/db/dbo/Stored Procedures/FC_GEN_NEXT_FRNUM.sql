CREATE procedure [dbo].[FC_GEN_NEXT_FRNUM] 
 @FRID int, @mode int
as 
SET nocount on

declare @res nvarchar(30)
declare @UserID int
declare @CreationDate datetime


select 
 @UserID = A.S_CR
,@CreationDate = cast(A.S_CDT as date)
,@res = A.FRNUM
from FC_REPORT A 
where A.ID = @FRID

if @res is not null
begin
  SET nocount off
  return
end

declare @nextN int

select @nextN = MAX(isnull(A.FRNUMN,0)) from FC_REPORT A with (nolock) where A.S_CR = @UserID and cast(A.S_CDT as date) = @CreationDate
set @nextN = ISNULL(@nextN,0) + 1

declare @yy nvarchar(4)
declare @mm nvarchar(2)
declare @dd nvarchar(4)

set @yy = LTRIM(str(datepart(yy,@CreationDate)))
set @mm = LTRIM(str(datepart(mm,@CreationDate)))  
set @dd = LTRIM(str(datepart(dd,@CreationDate)))    

if (LEN(@yy) = 4)
  set @yy = SUBSTRING(@yy,3,2)
if (LEN(@mm) = 1)  
  set @mm = '0'+@mm
if (LEN(@dd) = 1)  
  set @dd = '0'+@dd

declare @emplID int
select @emplID = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @UserID

declare @pn nvarchar(50)
select @pn = isnull(ltrim(cast(B.PERSONALNO as nvarchar)),'NA') from COM_EMPLOYEE B with (nolock) where B.ID = @emplID 

set @res = 'FR-'+@yy+@mm+@dd+'-'+@pn+'-'+LTRIM(str(@nextN))

update FC_REPORT set FRNUM = @res, FRNUMN = @nextN where ID = @FRID 

SET nocount off