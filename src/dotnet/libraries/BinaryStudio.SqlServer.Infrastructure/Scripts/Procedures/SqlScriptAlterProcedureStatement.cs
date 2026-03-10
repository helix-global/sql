using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlAlterProcedureStatement))]
    internal sealed class SqlScriptAlterProcedureStatement : SqlScriptCreateAlterProcedureStatementBase<SqlAlterProcedureStatement>
        {
        #region ctor{IServiceProvider,SqlAlterProcedureStatement}
        public SqlScriptAlterProcedureStatement(IServiceProvider context,SqlAlterProcedureStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }