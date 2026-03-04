using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlDropSequenceStatement))]
    internal sealed class SqlScriptDropSequenceStatement : SqlScriptDropStatement<SqlDropSequenceStatement>
        {
        #region ctor{IServiceProvider,SqlDropSequenceStatement}
        public SqlScriptDropSequenceStatement(IServiceProvider context,SqlDropSequenceStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }