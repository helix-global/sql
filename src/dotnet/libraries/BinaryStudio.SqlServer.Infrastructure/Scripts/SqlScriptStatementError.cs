using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptStatementError<T> : SqlScriptStatement<T>
        where T : SqlStatementError
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptStatementError(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlStatementError))]
    internal sealed class SqlScriptStatementError : SqlScriptStatementError<SqlStatementError>
        {
        #region ctor{IServiceProvider,SqlStatementError}
        public SqlScriptStatementError(IServiceProvider context,SqlStatementError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }