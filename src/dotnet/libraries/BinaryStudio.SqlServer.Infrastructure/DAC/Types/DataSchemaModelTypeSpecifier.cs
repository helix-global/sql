using System;
using System.Text;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlTypeSpecifier")]
    [DataSchemaModelSupportedRelationship(nameof(Type))]
    internal class DataSchemaModelTypeSpecifier : DataSchemaModelElement,IDataSchemaModelTypeSpecifier
        {
        [Relationship("1..1")][UsedImplicitly] public SqlObjectReference Type { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32? Length { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32? Scale { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Int32? Precision { get; }
        [DataSchemaModelPropertyMapping][UsedImplicitly] public Boolean? IsMax { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelTypeSpecifier(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            }
        #endregion
        #region M:ToString:String
        public override String ToString() {
            var r = new StringBuilder();
            if (Type.IsBultIn) {
                var TypeName = Type.Reference.ObjectName;
                r.Append(TypeName);
                if ((Precision != null) && (Scale != null)) { r.Append($"({Precision},{Scale})"); }
                else if (Precision != null) { r.Append($"({Precision})"); }
                else if (Scale != null)     { r.Append($"({Scale})");     }
                else if (Length != null)    { r.Append($"({Length})");    }
                else if (IsMax == true)     { r.Append($"(max)");         }
                }
            return r.ToString();
            }
        #endregion
        }
    }
