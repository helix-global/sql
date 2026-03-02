using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlAggregate")]
    internal class DataSchemaModelAggregate : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public SqlFormat Format { get; }
        [PropertyMapping][UsedImplicitly] public Int32 MaxByteSize { get; }
        [PropertyMapping][UsedImplicitly] public String ClassName { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsInvariantToDuplicates { get; }=true;
        [PropertyMapping][UsedImplicitly] public Boolean IsInvariantToNulls { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsNullIfEmpty { get; }
        [Relationship("0..1")][UsedImplicitly] public SqlObjectReference Assembly { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Schema   { get; }
        [Relationship("1..1")][UsedImplicitly] public IDataSchemaModelTypeSpecifier ReturnType { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<DataSchemaModelSubroutineParameter> Parameters { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelAggregate(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            return;
            }
        #endregion
        }
    }
