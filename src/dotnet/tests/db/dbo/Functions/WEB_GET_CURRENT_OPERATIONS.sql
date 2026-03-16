CREATE function [dbo].[WEB_GET_CURRENT_OPERATIONS](@UserID int, @aModelCode nvarchar(50), @aOperationCode nvarchar(50))
returns @res table 
 (row_index int identity not null
 ,ID int
 ,State int
 ,OrderN nvarchar(50)
 ,SN nvarchar(50)
 ,Urgency int
 ,OperationCode nvarchar(50)
 ,OperationName nvarchar(250)
 ,PartNumber nvarchar(100)
 ,ModelName nvarchar(250)
 ,RevisionName nvarchar(250)
 ,DepartmentCode nvarchar(50)
 ,Qty int 
 ,WaitTime int 
 ,Operator nvarchar(50)
 ,SpecialRequirements ntext
 ,ToDo ntext
 ,P1 nvarchar(250)
 ,P2 nvarchar(250)
 ,P3 nvarchar(250)
 ,P4 nvarchar(250)
 ,P5 nvarchar(250)
 ,P6 nvarchar(250)
 ,P7 nvarchar(250)
 ,P8 nvarchar(250)
 ,P9 nvarchar(250)
 ,P10 nvarchar(250)
 ,InTraining nvarchar(3)
 ,OperatorInTraining nvarchar(200) 
 )
as 
begin
insert into @res  (ID,State,OrderN,SN,Urgency,PartNumber,ModelName,RevisionName,OperationCode,OperationName,DepartmentCode,Qty,WaitTime,Operator,SpecialRequirements,ToDo,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,InTraining,OperatorInTraining)
select 
A.ID
,A.S_S
,T1000240.NN 
,T1000241.SN 
,(dbo.PR_OPER_URGENCY3(A.ID,A.ORDERID,T1000241.ORDERID,T1000240.URGENCY,T1000870.URGENCY,A.URGENCY)) 
,T1000224.CODE
,T1000224.NAME as ModelName
,T1000315.NAME as RevName
,T1000242.CODE as OperCode
,T1000242.NAME as OperName
,(select F1.CODE from COM_DEPARTMENTS F1 with (nolock) where F1.ID = T1000240.DEPARTMENTID) as DEPCODE
,isnull(A.Q_IN,1)
,(dbo.PR_OPER_WAITTIME(A.ID,A.S_S,A.S_CDT)) as WAITTIME
,T1000461.FULLNAME as USERINPROGRESS_OL
,(isnull(T1000870.SPREQ,T1000240.SPREQ)) as SPREQ
,A.TODOTEXT
,(dbo.PR_DEVICE_PARAM_IN_LIST_STR4(A.DEVICEID,T1000224.TYPEID,1,A.ID,T1000242.MTID)) as P1
,(dbo.PR_DEVICE_PARAM_IN_LIST_STR4(A.DEVICEID,T1000224.TYPEID,2,A.ID,T1000242.MTID)) as P2
,(dbo.PR_DEVICE_PARAM_IN_LIST_STR4(A.DEVICEID,T1000224.TYPEID,3,A.ID,T1000242.MTID)) as P3
,(dbo.PR_DEVICE_PARAM_IN_LIST_STR4(A.DEVICEID,T1000224.TYPEID,4,A.ID,T1000242.MTID)) as P4
,(dbo.PR_DEVICE_PARAM_IN_LIST_STR4(A.DEVICEID,T1000224.TYPEID,5,A.ID,T1000242.MTID)) as P5
,(dbo.PR_DEVICE_PARAM_IN_LIST_STR4(A.DEVICEID,T1000224.TYPEID,6,A.ID,T1000242.MTID)) as P6
,(dbo.PR_DEVICE_PARAM_IN_LIST_STR4(A.DEVICEID,T1000224.TYPEID,7,A.ID,T1000242.MTID)) as P7
,(dbo.PR_DEVICE_PARAM_IN_LIST_STR4(A.DEVICEID,T1000224.TYPEID,8,A.ID,T1000242.MTID)) as P8
,(dbo.PR_DEVICE_PARAM_IN_LIST_STR4(A.DEVICEID,T1000224.TYPEID,9,A.ID,T1000242.MTID)) as P9
,(dbo.PR_DEVICE_PARAM_IN_LIST_STR4(A.DEVICEID,T1000224.TYPEID,10,A.ID,T1000242.MTID)) as P10
,dbo.COM_OPERATION_IS_IN_TRAINING(A.ID) as InTraining
,T1003486.FULLNAME as OperatorInTraining
from PR_OPERATION A with (nolock) 
left join PR_PRORDER T1000240 with (nolock) on T1000240.ID = A.ORDERID
left join PR_DEVICE T1000241 with (nolock) on T1000241.ID = A.DEVICEID
left join PR_OPERATIONS T1000242 with (nolock) on T1000242.ID = A.OPERTYPEID
left join PR_MODELS T1000224 with (nolock) on T1000224.ID = T1000241.MODELID
left join DEF_USERS T1000461 with (nolock) on T1000461.ID = A.USERINPROGRESS
left join PR_REVISION T1000315 with (nolock) on T1000315.ID = T1000241.REVID
left join PR_SUPPLY T1000870 with (nolock) on T1000870.ID = T1000241.SORDERID
left join PR_OPERATIONS_GR T1000341 with (nolock) on T1000341.ID = T1000242.OPERGRID
left join DEF_USERS T1003486 with (nolock) on T1003486.ID = A.USERINTRAINING
 where (dbo.PR_OPER_ACCESS2(@UserID,T1000242.OPERGRID,T1000240.DEPARTMENTID,T1000341.DEPARTMENTID,getdate()) = 1 or A.USERINPROGRESS = @UserID )
   and (A.ID in (select BB.ID from dbo.PR_IS_MY_CO_NEW(@UserID,GETDATE()) BB))
   and (@aModelCode = '%' or @aModelCode = '*' or T1000224.CODE like @aModelCode)
   and (@aOperationCode = '%' or @aOperationCode = '*' or T1000242.CODE like @aOperationCode)
 order by case A.S_S when 1000032 then 1 else 0 end, case when A.USERINPROGRESS = @UserID then 0 else 1 end, dbo.PR_OPER_URGENCY4(A.ORDERID,T1000241.ORDERID,T1000240.URGENCY,T1000870.URGENCY,A.URGENCY) desc,dbo.PR_OPER_EXP_DATE(T1000240.ORDERTYPE, T1000870.DD, T1000240.EXPDATE),case A.S_CR when @UserID then 1 else 0 end,T1000241.SN


return

end