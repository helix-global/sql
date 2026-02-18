using System;
using System.Linq;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlDefaultConstraint")]
    internal class DataSchemaModelDefaultConstraint : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public String DefaultExpressionScript { get;private set; }
        public SqlObjectReference DefiningTable { get;private set; }
        public SqlObjectReference ForColumn     { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelDefaultConstraint(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            DefiningTable = Relationships.FirstOrDefault(i=>i.Value.Name == nameof(DefiningTable)).Value?.References.FirstOrDefault();
            ForColumn     = Relationships.FirstOrDefault(i=>i.Value.Name == nameof(ForColumn)).Value?.References.FirstOrDefault();
            }
        #endregion
        #region M:ToString:String
        public override String ToString() {
            if (!String.IsNullOrWhiteSpace(Name)) { return Name; }
            var r = Annotations.OfType<DataSchemaModelInlineConstraintAnnotation>().FirstOrDefault()?.Name;
            return r ?? base.ToString();
            }
        #endregion
        }
    }
