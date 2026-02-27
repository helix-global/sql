using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlApplicationRole")]
    internal class DataSchemaModelApplicationRole : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String Password { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelApplicationRole(DataSchemaModel Scope)
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
