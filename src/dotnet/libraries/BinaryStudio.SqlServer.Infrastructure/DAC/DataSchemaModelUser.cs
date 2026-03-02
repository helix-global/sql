using System;
using System.ComponentModel;
using System.Linq;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlUser")]
    [DataSchemaModelSupportedRelationship("DefaultSchema")]
    [DataSchemaModelSupportedRelationship("Login")]
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
