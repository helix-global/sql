using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlWindowClause))]
    internal sealed class SqlScriptWindowClause : SqlScriptCodeObject<SqlWindowClause>
        {
        #region ctor{IServiceProvider,SqlWindowClause}
        public SqlScriptWindowClause(IServiceProvider context,SqlWindowClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }