using System;
using System.Collections.Generic;
using System.Text;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlComputedColumn")]
    [DataSchemaModelSupportedRelationship("ExpressionDependencies")]
    internal class DataSchemaModelComputedColumn : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlScript ExpressionScript { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelComputedColumn(DataSchemaModel Scope)
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
