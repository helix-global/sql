using System;
using System.Collections.Generic;
using System.Linq;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    using SqlIndexedColumnSpecification=DataSchemaModelIndexedColumnSpecification;
    [DataSchemaModelMapping("SqlPrimaryKeyConstraint")]
    internal class DataSchemaModelPrimaryKeyConstraint : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Int32? FillFactor { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean IsClustered { get;private set; } = true;
        public IList<SqlIndexedColumnSpecification> ColumnSpecifications { get; } = new List<SqlIndexedColumnSpecification>();
        public SqlObjectReference DefiningTable { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelPrimaryKeyConstraint(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            ColumnSpecifications.AddRange(Relationships[nameof(ColumnSpecifications)].Elements.OfType<SqlIndexedColumnSpecification>());
            DefiningTable = Relationships[nameof(DefiningTable)].References[0];
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
