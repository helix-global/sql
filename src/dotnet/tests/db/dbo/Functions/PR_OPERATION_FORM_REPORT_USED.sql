CREATE function [dbo].[PR_OPERATION_FORM_REPORT_USED] (@aMode int, @aOperFormID int, @aReportID int, @aUserID int )
returns int
as 
begin
/*
   проверяет что форма содержит ссылку на отчет 
   алгоритм в KB1118
*/

declare @aReportGID nvarchar(50)
declare @aLinkToParam int

select @aReportGID = A.GID
      ,@aLinkToParam = A.LINKTOPRMID
from PR_REPORTS A with (nolock)
where A.ID = @aReportID
      
  
/* 1. контрол с отчетом */

if exists (
		select ID 
		from (
		select ID
		,PART.value('(/ACParameters)[1]','nvarchar(max)') as INTERXML
		from (
		  select A.ID 
		  ,cast(FORMXML as xml).query('/Form/Item[@Type="sfiControl"][@Link=2]/ACParameters') as PART
			  from PR_OPERATIONS A with (nolock)
				where A.ID = @aOperFormID
				and cast(FORMXML as xml).exist('/Form/Item[@Type="sfiControl"][@Link=2]/ACParameters') =1 
		) M
		) M2
		where cast(INTERXML as xml).exist('/AC_BarcodePrint[@ReportGID=sql:variable("@aReportGID")]')=1
)
return 1		

/* 2. контрол ItemsReport в котором выбран отчет */

if exists (

		select ID 
		from (
		select ID
		,PART.value('(/EditorPopup)[1]','nvarchar(max)') as INTERXML
		from (
		  select A.ID 
		  ,cast(FORMXML as xml).query('/Form/Item[@Type="sfiItemReports"]/EditorPopup') as PART
			  from PR_OPERATIONS A with (nolock)
				where A.ID = @aOperFormID
				and cast(FORMXML as xml).exist('/Form/Item[@Type="sfiItemReports"]/EditorPopup') =1 
		) M
		) M2
		where cast(INTERXML as xml).exist('/ItemReportsDialogData/SelectedReport/Id[text()[1]=sql:variable("@aReportID")]')=1

)
return 1


/* 3. формы с параметром к которому привязан отчет */

if @aLinkToParam is not null
begin

  if exists (
	  select A.ID 
	  from PR_OPERATIONS A with (nolock)
	  where A.ID = @aOperFormID
		and cast(FORMXML as xml).exist('/Form/Item[@Type="sfiValue"][@Link=sql:variable("@aLinkToParam")]') =1 
  )
  return 1

end


return 0

end