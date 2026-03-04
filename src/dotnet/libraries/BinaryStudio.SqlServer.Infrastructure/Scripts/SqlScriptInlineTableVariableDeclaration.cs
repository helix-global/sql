using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptInlineTableVariableDeclaration : SqlScriptCodeObject<SqlInlineTableVariableDeclaration>
        {
        #region ctor{IServiceProvider,SqlInlineTableVariableDeclaration}
        public SqlScriptInlineTableVariableDeclaration(IServiceProvider context,SqlInlineTableVariableDeclaration source)
            : base(context,source)
            {
            }
        #endregion
        }
    }