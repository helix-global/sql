using System;
using System.Collections.Generic;
using System.Text;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlForeignKeyConstraint")]
    internal class DataSchemaModelForeignKeyConstraint : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlForeignKeyAction OnDeleteAction { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlForeignKeyAction OnUpdateAction { get; }

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
