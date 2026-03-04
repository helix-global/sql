using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlReturnStatement))]
    internal sealed class SqlScriptReturnStatement : SqlScriptStatement<SqlReturnStatement>
        {
        #region ctor{IServiceProvider,SqlReturnStatement}
        public SqlScriptReturnStatement(IServiceProvider context,SqlReturnStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }