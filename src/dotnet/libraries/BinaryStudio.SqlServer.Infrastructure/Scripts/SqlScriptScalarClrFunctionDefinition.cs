using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptScalarClrFunctionDefinition : SqlScriptFunctionDefinition<SqlScalarClrFunctionDefinition>
        {
        #region ctor{IServiceProvider,SqlScalarClrFunctionDefinition}
        public SqlScriptScalarClrFunctionDefinition(IServiceProvider context,SqlScalarClrFunctionDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }