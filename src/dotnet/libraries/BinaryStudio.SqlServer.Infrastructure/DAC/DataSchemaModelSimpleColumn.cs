using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlSimpleColumn")]
    internal class DataSchemaModelSimpleColumn : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Boolean IsNullable { get; } = true;
        [DataSchemaModelPropertyMapping] public Boolean IsIdentity { get; } = false;
        [DataSchemaModelPropertyMapping] public String Collation { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelSimpleColumn(DataSchemaModel Scope)
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
