using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptInlineTableVariableDeclareStatement : SqlScriptDeclareStatement<SqlInlineTableVariableDeclareStatement>
        {
        #region ctor{IServiceProvider,SqlInlineTableVariableDeclareStatement}
        public SqlScriptInlineTableVariableDeclareStatement(IServiceProvider context,SqlInlineTableVariableDeclareStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }