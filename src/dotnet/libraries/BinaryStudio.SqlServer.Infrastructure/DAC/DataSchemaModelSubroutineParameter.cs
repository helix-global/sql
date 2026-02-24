using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlSubroutineParameter")]
    internal class DataSchemaModelSubroutineParameter : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public String IsReadOnly { get; }
        [DataSchemaModelPropertyMapping] public String IsOutput { get; }
        [DataSchemaModelPropertyMapping] public SqlScript DefaultExpressionScript { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelSubroutineParameter(DataSchemaModel Scope)
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
