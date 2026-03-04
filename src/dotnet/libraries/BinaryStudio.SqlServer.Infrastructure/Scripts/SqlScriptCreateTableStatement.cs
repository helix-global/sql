using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCreateTableStatement))]
    internal sealed class SqlScriptCreateTableStatement : SqlScriptDdlStatement<SqlCreateTableStatement>
        {
        #region ctor{IServiceProvider,SqlCreateTableStatement}
        public SqlScriptCreateTableStatement(IServiceProvider context,SqlCreateTableStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }