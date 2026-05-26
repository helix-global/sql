using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlDropSynonymStatement))]
    internal sealed class SqlScriptDropSynonymStatement : SqlScriptDropStatement<SqlDropSynonymStatement>
        {
        #region ctor{IServiceProvider,SqlDropSynonymStatement}
        public SqlScriptDropSynonymStatement(IServiceProvider context,SqlDropSynonymStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }