using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlTableTypePrimaryKeyConstraint")]
    [DataSchemaModelSupportedRelationship(nameof(ColumnSpecifications))]
    internal class DataSchemaModelTableTypePrimaryKeyConstraint : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsClustered { get; }
        [Relationship("1..*")][UsedImplicitly] public IList<DataSchemaModelTableTypeIndexedColumnSpecification> ColumnSpecifications { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelTableTypePrimaryKeyConstraint(DataSchemaModel Scope)
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
