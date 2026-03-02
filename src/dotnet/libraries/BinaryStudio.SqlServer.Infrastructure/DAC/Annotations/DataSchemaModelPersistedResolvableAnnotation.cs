using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("PersistedResolvableAnnotation")]
    internal class DataSchemaModelPersistedResolvableAnnotation : DataSchemaModelAnnotation,ISqlObjectReference
        {
        [DataSchemaModelPropertyMapping] public Int32? Affinity { get; }
        [DataSchemaModelPropertyMapping] public String TargetTypeStorage { get; }
        public SqlObjectIdentifier Reference { get { return SqlObjectIdentifier.Create(Name); }}

        #region ctor{DataSchemaModel}
        public DataSchemaModelPersistedResolvableAnnotation(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        }
    }
