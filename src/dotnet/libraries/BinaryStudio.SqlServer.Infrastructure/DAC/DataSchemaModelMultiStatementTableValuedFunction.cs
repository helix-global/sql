using System;
using System.Reflection;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlMultiStatementTableValuedFunction")]
    internal class DataSchemaModelMultiStatementTableValuedFunction : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Boolean IsAnsiNullsOn { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsQuotedIdentifierOn { get; }
        [DataSchemaModelPropertyMapping] public String ReturnTableVariable { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelMultiStatementTableValuedFunction(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            }
        #endregion
        #region M:ApplyProperty(MemberInfo,Object)
        protected override void ApplyProperty(MemberInfo target,Object value) {
            switch (target.Name) {
                case nameof(IsAnsiNullsOn):
                case "<IsAnsiNullsOn>k__BackingField":
                    base.ApplyProperty(target,PropB(value,true));
                    break;
                case "<IsQuotedIdentifierOn>k__BackingField":
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
