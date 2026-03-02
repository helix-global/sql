using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("PersistedResolvableAnnotation")]
    internal class DataSchemaModelPersistedResolvableAnnotation : DataSchemaModelAnnotation,ISqlObjectReference
        {
        [PropertyMapping] public Int32? Affinity { get; }
        [PropertyMapping] public String TargetTypeStorage { get; }
        public SqlObjectIdentifier Reference { get { return SqlObjectIdentifier.Create(Name); }}

        #region ctor{DataSchemaModel}
        public DataSchemaModelPersistedResolvableAnnotation(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        }
    }
