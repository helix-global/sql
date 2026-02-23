using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlDynamicColumnSource")]
    internal class DataSchemaModelDynamicColumnSource : DataSchemaModelElement
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelDynamicColumnSource(DataSchemaModel Scope)
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
