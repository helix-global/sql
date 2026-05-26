using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCommentStatement))]
    internal sealed class SqlScriptCommentStatement : SqlScriptStatement<SqlCommentStatement>
        {
        #region ctor{IServiceProvider,SqlCommentStatement}
        public SqlScriptCommentStatement(IServiceProvider context,SqlCommentStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }