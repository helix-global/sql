using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlAggregate")]
    internal class DataSchemaModelAggregate : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Int32 Format { get; } //TODO:: Should be enum!
        [DataSchemaModelPropertyMapping] public Int32 MaxByteSize { get; }
        [DataSchemaModelPropertyMapping] public String ClassName { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsInvariantToDuplicates { get; }=true;
        [DataSchemaModelPropertyMapping] public Boolean IsInvariantToNulls { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsNullIfEmpty { get; }

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
