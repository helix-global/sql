create function [dbo].[FC_REPORT_FROMDEPTRANSIT]( @RealFromDepID int, @UserID int , @aMode int)
returns int
as
begin
/*
KB240
Выводить сотрудникам отдела SG доступ к отчету Internal Delivery Note документа FAR
, если этот документ был создан одним из перечисленных аффилированных подразделений. 
В самом отчете в поле "VON - from" должен фигурировать отдел SG.
*/

/*
если сотрудник принадлежит "транзитному" подразделению "A" (SG например), а @RealFromDepID перечислено в списке
подразделений, для которых "A" является транзитным, то вместо @RealFromDepID выдать "A"  
*/

declare @res int 
set @res = @RealFromDepID
     
declare @UserDep int
select @UserDep = dbo.COM_USER_DEPARTMENT( @UserID)

if exists (select B.ID from FC_TRANSIT_DEP B with (nolock) where B.DEPID = @UserDep and B.FOR_DEPID =  @RealFromDepID  )
begin
   set @res = @UserDep 
end     
     
return @res  

end;