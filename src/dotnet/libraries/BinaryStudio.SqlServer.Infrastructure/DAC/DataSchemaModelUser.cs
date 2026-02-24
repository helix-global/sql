using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlUser")]
    internal class DataSchemaModelUser : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Int32 AuthenticationType { get; } //TODO:: Should be enum!

        #region ctor{DataSchemaModel}
        public DataSchemaModelUser(DataSchemaModel Scope)
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
