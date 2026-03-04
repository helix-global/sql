using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlDropProcedureStatement))]
    internal sealed class SqlScriptDropProcedureStatement : SqlScriptDropStatement<SqlDropProcedureStatement>
        {
        #region ctor{IServiceProvider,SqlDropProcedureStatement}
        public SqlScriptDropProcedureStatement(IServiceProvider context,SqlDropProcedureStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }