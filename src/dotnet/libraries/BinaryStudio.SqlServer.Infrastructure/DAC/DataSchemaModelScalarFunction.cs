using System;
using System.Collections.Generic;
using System.ComponentModel;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlScalarFunction")]
    [DataSchemaModelSupportedRelationship(nameof(FunctionBody))]
    [DataSchemaModelSupportedRelationship(nameof(Parameters))]
    [DataSchemaModelSupportedRelationship(nameof(Schema))]
    [DataSchemaModelSupportedRelationship(nameof(Type))]
    [DataSchemaModelSupportedRelationship(nameof(BodyDependencies))]
    [DataSchemaModelSupportedRelationship("DynamicObjects")]
    internal class DataSchemaModelScalarFunction : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAnsiNullsOn { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsSchemaBound { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsQuotedIdentifierOn { get; }
        [Relationship("1..1")] public IDataSchemaModelTypeSpecifier Type { get; }
        [Relationship("1..1")] public IDataSchemaModelFunctionImplementation FunctionBody { get; }
        [Relationship("1..1")] public SqlObjectReference Schema { get; }
        [Relationship("0..*")] public IList<DataSchemaModelSubroutineParameter> Parameters { get; }
        [Relationship("0..*")] public IList<SqlObjectReference> BodyDependencies { get; }

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
