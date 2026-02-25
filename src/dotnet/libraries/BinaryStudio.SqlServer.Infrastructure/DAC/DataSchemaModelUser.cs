using System;
using System.Collections.Generic;
using System.Text;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlUser")]
    internal class DataSchemaModelUser : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlUserAuthenticationType AuthenticationType { get; }

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
