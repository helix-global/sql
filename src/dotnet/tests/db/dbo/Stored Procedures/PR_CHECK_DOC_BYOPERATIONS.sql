CREATE procedure [dbo].[PR_CHECK_DOC_BYOPERATIONS] @OperID int,@UserID int
as 
SET nocount on

/* если есть параметры, объявленные как Declaration Of Conformity , то создает (если нет) записи в PR_DOC_BYOPERATIONS и привязывает файлы */

if exists (select A.ID 
             from PR_OPERATION_PARAMS A with (nolock) 
             left join PR_MODELTYPE_PARAMS F with (nolock) on F.ID = A.PARAMID
            where A.OPERID = @OperID
              and A.PARAMID in (select B.PARAMID from PR_DOC_SETTINGS B with (nolock))
              and F.DATATYPE = 7
           )
begin


  insert into PR_DOC_BYOPERATIONS (GID,S_CR,S_CDT,CODE,OPERID,PARAMID)
  select newid(),@UserID,getdate(),dbo.PR_NEW_G75_CODE(),A.OPERID,A.PARAMID
  from PR_OPERATION_PARAMS A with (nolock) 
  left join PR_MODELTYPE_PARAMS F with (nolock) on F.ID = A.PARAMID
 where A.OPERID = @OperID
   and A.PARAMID in (select B.PARAMID from PR_DOC_SETTINGS B with (nolock))
   and F.DATATYPE = 7
   and not exists (select L.ID from PR_DOC_BYOPERATIONS L with (nolock) where L.OPERID = A.OPERID and L.PARAMID = A.PARAMID)

   update PR_DOC_BYOPERATIONS 
      set FILEID = (select top 1 J.ID 
                      from PR_OPERATION_FILES J with (nolock) 
                     where J.OPERATIONID = @OperID 
                       and J.FILENAME = (select cast(K.PVALUE as nvarchar) from PR_OPERATION_PARAMS K with (nolock) 
                                          where K.OPERID = @OperID
                                            and K.PARAMID = PR_DOC_BYOPERATIONS.PARAMID
                                         )
                       order by J.ID desc
                    )
   where OPERID = @OperID


end              


set nocount off