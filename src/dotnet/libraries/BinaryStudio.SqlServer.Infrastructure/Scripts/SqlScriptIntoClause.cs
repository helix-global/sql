using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlIntoClause))]
    internal sealed class SqlScriptIntoClause : SqlScriptCodeObject<SqlIntoClause>
        {
        #region ctor{IServiceProvider,SqlIntoClause}
        public SqlScriptIntoClause(IServiceProvider context,SqlIntoClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }