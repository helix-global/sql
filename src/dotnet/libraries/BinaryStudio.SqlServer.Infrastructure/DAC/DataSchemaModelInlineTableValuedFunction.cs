using System;
using System.Collections.Generic;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlInlineTableValuedFunction")]
    internal class DataSchemaModelInlineTableValuedFunction : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAnsiNullsOn { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<SqlObjectReference> BodyDependencies { get; }
        [Relationship("1..*")][UsedImplicitly] public IList<IDataSchemaModelColumn> Columns { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<DataSchemaModelDynamicColumnSource> DynamicObjects { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<DataSchemaModelSubroutineParameter> Parameters { get; }
        [Relationship("1..1")][UsedImplicitly] public IDataSchemaModelFunctionImplementation FunctionBody { get;}
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Schema { get;}

        #region ctor{DataSchemaModel}
        public DataSchemaModelInlineTableValuedFunction(DataSchemaModel Scope)
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
