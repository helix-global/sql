using System;
using System.Reflection;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlMultiStatementTableValuedFunction")]
    internal class DataSchemaModelMultiStatementTableValuedFunction : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Boolean IsAnsiNullsOn { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean IsQuotedIdentifierOn { get;private set; }
        [DataSchemaModelPropertyMapping] public String ReturnTableVariable { get;private set; }

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
