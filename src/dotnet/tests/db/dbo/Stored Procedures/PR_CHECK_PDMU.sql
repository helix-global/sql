CREATE procedure [dbo].[PR_CHECK_PDMU] @aRevisionID int, @aMapID int
as 
set nocount on

/*
проверка что в предопределенных материалах нет ссылок на не использующиеся в актуальной карте операций
@aRevisionID is not null - запуск по ревизии
@aMapID is not null - запуск по карте
*/

if exists (
  select B.ID
  from PR_REVISION  A with (nolock)
  left join PR_REV_PDMU B with (nolock) on B.REVID = A.ID
  where (A.ID = @aRevisionID or A.MAPID = @aMapID)
    and B.ID is not null
    and A.MAPID is not null
    and not exists (select J.ID from PR_MAP_OPER J with (nolock) where J.MAPID = A.MAPID and J.OPERID = B.OPERID)
       )
       begin
       
          
          if @aRevisionID is not null
            print '#WRevision contains predefined materials linked to operation forms not used in the production map'
          else if @aRevisionID is null and @aMapID is not null
            print '#WSome revision contains predefined materials linked to operation forms not used in the production map'
       
       
       end
             


set nocount off