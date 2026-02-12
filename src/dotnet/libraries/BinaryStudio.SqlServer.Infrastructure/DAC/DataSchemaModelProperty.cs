using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    public class DataSchemaModelProperty : DataSchemaModelElement
        {
        [DataSchemaModelAttributeMapping] public String Value { get;private set; }

        #region ctor{DataSchemaModel}
        public DataSchemaModelProperty(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        }
    }
