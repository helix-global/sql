using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    internal class DataSchemaModelTypeSpecifierBase : DataSchemaModelElement
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelTypeSpecifierBase(DataSchemaModel Scope)
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
