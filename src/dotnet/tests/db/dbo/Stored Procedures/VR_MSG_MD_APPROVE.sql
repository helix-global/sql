
CREATE PROCEDURE [dbo].[VR_MSG_MD_APPROVE] 
  @aUserID int
AS
BEGIN



/* KB4905 09.08.2024 Efimov - p.11 send all notification about approve required by MD to once a day */
/*        09.12.2024 Efimov - Fix ENUM translate to English */ 
/* KB5155 11.12.2024 Efimov - send report ONLY if report body is NOT empty (has records to aprove) */


declare @REPORTTIME time = '06:00'	-- Report create and send time
declare @DELIVERYTYPE int = 44089 /* non-existent delivery type - for delivery to VRMD group user */
declare @DELIVERYDEPID int = -1

declare @nowDateTime datetime = getdate()
declare @nowTIME time =  cast(@nowDateTime as time)
declare @nowDATE date =  cast(@nowDateTime as date)

declare @subj nvarchar(1000) = 'Visitor requests awaiting MD approval'
declare @body nvarchar(max) = ''

--select * from MSG_LAST_DELIVERY_DATES where  DELIVERYTYPE = @DELIVERYTYPE
--delete from MSG_LAST_DELIVERY_DATES where  DELIVERYTYPE = 44089

-- ############## ПРОВЕРКА НА РАБОЧИЕ ДНИ НЕДЕЛИ #########################################
SET DATEFIRST 1

if (DATEPART(dw,GETDATE()) in (6,7)) /* mon - fr */
begin
   print 'exit (need report only at friday)'
   set nocount off
   return
end

-- ################# ПРОВЕРКА НА УЖЕ ОТПРАВЛЕННЫЙ ОТЧЕТ ###########################################
 if exists (select G.DD from MSG_LAST_DELIVERY_DATES G where G.DELIVERYTYPE = @DELIVERYTYPE and G.DEPID = @DELIVERYDEPID and G.DD = cast(@nowDATE as date))
 begin
   print 'exit (today already done)'
   set nocount off
   return
 end

-- ################# ПРОВЕРКА НАСТУПИЛО ЛИ ВРЕМЯ ДЛЯ ОТПРАВКИ НОВОГО ОТЧЕТ ########################################### 

 print 'report send time: ' + CAST(@REPORTTIME as varchar(5))
 print 'current time    : ' + cast(@nowTime as varchar(5))

 if  @nowDateTime <= (CAST(@nowDATE as datetime) + CAST(@REPORTTIME as datetime)) 
 begin
	print 'exit (it is not time to send)'
	set nocount off
    return
 end
	

print CHAR(13) + 'TIME TO SEND REPORT !!!' + CHAR(13)


/* REPORT => */

