using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("SqlLogin")]
    internal class DataSchemaModelLogin : DataSchemaModelElement
        {
        [DataSchemaModelPropertyMapping] public Boolean IsMappedToWindowsLogin { get;private set; }
        [DataSchemaModelPropertyMapping] public Boolean IsCheckPolicyOn { get;private set; } = true;
        [DataSchemaModelPropertyMapping] public String DefaultLanguage { get;private set; }
        [DataSchemaModelPropertyMapping] public String DefaultDatabase { get;private set; }

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

