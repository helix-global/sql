CREATE function [dbo].[SL_GETCHANGES_MODELS] ()
returns @res table (ID int, S_S int )
as 
begin

  /* 
1000164 Changed
     1000165    Approved  ???
1000166 New Product
*/
  declare @res2 table (ID int, S_S int)
    
  insert into @res2(ID,S_S)
  select A.ID, 1000166 
  from SL_MODELS_V A 
  where not exists (select B.ID from SL_MODELS B where B.ID = A.ID)
    and A.S_S <> 1000003 /*deprecated*/
  
  insert into @res2(ID,S_S)
  select A.ID, 1000164 
  from SL_MODELS_V A 
  left join SL_MODELS B with (nolock) on B.ID = A.ID
  where B.ID is not null
    and A.S_S <> 1000003 /*deprecated*/
    and (A.CODE <> B.CODE
         or A.DEPID <> B.DEPID
         or isnull(A.NAME,'') <> isnull(B.NAME,'')
         or isnull(A.DESCSTR,'') <> isnull(B.DESCSTR,'')
         or isnull(datalength(A.MPICT),-1) <> isnull(datalength(B.MPICT),-1)
         or A.TYPEID <> B.TYPEID
         or isnull(A.PRTYPE,-1) <> isnull(B.PRTYPE,-1)
         or isnull(A.SPEC,'') <> isnull(B.SPEC,'')
         or isnull(A.TAGS,'') <> isnull(B.TAGS,'')
         or isnull(A.CUSTOM4GROUP,-1) <> isnull(B.CUSTOM4GROUP,-1)
         or isnull(A.CUSTOM4ID,-1) <> isnull(B.CUSTOM4ID,-1)
         or B.S_S = 1000003
         /*or A.ID = 8138*/
    )  

  /*applicable options*/  
  insert into @res2(ID,S_S)
  select distinct A.MODELID, 1000164 
  from SL_MODEL_OPTIONS_V A 
  left join SL_MODELS AA on AA.ID = A.MODELID
  left join SL_MODEL_OPTIONS B with (nolock) on B.ID = A.ID
  where AA.S_S <> 1000003 /*deprecated*/
     and (B.ID is null
          or isnull(B.OPTIONID,-1) <> isnull(A.OPTIONID,-1)
          or isnull(B.MODELID,-1) <> isnull(A.MODELID,-1)
          or isnull(B.PREDEFINEDOPT,-1) <> isnull(A.PREDEFINEDOPT,-1)
          or isnull(B.CUSTOM4ID,-1) <> isnull(A.CUSTOM4ID,-1)
          or isnull(B.CUSTOM4GROUP,-1) <> isnull(A.CUSTOM4GROUP,-1)
          or isnull(B.OVERPTYPE,-1) <> isnull(A.OVERPTYPE,-1)
          or isnull(B.CMP_OUT2,'') <> isnull(A.CMP_OUT2,'')
          or isnull(B.CMP_OUT2_OVERRIDE,0) <> isnull(A.CMP_OUT2_OVERRIDE,0)
          or isnull(B.CMP_REQ,'') <> isnull(A.CMP_REQ,'')
          or isnull(B.CMP_REQ_OVERRIDE,0) <> isnull(A.CMP_REQ_OVERRIDE,0)
          or isnull(B.CMP_BLOCK,'') <> isnull(A.CMP_BLOCK,'')
          or isnull(B.CMP_BLOCK_OVERRIDE,0) <> isnull(A.CMP_BLOCK_OVERRIDE,0)
          )

  insert into @res2(ID,S_S)
  select distinct A.MODELID, 1000164 
  from SL_MODEL_OPTIONS A 
  left join SL_MODELS AA on AA.ID = A.MODELID
  left join SL_MODEL_OPTIONS_V B with (nolock) on B.ID = A.ID
  where AA.S_S <> 1000003 /*deprecated*/
    and B.ID is null

  /*required option groups*/
  insert into @res2(ID,S_S)
  select distinct A.MODELID, 1000164 
  from SL_REQ_OPTIONS_V A 
  left join SL_MODELS AA on AA.ID = A.MODELID
  left join SL_REQ_OPTIONS B with (nolock) on B.ID = A.ID
  where AA.S_S <> 1000003 /*deprecated*/
     and (B.ID is null
          or isnull(B.MODELID,-1) <> isnull(A.MODELID,-1)
          or isnull(B.OPTIONGRID,-1) <> isnull(A.OPTIONGRID,-1)
          or isnull(B.OPTIONGRID2,-1) <> isnull(A.OPTIONGRID2,-1)
          or isnull(B.OPTIONGRID3,-1) <> isnull(A.OPTIONGRID3,-1)
          )

  insert into @res2(ID,S_S)
  select distinct A.MODELID, 1000164 
  from SL_REQ_OPTIONS A 
  left join SL_MODELS AA on AA.ID = A.MODELID
  left join SL_REQ_OPTIONS_V B with (nolock) on B.ID = A.ID
  where AA.S_S <> 1000003 /*deprecated*/
    and B.ID is null

  /*files*/
  insert into @res2(ID,S_S)
  select distinct A.MODELID, 1000164 
  from SL_MODEL_FILES_V A 
  left join SL_MODELS AA on AA.ID = A.MODELID
  left join SL_MODEL_FILES B with (nolock) on B.ID = A.ID
  where AA.S_S <> 1000003 /*deprecated*/
     and (B.ID is null
          or isnull(B.MODELID,-1) <> isnull(A.MODELID,-1)
          or isnull(B.FILESIZE,-1) <> isnull(A.FILESIZE,-1)
          or isnull(B.FILENAME,'') <> isnull(A.FILENAME,'')
          or isnull(B.FILESOURCEID,-1) <> isnull(A.FILESOURCEID,-1)
          )

  insert into @res2(ID,S_S)
  select distinct A.MODELID, 1000164 
  from SL_MODEL_FILES A 
  left join SL_MODELS AA on AA.ID = A.MODELID
  left join SL_MODEL_FILES_V B with (nolock) on B.ID = A.ID
  where AA.S_S <> 1000003 /*deprecated*/
    and B.ID is null

  insert into @res (ID,S_S) 
  select distinct ID,S_S from @res2
  where not exists (select J.ID from SL_REJECTIONS J with (nolock) where J.PRODUCTID = "@res2".ID)

  
    
  return

end