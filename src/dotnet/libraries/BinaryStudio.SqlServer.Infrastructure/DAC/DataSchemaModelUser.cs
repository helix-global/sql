using System.ComponentModel;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlUser")]
    internal class DataSchemaModelUser : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping][UsedImplicitly] public SqlUserAuthenticationType AuthenticationType { get; }
        [Relationship("0..1",RelationshipKind.Reference|RelationshipKind.Annotation)][UsedImplicitly][TypeConverter(typeof(RelationshipConverter))] public ISqlObjectReference DefaultSchema { get; }
        [Relationship("0..1",RelationshipKind.Reference|RelationshipKind.Annotation)][UsedImplicitly][TypeConverter(typeof(RelationshipConverter))] public ISqlObjectReference Login { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelUser(DataSchemaModel Scope)
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
        }
    }
