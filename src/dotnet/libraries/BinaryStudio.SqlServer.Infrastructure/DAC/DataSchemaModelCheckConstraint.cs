using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlCheckConstraint")]
    [DataSchemaModelSupportedRelationship(nameof(CheckExpressionDependencies))]
    [DataSchemaModelSupportedRelationship(nameof(DefiningTable))]
    internal class DataSchemaModelCheckConstraint : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String CheckExpressionScript { get; }
        [Relationship("1..1")] public SqlObjectReference DefiningTable { get; }
        [Relationship("0..*")] public IList<SqlObjectReference> CheckExpressionDependencies { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelCheckConstraint(DataSchemaModel Scope)
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
