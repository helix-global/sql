using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlPrimaryKeyConstraint")]
    internal class DataSchemaModelPrimaryKeyConstraint : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public Int32? FillFactor { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsClustered { get; } = true;
        [Relationship("1..*")][UsedImplicitly] public IList<DataSchemaModelIndexedColumnSpecification> ColumnSpecifications { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference DefiningTable { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelPrimaryKeyConstraint(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            }
        #endregion
        #region M:ToString:String
        public override String ToString() {
            return (!String.IsNullOrWhiteSpace(Name))
                ? Name
                : $"{{PK}}:{DefiningTable}";
            }
        #endregion
        }
    }
