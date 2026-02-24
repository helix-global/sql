using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlFullTextCatalog")]
    internal class DataSchemaModelFullTextCatalog : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Boolean IsAccentSensitive { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelFullTextCatalog(DataSchemaModel Scope)
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
