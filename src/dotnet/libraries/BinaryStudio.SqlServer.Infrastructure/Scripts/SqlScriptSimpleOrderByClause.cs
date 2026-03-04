using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptSimpleOrderByClause : SqlScriptCodeObject<SqlSimpleOrderByClause>
        {
        #region ctor{IServiceProvider,SqlSimpleOrderByClause}
        public SqlScriptSimpleOrderByClause(IServiceProvider context,SqlSimpleOrderByClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }