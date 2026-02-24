using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlTable")]
    internal class DataSchemaModelTable : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Boolean IsAnsiNullsOn { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelTable(DataSchemaModel Scope)
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
