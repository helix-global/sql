using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlExecuteStatementError))]
    internal sealed class SqlScriptExecuteStatementError : SqlScriptStatementError<SqlExecuteStatementError>
        {
        #region ctor{IServiceProvider,SqlExecuteStatementError}
        public SqlScriptExecuteStatementError(IServiceProvider context,SqlExecuteStatementError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }