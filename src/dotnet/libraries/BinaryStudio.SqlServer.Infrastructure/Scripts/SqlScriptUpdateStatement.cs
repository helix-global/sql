using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlUpdateStatement))]
    internal sealed class SqlScriptUpdateStatement : SqlScriptDmlStatement<SqlUpdateStatement>
        {
        #region ctor{IServiceProvider,SqlUpdateStatement}
        public SqlScriptUpdateStatement(IServiceProvider context,SqlUpdateStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }