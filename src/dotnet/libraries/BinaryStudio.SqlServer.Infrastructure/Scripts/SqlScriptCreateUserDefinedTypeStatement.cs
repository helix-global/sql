using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCreateUserDefinedTypeStatement))]
    internal sealed class SqlScriptCreateUserDefinedTypeStatement : SqlScriptCreateTypeStatement<SqlCreateUserDefinedTypeStatement>
        {
        #region ctor{IServiceProvider,SqlCreateUserDefinedTypeStatement}
        public SqlScriptCreateUserDefinedTypeStatement(IServiceProvider context,SqlCreateUserDefinedTypeStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }