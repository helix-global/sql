using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlTable")]
    internal class DataSchemaModelTable : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public Boolean IsAnsiNullsOn { get; }
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
