using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlGroupByClause))]
    internal sealed class SqlScriptGroupByClause : SqlScriptCodeObject<SqlGroupByClause>
        {
        #region ctor{IServiceProvider,SqlGroupByClause}
        public SqlScriptGroupByClause(IServiceProvider context,SqlGroupByClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }