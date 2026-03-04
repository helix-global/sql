using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptNullStatement : SqlScriptStatement<SqlNullStatement>
        {
        #region ctor{IServiceProvider,SqlNullStatement}
        public SqlScriptNullStatement(IServiceProvider context,SqlNullStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }