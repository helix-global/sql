using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlView")]
    internal class DataSchemaModelView : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public SqlScript QueryScript { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsAnsiNullsOn { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsSchemaBound { get; }
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
