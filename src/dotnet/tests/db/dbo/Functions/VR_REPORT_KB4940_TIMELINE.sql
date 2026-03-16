
CREATE function [dbo].[VR_REPORT_KB4940_TIMELINE](@now date, @mode int)
returns nvarchar(max) as 
begin

	/* KB4940 REPORT FOR MD TIMELINE TABVLE ROWS */
	/* CREATE 13.09.2024 EFIMOV */
	/* UPDATE 07.10.2024 EFIMOV KB5017 */

	/* 
	MODE
	1 = Customers
	2 = IPG Subsidiaries
	3 = Other
	*/

	/* TEST
	declare @mode int = 3
	declare @now date = '20240910' --getdate()
	*/
	
	
	declare @tomorrow date = dateadd(day,1,@now)		-- tomorrow
	declare @lastday date = dateadd(day,13,@tomorrow)	-- +2 weeks
	
	declare @approved int = 5130013		-- doc state
	declare @mdpending int = 5130012	-- doc state
	
	declare @report nvarchar(max) = ''	-- final report init
	
	/* !!!!!! monday first day of week !!!!!!! */
	--SET DATEFIRST 1
	
	/* TABLE FOR LOKKING DATES */
	declare @datetable table (DAYID int,FUULDATEWEEKDAY date, DATEWEEKDAY nvarchar(5),NAMEWEEKDAY nvarchar(10), NUMWEEKDAY int )
	insert into @datetable 
	select  
	    ROW_NUMBER() OVER(ORDER BY DDATE) as DAYID , 
		DDATE FUULDATEWEEKDAY,
		substring(dbo.COM_FORMAT_DATETIME(DDATE,1),1,5) DATEWEEKDAY,
		DATENAME(WEEKDAY , DDATE) NAMEWEEKDAY,
		DATEPART(WEEKDAY , DDATE) NUMWEEKDAY
	from 
		dbo.COM_DAY_PERIOD(@tomorrow, @lastday)
	
	
	
	/* FILL REQUESTS */
	declare @requestsstable table (ID int,LINK nvarchar(max), COMPANY nvarchar(max),  VISITOR_TYPE nvarchar(max), VISITOR_SUBTYPE nvarchar(max), VISIT_PERIOD nvarchar(max), DEPARTMENT nvarchar(max), VISITOR_NAMES nvarchar(max),ADATE date, DDATE date)
	if(@mode =1) -- CUSTOMERS
	begin
		insert into @requestsstable select * 
		from VR_REPORT_KB4940_TODAY(null, @mode)
		where ((ADATE between @tomorrow and @lastday) or (DDATE between @tomorrow and @lastday)) -- The start date or end date falls within the range you are looking for
	end
	else if (@mode = 2)  -- SUBSIDIARIES
	begin
		insert into @requestsstable select * 
		from VR_REPORT_KB4940_TODAY(null, @mode)
		where ((ADATE between @tomorrow and @lastday) or (DDATE between @tomorrow and @lastday)) -- The start date or end date falls within the range you are looking for
	end
	else  -- (@mode = 3)	-- OTHER
	begin
		insert into @requestsstable select * 
		from VR_REPORT_KB4940_TODAY(null, @mode)
		where ((ADATE between @tomorrow and @lastday) or (DDATE between @tomorrow and @lastday)) -- The start date or end date falls within the range you are looking for
	end
	
	
	
	
	
	/* RESULT PIVOT TABLE FOR 14 DAYS */
	declare @prepivottable table (ID int, LINK nvarchar(max), COMPANY nvarchar(max), VISITOR_TYPE nvarchar(max), VISITOR_SUBTYPE nvarchar(max), VISIT_PERIOD nvarchar(max), DEPARTMENT nvarchar(max), VISITOR_NAMES nvarchar(max),  ADATE date, DDATE date,DAYID int,FUULDATEWEEKDAY date, DATEWEEKDAY nvarchar(5),NAMEWEEKDAY nvarchar(10), NUMWEEKDAY int)
	insert into @prepivottable
	select T.*, D.*  
	from @datetable D
		left join @requestsstable T on D.FUULDATEWEEKDAY between T.ADATE and T.DDATE
	
	
	declare @restable table (ID int, LINK nvarchar(max), COMPANY nvarchar(max), VISITOR_TYPE nvarchar(max), VISITOR_SUBTYPE nvarchar(max), DEPARTMENT nvarchar(max),  [1] nvarchar(max),[2] nvarchar(max), [3] nvarchar(max), [4] nvarchar(max), [5] nvarchar(max), [6] nvarchar(max), [7] nvarchar(max), [8] nvarchar(max), [9] nvarchar(max), [10] nvarchar(max), [11] nvarchar(max), [12] nvarchar(max), [13] nvarchar(max), [14] nvarchar(max))
	insert into @restable
	SELECT 
		ID, LINK,
		COMPANY, VISITOR_TYPE, VISITOR_SUBTYPE, DEPARTMENT,
		[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14]
	FROM
	(
	    SELECT P.ID, P.COMPANY,P.DEPARTMENT, P.VISITOR_NAMES, P.VISITOR_TYPE, P.VISITOR_SUBTYPE, P.DAYID, P.LINK
	    FROM @prepivottable P 
	) p
	PIVOT
	(
	    MAX(VISITOR_NAMES)
	    FOR DAYID IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14])
	 
	) AS pvt
	where ID is not null
	ORDER BY pvt.COMPANY
	
	
	
	/*test*/
	--select p.* from @prepivottable p
	--select VR.S_S,  r.* from @restable  r 
	--left join VR_REQUEST VR with (nolock) on VR.ID = r.ID
	--order by r.COMPANY
	/*test*/
	
	-- if has visitor requests then
	if exists (select * from @requestsstable)
	begin
	
	
		-- start trable
		--set @report = @report + '<table>'
		--table header
		set @report = @report + '<tr>
									<th class="customers">' + case when @mode = 1 then 'Customers' when @mode = 2 then 'IPG Subsidiaries' else 'Other' end + '</th>	
									<th class="visitortype">Visitor type</th>
									<th class="department">Department</th>
		
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,0, @tomorrow),1),1,5)  + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,0, @tomorrow)) + '</th>
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,1, @tomorrow),1),1,5)  + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,1, @tomorrow)) + '</th>
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,2, @tomorrow),1),1,5)  + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,2, @tomorrow)) + '</th>
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,3, @tomorrow),1),1,5)  + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,3, @tomorrow)) + '</th>
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,4, @tomorrow),1),1,5)  + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,4, @tomorrow)) + '</th>
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,5, @tomorrow),1),1,5)  + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,5, @tomorrow)) + '</th>
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,6, @tomorrow),1),1,5)  + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,6, @tomorrow)) + '</th>
		
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,7, @tomorrow),1),1,5)  + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,7, @tomorrow)) + '</th>
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,8, @tomorrow),1),1,5)  + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,8, @tomorrow)) + '</th>
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,9, @tomorrow),1),1,5)  + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,9, @tomorrow)) + '</th>
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,10, @tomorrow),1),1,5) + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,10, @tomorrow)) + '</th>
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,11, @tomorrow),1),1,5) + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,11, @tomorrow)) + '</th>
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,12, @tomorrow),1),1,5) + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,12, @tomorrow)) + '</th>
									<th class="day">' + substring(dbo.COM_FORMAT_DATETIME(DATEADD(day,13, @tomorrow),1),1,5) + ',<br>' + DATENAME(WEEKDAY , DATEADD(day,13, @tomorrow)) + '</th>
								</tr>
		'			
		-- row for table
		select
			@report = @report + '
			
			<tr>
				<td><a href="' + r.LINK + '">' + r.COMPANY + '</a></td>
				<td>' + 
					case 
						when @mode = 1 then r.VISITOR_SUBTYPE 
						when @mode = 2 then r.VISITOR_TYPE 
						when @mode = 3 then 
							case when VR.VISITORTYPE = 10 then ISNULL(r.VISITOR_SUBTYPE, r.VISITOR_TYPE) else r.VISITOR_TYPE end
					end
				+ '</td>
				<td>' + r.DEPARTMENT +  '</td>
		
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,0,  @tomorrow)) in ('6','7') AND r.[1]  IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[1]  IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[1]  IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[1],'')  + '</td>
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,1,  @tomorrow)) in ('6','7') AND r.[2]  IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[2]  IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[2]  IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[2],'')  + '</td>
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,2,  @tomorrow)) in ('6','7') AND r.[3]  IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[3]  IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[3]  IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[3],'')  + '</td>
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,3,  @tomorrow)) in ('6','7') AND r.[4]  IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[4]  IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[4]  IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[4],'')  + '</td>
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,4,  @tomorrow)) in ('6','7') AND r.[5]  IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[5]  IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[5]  IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[5],'')  + '</td>
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,5,  @tomorrow)) in ('6','7') AND r.[6]  IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[5]  IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[6]  IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[6],'')  + '</td>
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,6,  @tomorrow)) in ('6','7') AND r.[7]  IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[7]  IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[7]  IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[7],'')  + '</td>
		
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,7,  @tomorrow)) in ('6','7') AND r.[8]  IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[8]  IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[8]  IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[8],'')  + '</td>
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,8,  @tomorrow)) in ('6','7') AND r.[9]  IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[9]  IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[9]  IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[9],'')  + '</td>
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,9,  @tomorrow)) in ('6','7') AND r.[10] IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[10] IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[10] IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[10],'') + '</td>
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,10, @tomorrow)) in ('6','7') AND r.[11] IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[11] IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[11] IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[11],'') + '</td>
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,11, @tomorrow)) in ('6','7') AND r.[12] IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[12] IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[12] IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[12],'') + '</td>
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,12, @tomorrow)) in ('6','7') AND r.[13] IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[13] IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[13] IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[13],'') + '</td>
				<td' + case when DATEPART(WEEKDAY , DATEADD(day,13, @tomorrow)) in ('6','7') AND r.[14] IS NULL then ' class="weekend"' when VR.S_S = @approved and r.[14] IS NOT NULL then ' class="approved"' when VR.S_S = @mdpending and r.[14] IS NOT NULL then ' class="mdpending"' else '' end + '>' + isnull(r.[14],'') + '</td>
			</tr>
		'
		
		from @restable r
		left join VR_REQUEST VR with (nolock) on VR.ID = r.ID  -- for request state
		-- finish table
		--set @report = @report + '</table>'
	end	
	
	
	return @report
 end