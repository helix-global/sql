using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlProcedure")]
    internal class DataSchemaModelProcedure : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public SqlScript BodyScript { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsAnsiNullsOn { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsQuotedIdentifierOn { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsRecompiled { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsCaller { get; }=true;
        [DataSchemaModelPropertyMapping] public Boolean IsOwner { get; }
        [DataSchemaModelPropertyMapping] public String MethodName { get; }
        [DataSchemaModelPropertyMapping] public String ClassName { get; }

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
