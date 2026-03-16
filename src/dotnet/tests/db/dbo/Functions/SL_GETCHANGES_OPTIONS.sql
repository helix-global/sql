CREATE function [dbo].[SL_GETCHANGES_OPTIONS] ()
returns @res table (ID int, S_S int )
as 
begin

/*
OID Name
1000187 New Option
1000188 Changed

*/
  declare @res2 table (ID int, S_S int)

  insert into @res2(ID,S_S)
  select A.ID, 1000187
  from SL_OPTIONS_V A 
  where not exists (select B.ID from SL_OPTIONS B where B.ID = A.ID)
    and A.S_S = 4180002/*approved*/
  
  insert into @res2(ID,S_S)
  select A.ID, 1000188 
  from SL_OPTIONS_V A 
  left join SL_OPTIONS B on B.ID = A.ID
  where B.ID is not null
    and A.S_S = 4180002/*approved*/
    and (A.CODE <> B.CODE
         or A.DEPARTMENTID <> B.DEPARTMENTID
         or isnull(A.NAME,'') <> isnull(B.NAME,'')
         or isnull(A.GROUPID,-1) <> isnull(B.GROUPID,-1)
         or isnull(A.GROUPNAME,'') <> isnull(B.GROUPNAME,'')
         or datalength(A.OPICT) <> datalength(B.OPICT)
         or A.TYPEID <> B.TYPEID
         or isnull(A.TAGS,'') <> isnull(B.TAGS,'')
         or isnull(A.PRTYPE,-1) <> isnull(B.PRTYPE,-1)
         or isnull(A.CMP_OUT,'') <> isnull(B.CMP_OUT,'')
         or isnull(A.CMP_REQ,'') <> isnull(B.CMP_REQ,'')
         or isnull(A.SPEC,'') <> isnull(B.SPEC,'')
         or isnull(A.CUSTOM4GROUP,-1) <> isnull(B.CUSTOM4GROUP,-1)
         or isnull(A.CUSTOM4ID,-1) <> isnull(B.CUSTOM4ID,-1)
         or isnull(A.CMP_BLOCK,'') <> isnull(B.CMP_BLOCK,'')
         or B.S_S = 1000148  /*deprecated*/  /*KB1963*/
    )  
    
  /*files*/
  insert into @res2(ID,S_S)
  select distinct A.OPTID, 1000188
  from SL_OPTION_FILES_V A 
  left join SL_OPTIONS AA on AA.ID = A.OPTID
  left join SL_OPTION_FILES B with (nolock) on B.ID = A.ID
  where AA.S_S = 4180002/*approved*/
     and (B.ID is null
          or isnull(B.OPTID,-1) <> isnull(A.OPTID,-1)
          or isnull(B.FILESIZE,-1) <> isnull(A.FILESIZE,-1)
          or isnull(B.FILENAME,'') <> isnull(A.FILENAME,'')
          or isnull(B.FILESOURCEID,-1) <> isnull(A.FILESOURCEID,-1)
          )

  insert into @res2(ID,S_S)
  select distinct A.OPTID, 1000188 
  from SL_OPTION_FILES A 
  left join SL_OPTIONS AA on AA.ID = A.OPTID
  left join SL_OPTION_FILES_V B with (nolock) on B.ID = A.ID
  where AA.S_S = 4180002/*approved*/
    and B.ID is null    
    

  insert into @res (ID,S_S) select distinct ID,S_S from @res2
  where not exists (select J.ID from SL_REJECTIONS J with (nolock) where J.OPTIONID = "@res2".ID)

  return

end