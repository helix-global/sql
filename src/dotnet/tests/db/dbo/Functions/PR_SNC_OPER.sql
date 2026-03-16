CREATE function [dbo].[PR_SNC_OPER](@OperID int)
returns nvarchar(50) as 
begin
  declare @res nvarchar(50) 
  declare @aMask nvarchar(50) 
  declare @aUpMask nvarchar(50)   
  declare @aDate datetime
  declare @origin nvarchar(20)
  declare @origin2 nvarchar(20)
  
  select @aMask = coalesce(nullif(B.SNMASK,''),nullif(C.SNMASK,''),'########')
         ,@aDate = O.S_MDT
         ,@origin = isnull(S.VALUESTR,'0')
         ,@origin2 = isnull(S2.VALUESTR,'X')
  from PR_OPERATION O with (nolock)
  left join PR_DEVICE A with (nolock) on A.ID = O.DEVICEID
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_MODELTYPE C with (nolock) on C.ID = B.TYPEID
  left join DEF_SYSCONST S with (nolock) on S.LABEL = 'pr_origin'
  left join DEF_SYSCONST S2 with (nolock) on S2.LABEL = 'pr_origin2'
  where O.ID = @OperID;
  
  set @aUpMask = UPPER(@aMask);

  if @aUpMask = '-'
    return '-'

  declare @yyyy nvarchar(4);
  declare @yy nvarchar(4);
  declare @mm nvarchar(2);
  declare @dd nvarchar(2);
  declare @ww nvarchar(2);

  set @yyyy = RTRIM(LTRIM(STR(YEAR(@aDate))));
  set @yy = SUBSTRING(@yyyy,3,2);
  set @mm = RTRIM(LTRIM(STR(MONTH(@aDate))));
  if LEN(@mm) = 1
    set @mm = '0' + @mm;
  set @dd = RTRIM(LTRIM(STR(DAY(@aDate))));
  if LEN(@dd) = 1
    set @dd = '0' + @dd;
  
    
  set @res = @aMask;
  set @res = REPLACE(@res,'YYYY',@yyyy);
  set @res = REPLACE(@res,'YY',@yy);
  set @res = REPLACE(@res,'MM',@mm);
  set @res = REPLACE(@res,'DD',@dd);
  set @res = REPLACE(@res,'@',@origin);
  set @res = REPLACE(@res,'^',@origin2);  
    
  return @res
end