using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptOutputIntoClause : SqlScriptOutputClause<SqlOutputIntoClause>
        {
        #region ctor{IServiceProvider,SqlOutputIntoClause}
        public SqlScriptOutputIntoClause(IServiceProvider context,SqlOutputIntoClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }