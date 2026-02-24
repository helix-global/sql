using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlFullTextIndex")]
    internal class DataSchemaModelFullTextIndex : DataSchemaModelElement
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelFullTextIndex(DataSchemaModel Scope)
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
