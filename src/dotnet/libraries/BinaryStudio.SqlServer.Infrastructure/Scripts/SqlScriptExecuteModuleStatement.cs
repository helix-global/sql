using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlExecuteModuleStatement))]
    internal sealed class SqlScriptExecuteModuleStatement : SqlScriptExecuteStatement<SqlExecuteModuleStatement>
        {
        #region ctor{IServiceProvider,SqlExecuteModuleStatement}
        public SqlScriptExecuteModuleStatement(IServiceProvider context,SqlExecuteModuleStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }