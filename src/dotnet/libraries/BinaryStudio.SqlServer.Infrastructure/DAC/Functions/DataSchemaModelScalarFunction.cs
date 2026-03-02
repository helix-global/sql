using System;
using System.Collections.Generic;
using System.ComponentModel;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlScalarFunction")]
    internal class DataSchemaModelScalarFunction : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAnsiNullsOn { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsSchemaBound { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsQuotedIdentifierOn { get; }
        [Relationship("1..1")][UsedImplicitly] public IDataSchemaModelTypeSpecifier Type { get; }
        [Relationship("1..1")][UsedImplicitly] public IDataSchemaModelFunctionImplementation FunctionBody { get; }
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Schema { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<DataSchemaModelSubroutineParameter> Parameters { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<SqlObjectReference> BodyDependencies { get; }
        [Relationship("0..*")][UsedImplicitly] public IList<DataSchemaModelDynamicColumnSource> DynamicObjects { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelScalarFunction(DataSchemaModel Scope)
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
