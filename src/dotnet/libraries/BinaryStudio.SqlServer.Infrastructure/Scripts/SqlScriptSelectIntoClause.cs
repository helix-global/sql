using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlSelectIntoClause))]
    internal sealed class SqlScriptSelectIntoClause : SqlScriptCodeObject<SqlSelectIntoClause>
        {
        #region ctor{IServiceProvider,SqlSelectIntoClause}
        public SqlScriptSelectIntoClause(IServiceProvider context,SqlSelectIntoClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }