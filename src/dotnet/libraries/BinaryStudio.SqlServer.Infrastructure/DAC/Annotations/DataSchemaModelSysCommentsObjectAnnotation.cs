using System;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SysCommentsObjectAnnotation")]
    internal class DataSchemaModelSysCommentsObjectAnnotation : DataSchemaModelAnnotation
        {
        [DataSchemaModelPropertyMapping] public Int32? CreateOffset { get; }
        [DataSchemaModelPropertyMapping] public Int32? Length { get; }
        [DataSchemaModelPropertyMapping] public Int32? StartLine { get; }
        [DataSchemaModelPropertyMapping] public Int32? StartColumn { get; }
        [DataSchemaModelPropertyMapping] public String HeaderContents { get; }
        [DataSchemaModelPropertyMapping] public String FooterContents { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelSysCommentsObjectAnnotation(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        }
    }
