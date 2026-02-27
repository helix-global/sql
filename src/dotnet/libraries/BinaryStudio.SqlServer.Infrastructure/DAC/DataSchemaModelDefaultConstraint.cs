using System;
using System.Linq;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlDefaultConstraint")]
    [DataSchemaModelSupportedRelationship(nameof(DefiningTable))]
    [DataSchemaModelSupportedRelationship(nameof(ForColumn))]
    internal class DataSchemaModelDefaultConstraint : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public String DefaultExpressionScript { get; }
        [Relationship("1..1")] public SqlObjectReference DefiningTable { get;private set; }
        [Relationship("1..1")] public SqlObjectReference ForColumn     { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelDefaultConstraint(DataSchemaModel Scope)
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
        #region M:ToString:String
        public override String ToString() {
            if (!String.IsNullOrWhiteSpace(Name)) { return Name; }
            var r = Annotations.OfType<DataSchemaModelInlineConstraintAnnotation>().FirstOrDefault()?.Name;
            return r ?? base.ToString();
            }
        #endregion
        }
    }
