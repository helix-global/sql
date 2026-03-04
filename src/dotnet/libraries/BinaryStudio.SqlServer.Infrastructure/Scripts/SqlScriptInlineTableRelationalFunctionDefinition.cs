using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlInlineTableRelationalFunctionDefinition))]
    internal sealed class SqlScriptInlineTableRelationalFunctionDefinition : SqlScriptFunctionDefinition<SqlInlineTableRelationalFunctionDefinition>
        {
        #region ctor{IServiceProvider,SqlInlineTableRelationalFunctionDefinition}
        public SqlScriptInlineTableRelationalFunctionDefinition(IServiceProvider context,SqlInlineTableRelationalFunctionDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }