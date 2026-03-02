using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    internal class DataSchemaModelTableValuedFunction : DataSchemaModelElement
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelTableValuedFunction(DataSchemaModel Scope)
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
