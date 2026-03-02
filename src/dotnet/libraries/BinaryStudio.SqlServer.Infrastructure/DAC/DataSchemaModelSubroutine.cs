
using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    internal abstract class DataSchemaModelSubroutine : DataSchemaModelElement
        {
        [PropertyMapping][UsedImplicitly] public Boolean IsCaller { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsEncrypted { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsOwner { get; }
        [PropertyMapping][UsedImplicitly] public Boolean IsSelf { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Schema { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<DataSchemaModelSubroutineParameter> Parameters { get; }

        #region ctor{DataSchemaModel}
        protected DataSchemaModelSubroutine(DataSchemaModel Scope)
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
