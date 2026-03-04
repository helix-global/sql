using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptBreakStatement : SqlScriptStatement<SqlBreakStatement>
        {
        #region ctor{IServiceProvider,SqlBreakStatement}
        public SqlScriptBreakStatement(IServiceProvider context,SqlBreakStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }