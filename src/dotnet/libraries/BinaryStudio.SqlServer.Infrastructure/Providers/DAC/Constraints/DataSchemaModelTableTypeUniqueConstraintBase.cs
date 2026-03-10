using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    internal class DataSchemaModelTableTypeUniqueConstraintBase : DataSchemaModelElement
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelTableTypeUniqueConstraintBase(DataSchemaModel Scope)
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
