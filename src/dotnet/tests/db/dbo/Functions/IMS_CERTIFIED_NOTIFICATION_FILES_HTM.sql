CREATE function [dbo].IMS_CERTIFIED_NOTIFICATION_FILES_HTM(@aTrID int, @aMode int)
returns nvarchar(max) as 
begin

  declare @res nvarchar(max) = ''
  
              /*
  select @res = @res + '<a href="cid:'+replace(cast(A.GID as nvarchar(50)),'-','')+'@1">'+A.FILENAME+'</a>'
  from IMS_TRAINING_FILES A with (nolock) 
  where A.VNESHID = @aTrID
  */
  
  /*ссылки на attachements по тексту письма не заработали, поэтому сделана ссылка на документ PDB  */
  set @res = '<a href="a2l:\\Link=doc.ims_training.'+ltrim(rtrim(str(@aTrID)))+'">Open in PDB</a>'
  
   
  return isnull(@res,'') 

end