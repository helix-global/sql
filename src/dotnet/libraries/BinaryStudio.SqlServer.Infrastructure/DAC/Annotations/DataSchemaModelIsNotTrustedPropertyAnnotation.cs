using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [DataSchemaModelMapping("IsNotTrustedPropertyAnnotation")]
    internal class DataSchemaModelIsNotTrustedPropertyAnnotation : DataSchemaModelAnnotation
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelIsNotTrustedPropertyAnnotation(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        }
    }
