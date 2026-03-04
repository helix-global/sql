using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptExecuteAsClause : SqlScriptCodeObject<SqlExecuteAsClause>
        {
        #region ctor{IServiceProvider,SqlExecuteAsClause}
        protected SqlScriptExecuteAsClause(IServiceProvider context,SqlExecuteAsClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }