using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlComputedColumn")]
    [DataSchemaModelSupportedRelationship(nameof(ExpressionDependencies))]
    internal class DataSchemaModelComputedColumn : DataSchemaModelElement,IDataSchemaModelColumn
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlScript ExpressionScript { get; }
        [Relationship("0..*")] public IList<SqlObjectReference> ExpressionDependencies { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelComputedColumn(DataSchemaModel Scope)
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
