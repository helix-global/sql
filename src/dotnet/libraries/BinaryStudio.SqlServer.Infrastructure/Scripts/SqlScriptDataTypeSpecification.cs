using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptDataTypeSpecification : SqlScriptCodeObject<SqlDataTypeSpecification>
        {
        #region ctor{IServiceProvider,SqlDataTypeSpecification}
        public SqlScriptDataTypeSpecification(IServiceProvider context,SqlDataTypeSpecification source)
            : base(context,source)
            {
            }
        #endregion
        }
    }