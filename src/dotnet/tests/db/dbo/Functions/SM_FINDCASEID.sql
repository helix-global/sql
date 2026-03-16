CREATE function [dbo].[SM_FINDCASEID](@MsgSubj nvarchar(max),@CustID int)
returns int
as
begin

  declare @res int = null
  declare @ServCaseN nvarchar(50)
  declare @i int = charindex('##',@MsgSubj)
  declare @mergedto int = null
  
  if @i > 0
  begin
      
      set @ServCaseN = substring(@MsgSubj,@i+2,12);
      declare @j int = charindex('##',@ServCaseN)
      
      if @j > 1
      begin
      
         set @ServCaseN = substring(@ServCaseN,1,@j-1);
         select @res = A.ID, @mergedto = A.MERGED2ID from SM_SERVICECASE A with (nolock) where A.ND = @ServCaseN
         
         if @mergedto is not null
         begin
            
            declare @z int = 0
            declare @mergedto2 int = null
            while @z < 100
            begin
               set @mergedto2 = null
               select @res = A.ID, @mergedto2 = A.MERGED2ID from SM_SERVICECASE A with (nolock) where A.ID = @mergedto
               if @mergedto2 is null break
               set @mergedto = @mergedto2
               set @z = @z + 1
            end
            
         end
      
      end
      
  end    

  return @res;
end;