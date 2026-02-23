using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlComputedColumn")]
    internal class DataSchemaModelComputedColumn : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public SqlScript ExpressionScript { get;private set; }

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
