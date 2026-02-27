using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlView")]
    [DataSchemaModelSupportedRelationship(nameof(Columns))]
    [DataSchemaModelSupportedRelationship(nameof(QueryDependencies))]
    [DataSchemaModelSupportedRelationship(nameof(Schema))]
    [DataSchemaModelSupportedRelationship(nameof(DynamicObjects))]
    internal class DataSchemaModelView : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlScript QueryScript { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAnsiNullsOn { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsSchemaBound { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<DataSchemaModelDynamicColumnSource> DynamicObjects { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<SqlObjectReference> QueryDependencies { get; }
        [Relationship("1..*")][UsedImplicitly] public IList<IDataSchemaModelColumn> Columns { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Schema { get;}

        #region ctor{DataSchemaModel}
        public DataSchemaModelView(DataSchemaModel Scope)
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
