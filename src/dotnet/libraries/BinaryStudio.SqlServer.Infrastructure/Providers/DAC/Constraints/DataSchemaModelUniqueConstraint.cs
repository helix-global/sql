using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlUniqueConstraint")]
    internal class DataSchemaModelUniqueConstraint : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public Int32? FillFactor { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsClustered { get; }
        [Relationship("1..*")][UsedImplicitly] public IList<DataSchemaModelIndexedColumnSpecification> ColumnSpecifications { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference DefiningTable { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelUniqueConstraint(DataSchemaModel Scope)
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
                : $"{{UK}}:{DefiningTable}";
            }
        #endregion
        }
    }
