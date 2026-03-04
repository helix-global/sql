using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptCreateFunctionStatement : SqlScriptCreateAlterFunctionStatementBase<SqlCreateFunctionStatement>
        {
        #region ctor{IServiceProvider,SqlCreateFunctionStatement}
        public SqlScriptCreateFunctionStatement(IServiceProvider context,SqlCreateFunctionStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }