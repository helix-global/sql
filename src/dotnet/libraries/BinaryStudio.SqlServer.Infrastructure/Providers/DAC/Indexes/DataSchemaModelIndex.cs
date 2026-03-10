using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlIndex")]
    internal class DataSchemaModelIndex : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public Int32? FillFactor { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsUnique { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsClustered { get; }
        [PropertyMapping][UsedImplicitly] public SqlScript FilterPredicate { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference IndexedObject { get; }
        [Relationship("1..*")][UsedImplicitly] public IList<DataSchemaModelIndexedColumnSpecification> ColumnSpecifications { get;}
        [Relationship("0..*")][UsedImplicitly] public IList<SqlObjectReference> IncludedColumns { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<SqlObjectReference> BodyDependencies { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelIndex(DataSchemaModel Scope)
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
