CREATE function [dbo].[PR_SNC](@DeviceID int)
returns nvarchar(50) as 
begin
  declare @res nvarchar(50) 
  declare @aMask nvarchar(50) 
  declare @aUpMask nvarchar(50)   
  declare @dt datetime  
  declare @origin nvarchar(20)
  declare @origin2 nvarchar(20)
  
  select @aMask = coalesce(nullif(B.SNMASK,''),nullif(C.SNMASK,''),'########')
       , @dt = A.S_CDT
       , @origin = isnull(S.VALUESTR,'0')
       , @origin2 = isnull(S2.VALUESTR,'X')
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_MODELTYPE C with (nolock) on C.ID = B.TYPEID
  left join DEF_SYSCONST S with (nolock) on S.LABEL = 'pr_origin'
  left join DEF_SYSCONST S2 with (nolock) on S2.LABEL = 'pr_origin2'
  where A.ID = @DeviceID;
  
  set @aUpMask = UPPER(@aMask);

  if @aUpMask = '-'
    return '-'

  declare @yyyy nvarchar(4);
  declare @yy nvarchar(4);
  declare @mm nvarchar(2);
  declare @dd nvarchar(2);
  declare @ww nvarchar(2);
  
  set @origin = RTRIM(LTRIM(@origin))

  set @yyyy = RTRIM(LTRIM(STR(YEAR(@dt))));
  set @yy = SUBSTRING(@yyyy,3,2);
  set @mm = RTRIM(LTRIM(STR(MONTH(@dt))));
  if LEN(@mm) = 1
    set @mm = '0' + @mm;
  set @dd = RTRIM(LTRIM(STR(DAY(@dt))));
  if LEN(@dd) = 1
    set @dd = '0' + @dd;
  
    
  set @res = @aMask;
  set @res = REPLACE(@res,'YYYY',@yyyy);
  set @res = REPLACE(@res,'YY',@yy);
  set @res = REPLACE(@res,'MM',@mm);
  set @res = REPLACE(@res,'DD',@dd);
  set @res = REPLACE(@res,'@',@origin);
  set @res = REPLACE(@res,'^',@origin2);
  
  set @res = REPLACE(@res,'\','');
  
  return @res
end