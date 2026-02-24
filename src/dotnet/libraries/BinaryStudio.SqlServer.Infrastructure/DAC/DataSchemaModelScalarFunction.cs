using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlScalarFunction")]
    internal class DataSchemaModelScalarFunction : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Boolean IsAnsiNullsOn { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsSchemaBound { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsQuotedIdentifierOn { get; }

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
