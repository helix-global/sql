using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptCreateUserWithoutLoginStatement : SqlScriptCreateUserStatement<SqlCreateUserWithoutLoginStatement>
        {
        #region ctor{IServiceProvider,SqlCreateUserWithoutLoginStatement}
        public SqlScriptCreateUserWithoutLoginStatement(IServiceProvider context,SqlCreateUserWithoutLoginStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }