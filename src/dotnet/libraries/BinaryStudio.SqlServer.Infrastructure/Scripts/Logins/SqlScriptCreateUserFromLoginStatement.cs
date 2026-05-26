using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCreateUserFromLoginStatement))]
    internal sealed class SqlScriptCreateUserFromLoginStatement : SqlScriptCreateUserStatement<SqlCreateUserFromLoginStatement>
        {
        #region ctor{IServiceProvider,SqlCreateUserFromLoginStatement}
        public SqlScriptCreateUserFromLoginStatement(IServiceProvider context,SqlCreateUserFromLoginStatement source)
            : base(context, source)
            {
            }
        #endregion
        }
    }