using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlIfElseStatement))]
    internal sealed class SqlScriptIfElseStatement : SqlScriptConditionalStatement<SqlIfElseStatement>
        {
        #region ctor{IServiceProvider,SqlIfElseStatement}
        public SqlScriptIfElseStatement(IServiceProvider context,SqlIfElseStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }