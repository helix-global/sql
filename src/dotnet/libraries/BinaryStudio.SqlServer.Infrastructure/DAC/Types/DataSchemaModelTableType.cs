using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlTableType")]
    internal class DataSchemaModelTableType : DataSchemaModelElement
        {
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Schema { get;}
        [Relationship("1..*")][UsedImplicitly] public IList<IDataSchemaModelColumn> Columns { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<DataSchemaModelTableTypePrimaryKeyConstraint> Constraints { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelTableType(DataSchemaModel Scope)
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
