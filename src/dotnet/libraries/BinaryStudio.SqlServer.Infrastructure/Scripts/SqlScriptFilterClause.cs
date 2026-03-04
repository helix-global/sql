using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptFilterClause : SqlScriptCodeObject<SqlFilterClause>
        {
        #region ctor{IServiceProvider,SqlFilterClause}
        public SqlScriptFilterClause(IServiceProvider context,SqlFilterClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }