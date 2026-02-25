using System;
using System.Collections.Generic;
using System.Text;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlExtendedProperty")]
    [DataSchemaModelSupportedRelationship("Host")]
    internal class DataSchemaModelExtendedProperty : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlScript Value { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelExtendedProperty(DataSchemaModel Scope)
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
