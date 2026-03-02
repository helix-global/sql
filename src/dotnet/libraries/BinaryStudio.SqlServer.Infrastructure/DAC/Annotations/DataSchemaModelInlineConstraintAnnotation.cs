using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [ModelMapping("SqlInlineConstraintAnnotation")]
    internal class DataSchemaModelInlineConstraintAnnotation : DataSchemaModelAnnotation
        {
        #region ctor{DataSchemaModel}
        public DataSchemaModelInlineConstraintAnnotation(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        }
    }
