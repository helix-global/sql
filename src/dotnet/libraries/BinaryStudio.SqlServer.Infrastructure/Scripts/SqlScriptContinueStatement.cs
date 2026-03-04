using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptContinueStatement : SqlScriptStatement<SqlContinueStatement>
        {
        #region ctor{IServiceProvider,SqlContinueStatement}
        public SqlScriptContinueStatement(IServiceProvider context,SqlContinueStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }