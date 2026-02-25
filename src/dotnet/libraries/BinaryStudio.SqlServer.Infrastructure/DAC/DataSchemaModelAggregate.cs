using System;
using System.Collections.Generic;
using System.Text;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlAggregate")]
    internal class DataSchemaModelAggregate : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlFormat Format { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32 MaxByteSize { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String ClassName { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsInvariantToDuplicates { get; }=true;
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsInvariantToNulls { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsNullIfEmpty { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelAggregate(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            }
        #endregion
        }
    }
