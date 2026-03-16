CREATE view [dbo].[SM_WORKORDER_HISTORY]
AS
	select W.ID
			, W.GID
			, W.S_CR
			, W.S_CDT
			, W.S_MR
			, W.S_MDT
			, W.S_S
			, W.SCASEID
			, C.DD as OPEN_DATE
			, W.SORDERID
			, O.DD as SERVICE_DATE
			, W.EMPLID
			, R.OPERTIME
			, W.DEVICEID
			, dbo.SM_SERVICE_TASKS_NUMERS(W.ID) as SM_SERVICE_TASKS_NUMERS
			, C.ND as SCASE_NUMBER
			, O.NN as SERVORDER_NUMBER
			, E.NAME as ENGENEER_NAME
			, D.SN
			, M.NAME as MODEL_NAME
			, CUST.NAME as CUST_NAME
			, (select count(S.ID) from SM_WORKORDER_TASKS S with (nolock) where S.VNESHID=W.ID) as TASKSCOUNT
		from SM_WORKORDER W with (nolock)
			left join SM_SERVICECASE C with (nolock) on W.SCASEID=C.ID
			left join PR_PRORDER O with (nolock) on W.SORDERID=O.ID
			left join (select R.OPERTIME, case when R.RMA_TYPE = 1 then 'INT-'
												when R.RMA_TYPE = 2 then 'RMA-'
												when R.RMA_TYPE = 3 then 'SC-'
												when R.RMA_TYPE = 4 then 'SCAFF-'
												else null end + isnull(R.RMA,'') as SERVNUMBER 
							from FC_REPORT R with (nolock)) R on O.NN=R.SERVNUMBER
			left join COM_EMPLOYEE E on W.EMPLID=E.ID
			left join PR_DEVICE D on W.DEVICEID=D.ID
			left join PR_MODELS M on D.MODELID=M.ID
			left join COM_CUSTOMER CUST on O.CUSTOMERID=CUST.ID