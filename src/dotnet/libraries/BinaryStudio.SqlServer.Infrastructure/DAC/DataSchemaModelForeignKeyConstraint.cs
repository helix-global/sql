using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlForeignKeyConstraint")]
    internal class DataSchemaModelForeignKeyConstraint : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public SqlForeignKeyAction OnDeleteAction { get;set; }
        [DataSchemaModelPropertyMapping] public SqlForeignKeyAction OnUpdateAction { get;set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelForeignKeyConstraint(DataSchemaModel Scope)
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
