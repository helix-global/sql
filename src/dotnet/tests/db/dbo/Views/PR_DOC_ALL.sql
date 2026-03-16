CREATE view PR_DOC_ALL as
select A.ID,A.GID,A.S_CR,A.S_MR,A.S_CDT,A.S_MDT,A.NAME,A.CODE,1 as DOCTYPE,null as DEVICEID,A.DESCRIPTION 
from SW_TOOLS A 
where A.GROUPID in (select SWGROUP from PR_DOC_SETTINGS with (nolock))
union all 
select A.ID,A.GID,A.S_CR,A.S_MR,A.S_CDT,A.S_MDT,B.FILENAME,A.CODE,2 as DOCTYPE,C.DEVICEID,B.FILEDESC
from PR_DOC_BYOPERATIONS A with (nolock)
left join PR_OPERATION C with (nolock) on C.ID = A.OPERID
left join PR_OPERATION_FILES B with (nolock) on B.ID = A.FILEID
where A.FILEID is not null