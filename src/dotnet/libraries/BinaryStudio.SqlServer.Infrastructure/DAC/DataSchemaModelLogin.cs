using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlLogin")]
    internal class DataSchemaModelLogin : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Boolean IsMappedToWindowsLogin { get; }
        [DataSchemaModelPropertyMapping] public Boolean IsCheckPolicyOn { get; } = true;
        [DataSchemaModelPropertyMapping] public String DefaultLanguage { get; }
        [DataSchemaModelPropertyMapping] public String DefaultDatabase { get; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelLogin(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships() {
            base.UpdateRelationships();
            }
        #endregion
        }
    }

