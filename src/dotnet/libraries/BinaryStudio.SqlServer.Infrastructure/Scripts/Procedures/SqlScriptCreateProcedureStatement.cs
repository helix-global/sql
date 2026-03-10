using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCreateProcedureStatement))]
    internal sealed class SqlScriptCreateProcedureStatement : SqlScriptCreateAlterProcedureStatementBase<SqlCreateProcedureStatement>
        {
        #region ctor{IServiceProvider,SqlCreateProcedureStatement}
        public SqlScriptCreateProcedureStatement(IServiceProvider context,SqlCreateProcedureStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }