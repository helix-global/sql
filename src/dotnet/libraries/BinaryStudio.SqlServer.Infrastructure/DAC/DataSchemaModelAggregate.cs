using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlAggregate")]
    [DataSchemaModelSupportedRelationship(nameof(Assembly))]
    [DataSchemaModelSupportedRelationship(nameof(Schema))]
    [DataSchemaModelSupportedRelationship(nameof(ReturnType))]
    [DataSchemaModelSupportedRelationship(nameof(Parameters))]
    internal class DataSchemaModelAggregate : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlFormat Format { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32 MaxByteSize { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String ClassName { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsInvariantToDuplicates { get; }=true;
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsInvariantToNulls { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsNullIfEmpty { get; }
        [Relationship("0..1")] public SqlObjectReference Assembly { get; }
        [Relationship("1..1")] public SqlObjectReference Schema   { get; }
        [Relationship("1..1")] public IDataSchemaModelTypeSpecifier ReturnType { get; }
        [Relationship("0..*")] public IList<DataSchemaModelSubroutineParameter> Parameters { get; }

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
