using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlTableTypeColumn")]
    internal class DataSchemaModelTableTypeColumn : DataSchemaModelElement
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelTableTypeColumn(DataSchemaModel Scope)
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
