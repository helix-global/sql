using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlWhereClause))]
    internal sealed class SqlScriptWhereClause : SqlScriptConditionClause<SqlWhereClause>
        {
        #region ctor{IServiceProvider,SqlWhereClause}
        public SqlScriptWhereClause(IServiceProvider context,SqlWhereClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }