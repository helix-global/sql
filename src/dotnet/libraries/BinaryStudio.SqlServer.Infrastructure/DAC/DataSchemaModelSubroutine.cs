
using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    internal class DataSchemaModelSubroutine : DataSchemaModelElement
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelSubroutine(DataSchemaModel Scope)
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
