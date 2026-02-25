using System;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlDmlTrigger")]
    internal class DataSchemaModelDmlTrigger : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAnsiNullsOn { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsUpdateTrigger { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsDeleteTrigger { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsInsertTrigger { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlScript BodyScript { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlTriggerType SqlTriggerType { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelDmlTrigger(DataSchemaModel Scope)
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
