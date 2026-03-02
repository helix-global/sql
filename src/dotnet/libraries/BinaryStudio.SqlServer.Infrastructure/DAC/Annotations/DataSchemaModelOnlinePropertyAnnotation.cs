using System;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("OnlinePropertyAnnotation")]
    internal class DataSchemaModelOnlinePropertyAnnotation : DataSchemaModelAnnotation
        {
        [PropertyMapping] public Object Value { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelOnlinePropertyAnnotation(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        }
    }
