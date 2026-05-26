using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlTryCatchStatement))]
    internal sealed class SqlScriptTryCatchStatement : SqlScriptStatement<SqlTryCatchStatement>
        {
        #region ctor{IServiceProvider,SqlTryCatchStatement}
        public SqlScriptTryCatchStatement(IServiceProvider context,SqlTryCatchStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }