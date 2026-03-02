using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlStatistic")]
    internal class DataSchemaModelStatistic : DataSchemaModelElement
        {
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Subject { get; }
        [Relationship("1..*")][UsedImplicitly] public IList<SqlObjectReference> Columns { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelStatistic(DataSchemaModel Scope)
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
