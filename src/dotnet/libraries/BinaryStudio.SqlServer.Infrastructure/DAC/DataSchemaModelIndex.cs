using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlIndex")]
    [DataSchemaModelSupportedRelationship(nameof(ColumnSpecifications))]
    [DataSchemaModelSupportedRelationship(nameof(IndexedObject))]
    [DataSchemaModelSupportedRelationship(nameof(IncludedColumns))]
    [DataSchemaModelSupportedRelationship(nameof(BodyDependencies))]
    internal class DataSchemaModelIndex : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32? FillFactor { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsUnique { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsClustered { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlScript FilterPredicate { get; }
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
