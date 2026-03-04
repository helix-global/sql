using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlOrderByClause))]
    internal sealed class SqlScriptOrderByClause : SqlScriptCodeObject<SqlOrderByClause>
        {
        #region ctor{IServiceProvider,SqlOrderByClause}
        public SqlScriptOrderByClause(IServiceProvider context,SqlOrderByClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }