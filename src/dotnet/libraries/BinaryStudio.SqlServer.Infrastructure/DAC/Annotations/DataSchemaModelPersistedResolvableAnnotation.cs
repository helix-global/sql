using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("PersistedResolvableAnnotation")]
    internal class DataSchemaModelPersistedResolvableAnnotation : DataSchemaModelAnnotation
        {
        [DataSchemaModelPropertyMapping] public Int32? Affinity { get; }
        [DataSchemaModelPropertyMapping] public String TargetTypeStorage { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelPersistedResolvableAnnotation(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        }
    }
