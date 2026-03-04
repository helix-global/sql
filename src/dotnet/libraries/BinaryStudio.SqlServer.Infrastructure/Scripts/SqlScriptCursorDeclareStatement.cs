using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptCursorDeclareStatement : SqlScriptDeclareStatement<SqlCursorDeclareStatement>
        {
        #region ctor{IServiceProvider,SqlCursorDeclareStatement}
        public SqlScriptCursorDeclareStatement(IServiceProvider context,SqlCursorDeclareStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }