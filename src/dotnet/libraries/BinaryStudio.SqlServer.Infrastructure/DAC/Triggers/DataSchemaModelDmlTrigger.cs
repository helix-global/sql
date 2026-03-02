using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlDmlTrigger")]
    internal class DataSchemaModelDmlTrigger : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public Boolean IsAnsiNullsOn { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsUpdateTrigger { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsDeleteTrigger { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsInsertTrigger { get; }
        [PropertyMapping][UsedImplicitly] public SqlScript BodyScript { get; }
        [PropertyMapping][UsedImplicitly] public SqlTriggerType SqlTriggerType { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<SqlObjectReference> BodyDependencies { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Parent { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelDmlTrigger(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            return;
            }
        #endregion
        }
    }
