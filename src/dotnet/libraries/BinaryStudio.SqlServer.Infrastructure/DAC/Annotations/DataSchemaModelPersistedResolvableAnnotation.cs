using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("PersistedResolvableAnnotation")]
    internal class DataSchemaModelPersistedResolvableAnnotation : DataSchemaModelAnnotation
        {
        [DataSchemaModelPropertyMapping] public Int32? Affinity { get;private set; }
        [DataSchemaModelPropertyMapping] public String TargetTypeStorage { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelPersistedResolvableAnnotation(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        }
    }
