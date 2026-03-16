CREATE function [dbo].[COM_IMP_RECOMMEND_FINEACCESS](@state int, @aUserID int)
returns nvarchar(max)
as
begin

declare @res nvarchar(max)
set @res = ''

declare @isSpv int = 0
declare @isPlm int = 0


set @isSpv = dbo.DEF_USERINGROUP1(@aUserID, 'SPV')
set @isPlm = dbo.DEF_USERINGROUP1(@aUserID, 'PLM')


if @state in(4130005,4130002)  and @isSpv=1
	set @res = 'SPV'

if @state in(4130001,4130007)  and @isPlm=1
	set @res = 'PLM'

if @state in(4130003)  and (@isPlm=1 or @isSpv=1)
	set @res = 'SPVPLM'

	                
if LEN(@res) = 0
   return null
     
return @res  

end;