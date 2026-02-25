using System;
using System.ComponentModel;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlScalarFunction")]
    [DataSchemaModelSupportedRelationship("BodyDependencies")]
    [DataSchemaModelSupportedRelationship("FunctionBody")]
    [DataSchemaModelSupportedRelationship("Parameters")]
    [DataSchemaModelSupportedRelationship("Schema")]
    [DataSchemaModelSupportedRelationship("Type")]
    [DataSchemaModelSupportedRelationship("DynamicObjects")]
    internal class DataSchemaModelScalarFunction : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAnsiNullsOn { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsSchemaBound { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsQuotedIdentifierOn { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelScalarFunction(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
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
