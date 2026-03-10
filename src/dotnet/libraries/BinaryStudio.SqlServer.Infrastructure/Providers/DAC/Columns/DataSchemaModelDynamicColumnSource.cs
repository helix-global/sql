using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlDynamicColumnSource")]
    internal class DataSchemaModelDynamicColumnSource : DataSchemaModelElement
        {
        [Relationship("1..*")][UsedImplicitly] public IList<IDataSchemaModelColumn> Columns { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelDynamicColumnSource(DataSchemaModel Scope)
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
