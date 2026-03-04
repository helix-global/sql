using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptForBrowseClause : SqlScriptForClause<SqlForBrowseClause>
        {
        #region ctor{IServiceProvider,SqlForBrowseClause}
        public SqlScriptForBrowseClause(IServiceProvider context,SqlForBrowseClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }