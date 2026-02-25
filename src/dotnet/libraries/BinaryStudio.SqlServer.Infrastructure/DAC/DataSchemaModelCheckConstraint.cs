using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlCheckConstraint")]
    internal class DataSchemaModelCheckConstraint : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String CheckExpressionScript { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelCheckConstraint(DataSchemaModel Scope)
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
