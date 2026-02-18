using System;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("OnlinePropertyAnnotation")]
    internal class DataSchemaModelOnlinePropertyAnnotation : DataSchemaModelAnnotation
        {
        [DataSchemaModelPropertyMapping] public Object Value { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelOnlinePropertyAnnotation(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        }
    }
