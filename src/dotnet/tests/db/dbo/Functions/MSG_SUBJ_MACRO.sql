CREATE function [dbo].[MSG_SUBJ_MACRO](@aSubj nvarchar(max),@aNow datetime)
returns nvarchar(max) as 
begin

  declare @res nvarchar(max);
  set @res = @aSubj;
  
  declare @yyyy nvarchar(4);
  declare @yy nvarchar(4);
  declare @mm nvarchar(2);
  declare @dd nvarchar(2);
  declare @ww nvarchar(2);
  
  set @yyyy = RTRIM(LTRIM(STR(YEAR(@aNow))));
  set @yy = SUBSTRING(@yyyy,3,2);
  set @mm = RTRIM(LTRIM(STR(MONTH(@aNow))));
  if LEN(@mm) = 1
    set @mm = '0' + @mm;
  set @dd = RTRIM(LTRIM(STR(DAY(@aNow))));
  if LEN(@dd) = 1
    set @dd = '0' + @dd;
  set @ww = DATEPART(iso_week, @aNow);
  if LEN(@ww) = 1
    set @ww = '0' + @ww;
  
  
  set @res = REPLACE(@res,'{YYYY}',@yyyy)
  set @res = REPLACE(@res,'{YY}',@yy)
  set @res = REPLACE(@res,'{MM}',@mm)
  set @res = REPLACE(@res,'{DD}',@dd) 
  set @res = REPLACE(@res,'{WW}',@ww) 


  declare @yyyyND nvarchar(4);
  declare @yyND nvarchar(4);
  declare @mmND nvarchar(2);
  declare @ddND nvarchar(2);
  declare @wwND nvarchar(2);
  
  declare @ND datetime = dateadd(day,1,@aNow)
  
  set @yyyyND = RTRIM(LTRIM(STR(YEAR(@ND))));
  set @yyND = SUBSTRING(@yyyyND,3,2);
  set @mmND = RTRIM(LTRIM(STR(MONTH(@ND))));
  if LEN(@mmND) = 1
    set @mmND = '0' + @mmND;
  set @ddND = RTRIM(LTRIM(STR(DAY(@ND))));
  if LEN(@ddND) = 1
    set @ddND = '0' + @ddND;
  set @wwND = DATEPART(iso_week, @ND);
  if LEN(@wwND) = 1
    set @wwND = '0' + @wwND;
  
  
  set @res = REPLACE(@res,'{NextDayYYYY}',@yyyyND)
  set @res = REPLACE(@res,'{NextDayYY}',@yyND)
  set @res = REPLACE(@res,'{NextDayMM}',@mmND)
  set @res = REPLACE(@res,'{NextDayDD}',@ddND) 
  set @res = REPLACE(@res,'{NextDayWW}',@wwND) 
  
 
  return @res;
  
end