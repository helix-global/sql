using System;
using System.ComponentModel;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlProcedure")]
    [DataSchemaModelSupportedRelationship("BodyDependencies")]
    [DataSchemaModelSupportedRelationship("DynamicObjects")]
    [DataSchemaModelSupportedRelationship("Parameters")]
    [DataSchemaModelSupportedRelationship("Schema")]
    [DataSchemaModelSupportedRelationship("Assembly")]
    internal class DataSchemaModelProcedure : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlScript BodyScript { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsAnsiNullsOn { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsQuotedIdentifierOn { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsRecompiled { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsCaller { get; }=true;
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean IsOwner { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String MethodName { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String ClassName { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelProcedure(DataSchemaModel Scope)
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
