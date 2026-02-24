using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlDmlTrigger")]
    internal class DataSchemaModelDmlTrigger : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Boolean IsAnsiNullsOn { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsUpdateTrigger { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsDeleteTrigger { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsInsertTrigger { get; }
        [DataSchemaModelPropertyMapping] public SqlScript BodyScript { get; }
        [DataSchemaModelPropertyMapping] public Int32 SqlTriggerType { get; } //TODO:: Should be enum!

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
