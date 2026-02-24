using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlView")]
    internal class DataSchemaModelView : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public SqlScript QueryScript { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsAnsiNullsOn { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsSchemaBound { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelView(DataSchemaModel Scope)
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
