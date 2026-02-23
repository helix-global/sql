using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlView")]
    internal class DataSchemaModelView : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public SqlScript QueryScript { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean IsAnsiNullsOn { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean IsSchemaBound { get;private set; }

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
