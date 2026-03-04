using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptAlterFunctionStatement : SqlScriptCreateAlterFunctionStatementBase<SqlAlterFunctionStatement>
        {
        #region ctor{IServiceProvider,SqlAlterFunctionStatement}
        public SqlScriptAlterFunctionStatement(IServiceProvider context,SqlAlterFunctionStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }