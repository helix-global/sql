using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptDropFunctionStatement : SqlScriptDropStatement<SqlDropFunctionStatement>
        {
        #region ctor{IServiceProvider,SqlDropFunctionStatement}
        public SqlScriptDropFunctionStatement(IServiceProvider context,SqlDropFunctionStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }