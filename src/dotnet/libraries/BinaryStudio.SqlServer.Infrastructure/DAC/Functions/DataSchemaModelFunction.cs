using JetBrains.Annotations;
using System;
using System.Collections.Generic;
using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    internal abstract class DataSchemaModelFunction : DataSchemaModelSubroutine
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAnsiNullsOn { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsSchemaBound { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsQuotedIdentifierOn { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<SqlObjectReference> BodyDependencies { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<DataSchemaModelDynamicColumnSource> DynamicObjects { get; }
        [Relationship("1..1")][UsedImplicitly] public IDataSchemaModelFunctionImplementation FunctionBody { get; }

        #region ctor{DataSchemaModel}
        protected DataSchemaModelFunction(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:ApplyProperty(PropertyDescriptor,Object)
        protected override void ApplyProperty(PropertyDescriptor target,Object value) {
            switch (target.Name) {
                case nameof(IsAnsiNullsOn):
                    base.ApplyProperty(target,PropB(value,true));
                    break;
                case nameof(IsQuotedIdentifierOn):
                    base.ApplyProperty(target,PropB(value,true));
                    break;
                default:
                    base.ApplyProperty(target, value);
                    break;
                }
            }
        #endregion
        }
    }
