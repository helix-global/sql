using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptCompoundStatement : SqlScriptStatement<SqlCompoundStatement>
        {
        #region ctor{IServiceProvider,SqlCompoundStatement}
        public SqlScriptCompoundStatement(IServiceProvider context,SqlCompoundStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }