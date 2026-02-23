using System;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SysCommentsObjectAnnotation")]
    internal class DataSchemaModelSysCommentsObjectAnnotation : DataSchemaModelAnnotation
        {
        [DataSchemaModelPropertyMapping] public Int32? CreateOffset { get;private set; }
        [DataSchemaModelPropertyMapping] public Int32? Length { get;private set; }
        [DataSchemaModelPropertyMapping] public Int32? StartLine { get;private set; }
        [DataSchemaModelPropertyMapping] public Int32? StartColumn { get;private set; }
        [DataSchemaModelPropertyMapping] public String HeaderContents { get;private set; }
        [DataSchemaModelPropertyMapping] public String FooterContents { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelSysCommentsObjectAnnotation(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        }
    }
