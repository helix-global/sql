using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptSelectStatement : SqlScriptStatement<SqlSelectStatement>
        {
        #region ctor{IServiceProvider,SqlSelectStatement}
        public SqlScriptSelectStatement(IServiceProvider context,SqlSelectStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }