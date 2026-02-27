using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlTable")]
    [DataSchemaModelSupportedRelationship(nameof(Columns))]
    [DataSchemaModelSupportedRelationship(nameof(Schema))]
    internal class DataSchemaModelTable : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAnsiNullsOn { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Schema { get;}
        [Relationship("1..*")][UsedImplicitly] public IList<IDataSchemaModelColumn> Columns { get; }

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