select 
	@body = 
	'
	<html>
		<head>
			<style>
				table.blueTable {
				  font: 1.1em Calibri;
				  border: 1px solid #9CA3B4;
				  background-color: #FFFFFF;
				  text-align: left;
				  border-collapse: collapse;
				}
				table.blueTable td, table.blueTable th {
				  border: 1px solid #AAAAAA;
				  padding: 3px 2px;
				}
				table.blueTable tbody td {
				  font-size: 13px;
				}
				table.blueTable thead {
				  background: #919191;
				  background: -moz-linear-gradient(top, #acacac 0%, #9c9c9c 66%, #919191 100%);
				  background: -webkit-linear-gradient(top, #acacac 0%, #9c9c9c 66%, #919191 100%);
				  background: linear-gradient(to bottom, #acacac 0%, #9c9c9c 66%, #919191 100%);
				}
				table.blueTable thead th {
				  font-size: 15px;
				  font-weight: bold;
				  color: #FFFFFF;
				  border-left: 2px solid #D0E4F5;
				}
				table.blueTable thead th:first-child {
				  border-left: none;
				}
				
				table.blueTable tfoot td {
				  font-size: 14px;
				}
				table.blueTable tfoot .links {
				  text-align: right;
				}
				table.blueTable tfoot .links a{
				  display: inline-block;
				  background: #1C6EA4;
				  color: #FFFFFF;
				  padding: 2px 8px;
				  border-radius: 5px;
				}
			</style>
		</head>
	<body>
	' +

	' Hello,<br>
	Following requests are awaiting MD approval:<br>
	<a href="a2l:\\Link=doc.vr_request">MD-Pending approval list</a><br><br> 
	' +


	'<table class="blueTable">' +
	'<thead>' +
	'<th>Request No.</th>
	 <th>Type</th>
	 <th>Visitor sub-type</th>
	 <th>Department</th>
	 <th>Company\Subsidiary</th>
	 <th>Begin</th>
	 <th>End</th>
	 <th>Visitors</th>' +
	 '</thead>'
	 +
	 (
		select dbo.GROUP_CONCAT_D(
		    '<tr>' +
			'<td> <a href="a2l:\\Link=doc.vr_request.'+ CONVERT(nvarchar(10), R.ID) + '">' + isnull(R.ND,'') + '</a> </td>' +
			'<td>' + isnull(dbo.COM_LANG_EN(ENUMT.NAME),'') + '</td>' +
			'<td>' + isnull(dbo.COM_LANG_EN(ENUMTS.NAME),'') + '</td>' +
			'<td>' + isnull(D.NAME,'') + '</td>' +
			'<td>' + isnull(dbo.VR_GET_ALL_COMPANIES(R.ID),'') + '</td>' +
			'<td>' + isnull(dbo.COM_FORMAT_DATETIME( cast(convert(date,R.ADATE) as datetime) + cast(convert(time,R.VT_FROM) as datetime) ,1 ),'') + '</td>' +
			'<td>' + isnull(dbo.COM_FORMAT_DATETIME( cast(convert(date,R.DDATE) as datetime) + cast(convert(time,R.VT_TO) as datetime) ,1 ),'') + '</td>' +
			'<td >' + isnull(dbo.VR_GET_REQUEST_ALL_VISITORS(R.ID),'') + '</td>' +
			'</tr>'
			,'')
		
		from VR_REQUEST R with (nolock)
		left join COM_DEPARTMENTS D with (nolock) on R.DEPID = D.ID
		
		left join DEF_ENUMERATION ENUM with(nolock) on ENUM.LABEL ='vr_visitor_type' 
		left join DEF_ENUMERATION_T ENUMT with(nolock) on ENUMT.ENUMOID = ENUM.OID and ENUMT.CODE = R.VISITORTYPE
		
		left join DEF_ENUMERATION ENUMS with(nolock) on ENUMS.LABEL ='vr_visitor_subtype' 
		left join DEF_ENUMERATION_T ENUMTS with(nolock) on ENUMTS.ENUMOID = ENUMS.OID and ENUMTS.CODE = R.VISITORSUBTYPE
		
		where 
			R.S_S = 5130012 /* MD approve required */
	 ) +
	 '</table>
	 <br><br>Please, do not answer this e-mail.<br>Production Database
	 </body>
	 </html>
	 '

	--select @subj
	
	--exec MSG_SEND_TOUSER 26052, 26052, @subj, @body 


	-- send report ONLY if report body is NOT empty (has records to aprove) KB5155
    if(ISNULL(@body,'') != '')
    begin 
		exec  MSG_SEND_TOGROUP @aUserID, 44089 /*VRMD*/, @subj, @body
	end

   




/* <= REPORT */



-- ############## ПОМЕЧАЕМ ЧТО СЕГОДНЯ ПИСЬМО ОТПРАВЛЕНО #########################################
insert into MSG_LAST_DELIVERY_DATES (DELIVERYTYPE,DEPID,DD) values (@DELIVERYTYPE,@DELIVERYDEPID, @nowDate)
print 'Report date is inserted in [MSG_LAST_DELIVERY_DATES].'


END