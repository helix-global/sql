using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptTableFunctionReturnType : SqlScriptFunctionReturnType<SqlTableFunctionReturnType>
        {
        #region ctor{IServiceProvider,SqlTableFunctionReturnType}
        public SqlScriptTableFunctionReturnType(IServiceProvider context,SqlTableFunctionReturnType source)
            : base(context,source)
            {
            }
        #endregion
        }
    }