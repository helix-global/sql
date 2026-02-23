using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlTableTypeConstraint")]
    internal class DataSchemaModelTableTypeConstraint : DataSchemaModelElement
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelTableTypeConstraint(DataSchemaModel Scope)
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
