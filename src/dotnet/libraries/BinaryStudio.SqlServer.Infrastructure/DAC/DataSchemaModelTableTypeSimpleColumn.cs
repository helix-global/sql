using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlTableTypeSimpleColumn")]
    internal class DataSchemaModelTableTypeSimpleColumn : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Boolean IsNullable { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelTableTypeSimpleColumn(DataSchemaModel Scope)
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
