using System;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SysCommentsObjectAnnotation")]
    internal class DataSchemaModelSysCommentsObjectAnnotation : DataSchemaModelAnnotation
        {
        [PropertyMapping] public Int32? CreateOffset { get; }
        [PropertyMapping] public Int32? Length { get; }
        [PropertyMapping] public Int32? StartLine { get; }
        [PropertyMapping] public Int32? StartColumn { get; }
        [PropertyMapping] public String HeaderContents { get; }
        [PropertyMapping] public String FooterContents { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelSysCommentsObjectAnnotation(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        }
    }
