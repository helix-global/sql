CREATE function [dbo].[SW_VER_FINEACCESS](@aDepID int, @aUserID int, @aMode int, @aDate datetime)
returns nvarchar(max)
as
begin

if (@aDepID = 184 /*R&D-SD*/ and @aUserID = 37 /*FShcherbina*/)
  return null

if (@aDepID = 182 /*R&D-PL*/ and @aUserID in (53,56,57,58) /*mvladimirov,abeloglazov,ygerikalan,tbecker*/)
  return null
     
declare @res nvarchar(max)
     
set @res = dbo.COM_DEP_FINEACCESS(@aDepID, @aUserID, @aMode, @aDate)

return @res

end;