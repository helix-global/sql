using System;
using System.Collections.Generic;
using System.Linq;
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
        public SqlObjectReference Assembly { get;private set; }
        public SqlObjectReference Schema   { get;private set; }
        public IDataSchemaModelTypeSpecifier ReturnType { get;private set; }
        public IList<DataSchemaModelSubroutineParameter> Parameters { get; } = new List<DataSchemaModelSubroutineParameter>();

        #region ctor{DataSchemaModel}
        public DataSchemaModelAggregate(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            Assembly = Relationships.FirstOrDefault(i=>i.Value.Name == nameof(Assembly)).Value?.References.FirstOrDefault();
            Schema   = Relationships.FirstOrDefault(i=>i.Value.Name == nameof(Schema)).Value?.References.FirstOrDefault();
            ReturnType = (IDataSchemaModelTypeSpecifier)Relationships[nameof(ReturnType)].Elements[0];
            Parameters.AddRange(Relationships[nameof(Parameters)].Elements.OfType<DataSchemaModelSubroutineParameter>());
            return;
            }
        #endregion
        }
    }
