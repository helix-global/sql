using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
        [SqlScriptObject(typeof(SqlCreateUserStatementError))]
    internal sealed class SqlScriptCreateUserStatementError : SqlScriptCreateUserStatement<SqlCreateUserStatementError>
        {
        #region ctor{IServiceProvider,SqlCreateUserStatementError}
        public SqlScriptCreateUserStatementError(IServiceProvider context,SqlCreateUserStatementError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }