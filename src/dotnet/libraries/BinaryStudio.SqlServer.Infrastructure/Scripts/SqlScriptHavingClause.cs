using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlHavingClause))]
    internal sealed class SqlScriptHavingClause : SqlScriptConditionClause<SqlHavingClause>
        {
        #region ctor{IServiceProvider,SqlHavingClause}
        public SqlScriptHavingClause(IServiceProvider context,SqlHavingClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }